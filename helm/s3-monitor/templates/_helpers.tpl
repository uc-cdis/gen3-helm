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

{{/* The setup ServiceAccount, role and Jobs exist only for the event recorder (or its one-off cleanup). */}}
{{- define "s3monitor.setupEnabled" -}}
{{- if and (include "s3monitor.crossplaneEnabled" .) (or .Values.eventRecorder.enabled .Values.eventRecorder.removeNotifications) }}true{{ end -}}
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

{{- define "s3monitor.setupRoleName" -}}
{{- printf "%s-%s" (include "s3monitor.base" .) .Values.setupServiceAccount.name -}}
{{- end -}}

{{- define "s3monitor.recorderName" -}}
{{- printf "%s-%s-recorder" (include "s3monitor.base" .) (include "s3monitor.fullname" .) -}}
{{- end -}}

{{- define "s3monitor.recorderRoleName" -}}
{{- include "s3monitor.recorderName" . -}}
{{- end -}}

{{- define "s3monitor.recorderLogGroup" -}}
{{- printf "/aws/lambda/%s" (include "s3monitor.recorderName" .) -}}
{{- end -}}

{{- define "s3monitor.ecrRepoName" -}}
{{- include "s3monitor.recorderName" . | lower -}}
{{- end -}}

{{- define "s3monitor.ecrRepoUri" -}}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s" (include "s3monitor.accountId" .) (include "s3monitor.region" .) (include "s3monitor.ecrRepoName" .) -}}
{{- end -}}

{{- define "s3monitor.recorderFunctionArn" -}}
{{- printf "arn:%s:lambda:%s:%s:function:%s" (include "s3monitor.partition" .) (include "s3monitor.region" .) (include "s3monitor.accountId" .) (include "s3monitor.recorderName" .) -}}
{{- end -}}

{{/* Id prefix of the bucket notification entries owned by this release. */}}
{{- define "s3monitor.notificationIdPrefix" -}}
{{- printf "%s-%s-" (include "s3monitor.fullname" .) (include "s3monitor.base" .) -}}
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

{{/* Tag of the Lambda's copy in ECR. Changes whenever the source image digest (or tag) changes. */}}
{{- define "s3monitor.recorderImageTag" -}}
{{- $i := .Values.image -}}
{{- $arch := .Values.eventRecorder.architecture -}}
{{- $safe := regexReplaceAll "[^A-Za-z0-9_.-]" (toString $i.tag) "_" | trunc 80 -}}
{{- if $i.digest -}}{{ printf "%s-%s-%s" $safe $arch (substr 7 19 $i.digest) }}{{- else -}}{{ printf "%s-%s" $safe $arch }}{{- end -}}
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

{{/* Tenants whose ObjectCreated events go to the recorder Lambda (mirrors config.py s3_event_tenants). */}}
{{- define "s3monitor.recorderTenants" -}}
{{- $out := list -}}
{{- if .Values.eventRecorder.enabled -}}
{{- range $i, $t := .Values.config.tenants -}}
{{- $ev := $t.s3_event | default dict -}}
{{- if and $ev.enabled (eq ($t.lifecycle | default "active") "active") -}}
{{- $out = append $out (merge (dict "_index" $i) $t) -}}
{{- end -}}
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
{{- $eks := dict "cluster_name" $v.eksClusterName "namespace" .Release.Namespace "service_account" $v.serviceAccount.name -}}
{{- $oidc := include "s3monitor.oidcProviderUrl" . -}}
{{- if $oidc }}{{ $_ := set $eks "oidc_provider_url" $oidc }}{{ end -}}
{{- $cfg := dict
    "name" (include "s3monitor.base" .)
    "account" (include "s3monitor.accountId" .)
    "region" (include "s3monitor.region" .)
    "apply" $c.apply
    "lookback_days" $c.lookbackDays
    "use_fips_aws_endpoints" $c.useFipsAwsEndpoints
    "eks" $eks
    "image" (dict "repository" $v.image.repository "tag" (toString $v.image.tag))
    "iam" (dict "role_name" (include "s3monitor.roleName" .))
    "lake" $lake
    "mq" $mq
    "s3_event_recorder" (dict "enabled" $v.eventRecorder.enabled "memory_size" $v.eventRecorder.memorySize "timeout_seconds" $v.eventRecorder.timeoutSeconds)
    "tenants" $c.tenants
-}}
{{- if $c.assumeRoleArn }}{{ $_ := set $cfg "assume_role_arn" $c.assumeRoleArn }}{{ end -}}
{{- toPrettyJson $cfg -}}
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
{{- $prefix := trimPrefix "/" ($t.scan_prefix | default "") -}}
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

{{/* Recorder Lambda execution role: its own log group, the lake, recorder tenants' objects. */}}
{{- define "s3monitor.recorderPolicies" -}}
{{- $p := include "s3monitor.partition" . -}}
{{- $lg := printf "arn:%s:logs:%s:%s:log-group:%s" $p (include "s3monitor.region" .) (include "s3monitor.accountId" .) (include "s3monitor.recorderLogGroup" .) -}}
{{- $base := list (dict "Sid" "Logs" "Effect" "Allow" "Action" (list "logs:CreateLogStream" "logs:PutLogEvents") "Resource" (list (printf "%s:*" $lg))) -}}
{{- $base = concat $base (include "s3monitor.lakeStatements" . | fromJsonArray) -}}
{{- $perTenant := list -}}
{{- range $t := (include "s3monitor.recorderTenants" . | fromJsonArray) -}}
{{- $sid := printf "T%v%s" $t._index (regexReplaceAll "[^A-Za-z0-9]" $t.id "") -}}
{{- $ev := $t.s3_event | default dict -}}
{{- $stmts := list (dict "Sid" (printf "%sRead" $sid) "Effect" "Allow" "Action" (list "s3:GetObject") "Resource" (list (printf "%s/%s*" (include "s3monitor.s3Arn" (list $p $t.existing_bucket_name)) (trimPrefix "/" ($ev.prefix | default ""))))) -}}
{{- if $t.kms_key_arn -}}
{{- $stmts = append $stmts (dict "Sid" (printf "%sKms" $sid) "Effect" "Allow" "Action" (list "kms:Decrypt" "kms:DescribeKey") "Resource" (list $t.kms_key_arn)) -}}
{{- end -}}
{{- $perTenant = append $perTenant $stmts -}}
{{- end -}}
{{- include "s3monitor.packPolicies" (list . (include "s3monitor.recorderRoleName" .) $base $perTenant) -}}
{{- end -}}

{{/* Setup Jobs' role: copy the image into ECR, manage tenant bucket notifications. */}}
{{- define "s3monitor.setupPolicies" -}}
{{- $p := include "s3monitor.partition" . -}}
{{- $base := list -}}
{{- if .Values.eventRecorder.enabled -}}
{{- $repo := printf "arn:%s:ecr:%s:%s:repository/%s" $p (include "s3monitor.region" .) (include "s3monitor.accountId" .) (include "s3monitor.ecrRepoName" .) -}}
{{- $base = append $base (dict "Sid" "EcrLogin" "Effect" "Allow" "Action" (list "ecr:GetAuthorizationToken") "Resource" (list "*")) -}}
{{- $base = append $base (dict "Sid" "EcrPushRecorderImage" "Effect" "Allow" "Action" (list "ecr:BatchCheckLayerAvailability" "ecr:BatchGetImage" "ecr:CompleteLayerUpload" "ecr:GetDownloadUrlForLayer" "ecr:InitiateLayerUpload" "ecr:PutImage" "ecr:UploadLayerPart") "Resource" (list $repo)) -}}
{{- end -}}
{{- $perTenant := list -}}
{{- range $t := (include "s3monitor.activeTenants" . | fromJsonArray) -}}
{{- $sid := printf "T%v%s" $t._index (regexReplaceAll "[^A-Za-z0-9]" $t.id "") -}}
{{- $perTenant = append $perTenant (list (dict "Sid" (printf "%sNotifications" $sid) "Effect" "Allow" "Action" (list "s3:GetBucketNotification" "s3:PutBucketNotification") "Resource" (list (include "s3monitor.s3Arn" (list $p $t.existing_bucket_name))))) -}}
{{- end -}}
{{- include "s3monitor.packPolicies" (list . (include "s3monitor.setupRoleName" .) $base $perTenant) -}}
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
{{- if not $c.tenants }}{{ fail "config.tenants must list at least one tenant" }}{{ end -}}
{{- range $i, $t := $c.tenants -}}
{{- if not (and $t.id $t.existing_bucket_name) }}{{ fail (printf "config.tenants[%d] needs id and existing_bucket_name" $i) }}{{ end -}}
{{- end -}}
{{- if $v.image.digest -}}
{{- if not (regexMatch "^sha256:[0-9a-f]{64}$" $v.image.digest) }}{{ fail "image.digest must be sha256:<64 hex chars>" }}{{ end -}}
{{- end -}}
{{- if not (has $v.eventRecorder.architecture (list "arm64" "amd64")) }}{{ fail "eventRecorder.architecture must be arm64 or amd64" }}{{ end -}}
{{- if include "s3monitor.crossplaneEnabled" . -}}
{{- if not (include "s3monitor.oidcProviderUrl" .) }}{{ fail "s3-monitor: global.crossplane.oidcProviderUrl is required" }}{{ end -}}
{{- range $n := list (include "s3monitor.roleName" .) (include "s3monitor.setupRoleName" .) (include "s3monitor.recorderName" .) -}}
{{- if gt (len $n) 64 }}{{ fail (printf "s3-monitor: AWS name %q is longer than 64 characters; shorten global.environment or the namespace" $n) }}{{ end -}}
{{- end -}}
{{- else if $v.eventRecorder.enabled -}}
{{- fail "s3-monitor: eventRecorder needs global.crossplane.enabled (the Lambda, its role and ECR repository are Crossplane resources)" -}}
{{- end -}}
{{- end -}}
