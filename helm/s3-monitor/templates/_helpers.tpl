{{/*
s3-monitor chart helpers. The application code runs from the quay.io image
(.Values.image); this chart only provides configuration and AWS/EKS resources.
*/}}

{{- define "s3monitor.global" -}}
{{- toJson (.Values.global | default dict) -}}
{{- end -}}

{{- define "s3monitor.crossplane" -}}
{{- $global := include "s3monitor.global" . | fromJson -}}
{{- toJson (get $global "crossplane" | default dict) -}}
{{- end -}}

{{- define "s3monitor.crossplaneEnabled" -}}
{{- $cp := include "s3monitor.crossplane" . | fromJson -}}
{{- if get $cp "enabled" }}true{{ end -}}
{{- end -}}

{{/* Account id as a string. gen3 values often have it as a bare YAML number, which Helm reads as float64. */}}
{{- define "s3monitor.accountId" -}}
{{- $cp := include "s3monitor.crossplane" . | fromJson -}}
{{- $a := get $cp "accountId" -}}
{{- if kindIs "float64" $a -}}{{ printf "%.0f" $a }}{{- else -}}{{ toString ($a | default "") }}{{- end -}}
{{- end -}}

{{- define "s3monitor.region" -}}
{{- .Values.aws.region -}}
{{- end -}}

{{- define "s3monitor.partition" -}}
{{- $r := include "s3monitor.region" . -}}
{{- if hasPrefix "us-gov-" $r }}aws-us-gov{{ else if hasPrefix "cn-" $r }}aws-cn{{ else }}aws{{ end -}}
{{- end -}}

{{- define "s3monitor.providerConfig" -}}
{{- $cp := include "s3monitor.crossplane" . | fromJson -}}
{{- get $cp "providerConfigName" | default "provider-aws" -}}
{{- end -}}

{{- define "s3monitor.oidcProviderUrl" -}}
{{- $cp := include "s3monitor.crossplane" . | fromJson -}}
{{- get $cp "oidcProviderUrl" | default "" | trimPrefix "https://" | trimSuffix "/" -}}
{{- end -}}

{{/* "<environment>-<namespace>": prefix of every AWS resource name, as for the other vectis roles. */}}
{{- define "s3monitor.base" -}}
{{- $global := include "s3monitor.global" . | fromJson -}}
{{- printf "%s-%s" (get $global "environment" | default "") .Release.Namespace -}}
{{- end -}}

{{/* Prefix of the Kubernetes objects. Distinct from the legacy s3-monitor in vectis-overlays. */}}
{{- define "s3monitor.fullname" -}}
{{- .Values.fullnameOverride | default "s3-monitor-activemq" | trunc 52 | trimSuffix "-" -}}
{{- end -}}

{{/* CronJob IRSA role. Same name the ServiceAccount annotation uses. */}}
{{- define "s3monitor.roleName" -}}
{{- printf "%s-%s" (include "s3monitor.base" .) .Values.serviceAccount.name -}}
{{- end -}}

{{- define "s3monitor.labels" -}}
app: {{ include "s3monitor.fullname" . }}
app.kubernetes.io/name: {{ include "s3monitor.fullname" . }}
app.kubernetes.io/part-of: s3-monitor
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "s3monitor.awsTags" -}}
{{- $global := include "s3monitor.global" . | fromJson -}}
{{- toJson (dict "Project" (include "s3monitor.fullname" .) "Environment" (get $global "environment" | default "") "Namespace" .Release.Namespace) -}}
{{- end -}}

{{/* Crossplane v1beta1 IAM tag list: [{key, value}] */}}
{{- define "s3monitor.iamTags" -}}
{{- range $k, $v := (include "s3monitor.awsTags" . | fromJson) }}
- key: {{ $k | quote }}
  value: {{ $v | quote }}
{{- end }}
{{- end -}}

{{/* Runtime image: pinned by digest when one is given. */}}
{{- define "s3monitor.image" -}}
{{- $i := .Values.image -}}
{{- if $i.digest -}}{{ printf "%s@%s" $i.repository $i.digest }}{{- else -}}{{ printf "%s:%s" $i.repository $i.tag }}{{- end -}}
{{- end -}}

{{/* Tenants that still get access (everything except lifecycle "retired"). */}}
{{- define "s3monitor.activeTenants" -}}
{{- $out := list -}}
{{- range $i, $t := .Values.config.tenants -}}
{{- if ne ($t.lifecycle | default "active") "retired" -}}
{{- $out = append $out (merge (dict "_index" $i) $t) -}}
{{- end -}}
{{- end -}}
{{- toJson $out -}}
{{- end -}}

{{/*
The environment config the application reads (schema: scripts/config.py in the image).
Rendered from values, so namespace, service account and role always match this release.
*/}}
{{- define "s3monitor.configJson" -}}
{{- $v := .Values -}}
{{- $c := $v.config -}}
{{- $lake := dict "bucket" $c.lake.bucket "prefix" $c.lake.prefix -}}
{{- if $c.lake.kmsKeyArn }}{{ $_ := set $lake "kms_key_arn" $c.lake.kmsKeyArn }}{{ end -}}
{{- $mq := dict "existing_mq_stomp_endpoints" $c.mq.stompEndpoints "existing_mq_secret_arn" $c.mq.secretArn "destination_prefix" $c.mq.destinationPrefix "resolve_ipv4" $c.mq.resolveIpv4 -}}
{{- $sqs := dict "queue_url" $c.sqs.queueUrl "wait_time_seconds" (int $c.sqs.waitTimeSeconds) "batch_size" (int $c.sqs.batchSize) "max_receive_count" (int $c.sqs.maxReceiveCount) "max_run_seconds" (int $c.sqs.maxRunSeconds) "flush_rows" (int $c.sqs.flushRows) "flush_seconds" (int $c.sqs.flushSeconds) -}}
{{- $eks := dict "cluster_name" $v.eksClusterName "namespace" .Release.Namespace "service_account" $v.serviceAccount.name -}}
{{- $oidc := include "s3monitor.oidcProviderUrl" . -}}
{{- if $oidc }}{{ $_ := set $eks "oidc_provider_url" $oidc }}{{ end -}}
{{- $cfg := dict
    "name" (include "s3monitor.base" .)
    "account" (include "s3monitor.accountId" .)
    "region" (include "s3monitor.region" .)
    "apply" $c.apply
    "use_fips_aws_endpoints" $c.useFipsAwsEndpoints
    "eks" $eks
    "iam" (dict "role_name" (include "s3monitor.roleName" .))
    "sqs" $sqs
    "lake" $lake
    "mq" $mq
    "tenants" $c.tenants
-}}
{{- if $c.assumeRoleArn }}{{ $_ := set $cfg "assume_role_arn" $c.assumeRoleArn }}{{ end -}}
{{- toPrettyJson $cfg -}}
{{- end -}}

{{/* arn:aws:sqs:<region>:<account>:<name> from https://sqs.<region>.amazonaws.com/<account>/<name> */}}
{{- define "s3monitor.queueArn" -}}
{{- $parts := splitList "/" (.Values.config.sqs.queueUrl | trimSuffix "/") -}}
{{- printf "arn:%s:sqs:%s:%s:%s" (include "s3monitor.partition" .) (include "s3monitor.region" .) (index $parts 3) (index $parts 4) -}}
{{- end -}}

{{/* ---------- IAM policy statements (JSON lists) ---------- */}}

{{- define "s3monitor.s3Arn" -}}
{{- printf "arn:%s:s3:::%s" (index . 0) (index . 1) -}}
{{- end -}}

{{/* ListBucket scoped to a prefix. GetBucketLocation carries no s3:prefix, so it gets its own statement. */}}
{{- define "s3monitor.listStatements" -}}
{{- $sid := index . 0 -}}{{- $arn := index . 1 -}}{{- $prefix := index . 2 -}}
{{- if $prefix -}}
{{- toJson (list
      (dict "Sid" $sid "Effect" "Allow" "Action" (list "s3:ListBucket") "Resource" (list $arn) "Condition" (dict "StringLike" (dict "s3:prefix" (list (printf "%s*" $prefix)))))
      (dict "Sid" (printf "%sLocation" $sid) "Effect" "Allow" "Action" (list "s3:GetBucketLocation") "Resource" (list $arn))) -}}
{{- else -}}
{{- toJson (list (dict "Sid" $sid "Effect" "Allow" "Action" (list "s3:ListBucket" "s3:GetBucketLocation") "Resource" (list $arn))) -}}
{{- end -}}
{{- end -}}

{{- define "s3monitor.lakeStatements" -}}
{{- $p := include "s3monitor.partition" . -}}
{{- $lake := .Values.config.lake -}}
{{- $arn := include "s3monitor.s3Arn" (list $p $lake.bucket) -}}
{{- $prefix := trimAll "/" $lake.prefix -}}
{{- $stmts := include "s3monitor.listStatements" (list "LakeList" $arn (printf "%s/" $prefix)) | fromJsonArray -}}
{{- $stmts = append $stmts (dict "Sid" "LakeReadWrite" "Effect" "Allow" "Action" (list "s3:GetObject" "s3:PutObject" "s3:AbortMultipartUpload") "Resource" (list (printf "%s/%s/*" $arn $prefix))) -}}
{{- if $lake.kmsKeyArn -}}
{{- $stmts = append $stmts (dict "Sid" "LakeKms" "Effect" "Allow" "Action" (list "kms:Decrypt" "kms:GenerateDataKey" "kms:DescribeKey") "Resource" (list $lake.kmsKeyArn)) -}}
{{- end -}}
{{- toJson $stmts -}}
{{- end -}}

{{/* CronJob: everything not tied to a single tenant. */}}
{{- define "s3monitor.cronjobBaseStatements" -}}
{{- $c := .Values.config -}}
{{- $stmts := include "s3monitor.lakeStatements" . | fromJsonArray -}}
{{- $stmts = append $stmts (dict "Sid" "ReadMqSecret" "Effect" "Allow" "Action" (list "secretsmanager:GetSecretValue" "secretsmanager:DescribeSecret") "Resource" (list $c.mq.secretArn)) -}}
{{- $stmts = append $stmts (dict "Sid" "ConsumeEvents" "Effect" "Allow" "Action" (list "sqs:ReceiveMessage" "sqs:DeleteMessage" "sqs:ChangeMessageVisibility" "sqs:GetQueueAttributes" "sqs:GetQueueUrl" "sqs:SendMessage") "Resource" (list (include "s3monitor.queueArn" .))) -}}
{{- if $c.mq.secretKmsKeyArn -}}
{{- $stmts = append $stmts (dict "Sid" "MqSecretKms" "Effect" "Allow" "Action" (list "kms:Decrypt" "kms:DescribeKey") "Resource" (list $c.mq.secretKmsKeyArn)) -}}
{{- end -}}
{{- if $c.assumeRoleArn -}}
{{- $stmts = append $stmts (dict "Sid" "AssumeConfiguredRole" "Effect" "Allow" "Action" (list "sts:AssumeRole") "Resource" (list $c.assumeRoleArn)) -}}
{{- end -}}
{{- toJson $stmts -}}
{{- end -}}

{{/* CronJob: statements for one tenant ((list $ tenant)). */}}
{{- define "s3monitor.cronjobTenantStatements" -}}
{{- $root := index . 0 -}}{{- $t := index . 1 -}}
{{- $p := include "s3monitor.partition" $root -}}
{{- $arn := include "s3monitor.s3Arn" (list $p $t.existing_bucket_name) -}}
{{- $sid := printf "T%v%s" $t._index (regexReplaceAll "[^A-Za-z0-9]" $t.id "") -}}
{{- $prefix := trimPrefix "/" ($t.prefix | default "") -}}
{{- $stmts := include "s3monitor.listStatements" (list (printf "%sList" $sid) $arn $prefix) | fromJsonArray -}}
{{- $stmts = append $stmts (dict "Sid" (printf "%sRead" $sid) "Effect" "Allow" "Action" (list "s3:GetObject") "Resource" (list (printf "%s/%s*" $arn $prefix))) -}}
{{- if $t.kms_key_arn -}}
{{- $stmts = append $stmts (dict "Sid" (printf "%sKms" $sid) "Effect" "Allow" "Action" (list "kms:Decrypt" "kms:DescribeKey") "Resource" (list $t.kms_key_arn)) -}}
{{- end -}}
{{- toJson $stmts -}}
{{- end -}}

{{/*
Pack statements into IAM managed policies: one "base" policy plus tenant policies holding
.Values.iam.tenantsPerPolicy tenants each. Input: (list $ roleName baseStatements
perTenantStatementLists). Output: JSON list of {"suffix", "document"}. Fails if a document is
over IAM's 6,144-character limit or the role would need more than 10 attached policies.
*/}}
{{- define "s3monitor.packPolicies" -}}
{{- $root := index . 0 -}}{{- $role := index . 1 -}}{{- $base := index . 2 -}}{{- $perTenant := index . 3 -}}
{{- $policies := list -}}
{{- if $base -}}
{{- $policies = append $policies (dict "suffix" "base" "document" (dict "Version" "2012-10-17" "Statement" $base)) -}}
{{- end -}}
{{- range $n, $group := chunk (int $root.Values.iam.tenantsPerPolicy) $perTenant -}}
{{- $stmts := list -}}
{{- range $group }}{{ $stmts = concat $stmts . }}{{ end -}}
{{- $policies = append $policies (dict "suffix" (printf "tenants-%d" (add1 $n)) "document" (dict "Version" "2012-10-17" "Statement" $stmts)) -}}
{{- end -}}
{{- include "s3monitor.checkPolicies" (list $role $policies) -}}
{{- toJson $policies -}}
{{- end -}}

{{- define "s3monitor.cronjobPolicies" -}}
{{- $perTenant := list -}}
{{- range $t := (include "s3monitor.activeTenants" . | fromJsonArray) -}}
{{- $perTenant = append $perTenant (include "s3monitor.cronjobTenantStatements" (list $ $t) | fromJsonArray) -}}
{{- end -}}
{{- include "s3monitor.packPolicies" (list . (include "s3monitor.roleName" .) (include "s3monitor.cronjobBaseStatements" . | fromJsonArray) $perTenant) -}}
{{- end -}}

{{- define "s3monitor.checkPolicies" -}}
{{- $role := index . 0 -}}{{- $policies := index . 1 -}}
{{- if gt (len $policies) 10 -}}
{{- fail (printf "s3-monitor: role %s would need %d attached policies (IAM default quota 10). Raise iam.tenantsPerPolicy (if policies stay under 6,144 characters) or split tenants across environments." $role (len $policies)) -}}
{{- end -}}
{{- range $policies -}}
{{- $size := len (toJson .document) -}}
{{- if gt $size 6144 -}}
{{- fail (printf "s3-monitor: IAM policy %s-%s is %d characters (IAM limit 6144). Lower iam.tenantsPerPolicy." $role .suffix $size) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* ---------- Validation ---------- */}}
{{- define "s3monitor.validate" -}}
{{- $v := .Values -}}
{{- $c := $v.config -}}
{{- $global := include "s3monitor.global" . | fromJson -}}
{{- if not (get $global "environment") }}{{ fail "s3-monitor: global.environment is required" }}{{ end -}}
{{- if not (regexMatch "^[0-9]{12}$" (include "s3monitor.accountId" .)) -}}
{{- fail (printf "s3-monitor: global.crossplane.accountId must be a 12-digit AWS account id (quote it in values), got %q" (include "s3monitor.accountId" .)) -}}
{{- end -}}
{{- if not $v.eksClusterName }}{{ fail "eksClusterName is required" }}{{ end -}}
{{- if not $c.lake.bucket }}{{ fail "config.lake.bucket is required" }}{{ end -}}
{{- if not $c.lake.prefix }}{{ fail "config.lake.prefix is required" }}{{ end -}}
{{- if not $c.mq.stompEndpoints }}{{ fail "config.mq.stompEndpoints needs at least one stomp+ssl:// endpoint" }}{{ end -}}
{{- if not $c.mq.secretArn }}{{ fail "config.mq.secretArn is required" }}{{ end -}}
{{- if not (regexMatch "^https://sqs\\.[a-z0-9-]+\\.amazonaws\\.com/[0-9]{12}/[A-Za-z0-9_-]+$" ($c.sqs.queueUrl | default "")) }}{{ fail "config.sqs.queueUrl must be an SQS queue URL: https://sqs.<region>.amazonaws.com/<account>/<name>" }}{{ end -}}
{{- if not $c.tenants }}{{ fail "config.tenants must list at least one tenant" }}{{ end -}}
{{- range $i, $t := $c.tenants -}}
{{- if not (and $t.id $t.existing_bucket_name) }}{{ fail (printf "config.tenants[%d] needs id and existing_bucket_name" $i) }}{{ end -}}
{{- end -}}
{{- if $v.image.digest -}}
{{- if not (regexMatch "^sha256:[0-9a-f]{64}$" $v.image.digest) }}{{ fail "image.digest must be sha256:<64 hex chars>" }}{{ end -}}
{{- end -}}
{{- if include "s3monitor.crossplaneEnabled" . -}}
{{- if not (include "s3monitor.oidcProviderUrl" .) }}{{ fail "s3-monitor: global.crossplane.oidcProviderUrl is required" }}{{ end -}}
{{- if gt (len (include "s3monitor.roleName" .)) 64 }}{{ fail (printf "s3-monitor: role name %q is longer than 64 characters; shorten global.environment or the namespace" (include "s3monitor.roleName" .)) }}{{ end -}}
{{- end -}}
{{- end -}}

{{/* Pod template shared by the CronJob and the backfill Job: (list $ overrides), overrides = nil or {command, args}. */}}
{{- define "s3monitor.podTemplate" -}}
{{- $root := index . 0 -}}{{- $o := index . 1 -}}
{{- $v := $root.Values -}}
metadata:
  labels:
    {{- include "s3monitor.labels" $root | nindent 4 }}
  annotations:
    checksum/config: {{ include "s3monitor.configJson" $root | sha256sum }}
spec:
  serviceAccountName: {{ $v.serviceAccount.name }}
  restartPolicy: {{ if $o }}Never{{ else }}OnFailure{{ end }}
  {{- with $v.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: s3-monitor
      image: {{ include "s3monitor.image" $root | quote }}
      imagePullPolicy: {{ $v.image.pullPolicy }}
      {{- if $o }}
      command: {{ toJson $o.command }}
      args: {{ toJson $o.args }}
      {{- end }}
      env:
        - name: CONFIG_URI
          value: /config/config.json
        - name: AWS_REGION
          value: {{ $v.aws.region | quote }}
        - name: TMPDIR
          value: /tmp
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
      volumeMounts:
        - name: config
          mountPath: /config
          readOnly: true
        - name: tmp
          mountPath: /tmp
      resources:
        {{- toYaml $v.resources | nindent 8 }}
  volumes:
    - name: config
      configMap:
        name: {{ include "s3monitor.fullname" $root }}-config
    - name: tmp
      emptyDir: {}
{{- end -}}
