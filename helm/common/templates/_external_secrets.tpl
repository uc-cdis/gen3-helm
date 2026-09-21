{{/*
Service DB Creds Secrets Manager Name
*/}}
{{- define "common.externalSecret.dbcreds.name" -}}
{{- if .Values.externalSecrets.dbcreds }}
{{- .Values.externalSecrets.dbcreds }}
{{- else }}
{{- .Values.global.environment }}-{{ .Chart.Name }}-creds
{{- end -}}
{{- end -}}

{{/*
External Secrets API version.
Keep the existing default for backwards compatibility.
*/}}
{{- define "common.externalSecrets.apiVersion" -}}
{{- default "external-secrets.io/v1beta1" .Values.global.externalSecrets.apiVersion -}}
{{- end -}}

{{/*
SecretStore kind.

Supported values:
  SecretStore
  ClusterSecretStore
*/}}
{{- define "common.SecretStore.kind" -}}
{{- $secretStore := dig "secretStore" (dict) .Values.global.externalSecrets -}}
{{- $kind := dig "kind" "SecretStore" $secretStore -}}
{{- if not (has $kind (list "SecretStore" "ClusterSecretStore")) -}}
{{- fail "global.externalSecrets.secretStore.kind must be either SecretStore or ClusterSecretStore" -}}
{{- end -}}
{{- $kind -}}
{{- end -}}

{{/*
Name of the SecretStore.

An explicitly configured name takes precedence.

Otherwise preserve existing behavior:
  separateSecretStore=true -> <chart>-secret-store
  separateSecretStore=false -> gen3-secret-store
*/}}
{{- define "common.SecretStore" -}}
{{- $secretStore := dig "secretStore" (dict) .Values.global.externalSecrets -}}
{{- $name := dig "name" "" $secretStore -}}

{{- if $name -}}
{{- $name -}}
{{- else if .Values.global.externalSecrets.separateSecretStore -}}
{{- .Chart.Name }}-secret-store
{{- else -}}
gen3-secret-store
{{- end -}}
{{- end -}}

{{/*
ExternalSecret Object
*/}}
{{- define "common.externalSecret.db" -}}
{{- if and .Values.global.externalSecrets.deploy (not .Values.global.externalSecrets.createLocalK8sSecret) }}
apiVersion: {{ include "common.externalSecrets.apiVersion" . }}
kind: ExternalSecret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: {{ include "common.SecretStore" . }}
    kind: {{ include "common.SecretStore.kind" . }}
  target:
    name: {{ $.Chart.Name }}-dbcreds
    creationPolicy: Owner
  dataFrom:
    - extract:
        key: {{ include "common.externalSecret.dbcreds.name" . }}
        conversionStrategy: Default
        decodingStrategy: None
{{- end }}
{{- end -}}

{{/*
External Secrets SecretStore.

Behavior:
  1. If global.externalSecrets.secretStore.spec is provided,
     render it verbatim.
  2. Otherwise, preserve the existing legacy GCP behavior when
     global.gcp.enabled=true.
  3. Otherwise, default to AWS Secrets Manager.

This makes AWS the default while allowing arbitrary ESO SecretStore
configurations such as Vault, Azure Key Vault, GCP Secret Manager,
Akeyless, etc.
*/}}
{{- define "common.secretstore" -}}

{{- $secretStore := dig "secretStore" (dict) .Values.global.externalSecrets -}}
{{- $create := dig "create" true $secretStore -}}
{{- $spec := dig "spec" (dict) $secretStore -}}
{{- $annotations := dig "annotations" (dict) $secretStore -}}
{{- $gcpEnabled := dig "gcp" "enabled" false .Values.global -}}

{{- if $create }}
apiVersion: {{ include "common.externalSecrets.apiVersion" . }}
kind: {{ include "common.SecretStore.kind" . }}
metadata:
  name: {{ include "common.SecretStore" . }}
{{- with $annotations }}
  annotations:
{{ toYaml . | nindent 4 }}
{{- end }}
spec:
{{- if $spec }}

{{/*
Generic SecretStore configuration.
*/}}
{{ toYaml $spec | nindent 2 }}

{{- else if $gcpEnabled }}

{{/*
Legacy GCP configuration.

Keep this temporarily for backwards compatibility with existing
Gen3 deployments. New deployments can use secretStore.spec instead.
*/}}
  provider:
    gcpsm:
      projectID: {{ .Values.global.gcp.projectID | quote }}
      auth:
        workloadIdentity:
          serviceAccountRef:
            name: gcp-secret-store-sa

{{- else }}

{{/*
AWS Secrets Manager is the default SecretStore.
*/}}
  provider:
    aws:
      service: SecretsManager
      region: {{ .Values.global.aws.region | quote }}
      auth:
{{- if .Values.global.aws.secretStoreServiceAccount.enabled }}
        jwt:
          serviceAccountRef:
            name: {{ .Values.global.aws.secretStoreServiceAccount.name }}
{{- else }}
        secretRef:
          accessKeyIDSecretRef:
            name: {{ .Chart.Name }}-aws-config
            key: access-key
          secretAccessKeySecretRef:
            name: {{ .Chart.Name }}-aws-config
            key: secret-access-key
{{- end }}

{{- end }}

{{/*
The GCP ServiceAccount is only needed by the legacy GCP configuration.
Generic secretStore.spec users are responsible for defining whatever
provider-specific authentication resources they require.
*/}}
{{- if and (not $spec) $gcpEnabled }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gcp-secret-store-sa
  annotations:
    iam.gke.io/gcp-service-account: {{ .Values.global.gcp.secretStoreServiceAccount | quote }}
{{- end }}

{{- end }}
{{- end -}}