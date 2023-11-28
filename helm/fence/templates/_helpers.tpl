{{/*
Expand the name of the chart.
*/}}
{{- define "fence.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
a function to generate or get the jwt keys
*/}}

{{- define "getOrCreatePrivateKey" -}}
{{- $secretName := "fence-jwt-keys" }}
{{- $existingSecret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if $existingSecret }}
{{- index $existingSecret.data "jwt_private_key.pem" }}
{{- else }}
{{- genPrivateKey "rsa" | b64enc }}
{{- end }}
{{- end -}}



{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fence.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fence.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fence.labels" -}}
{{- if .Values.commonLabels }}
    {{- with .Values.commonLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.commonLabels" .)}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fence.selectorLabels" -}}
{{- if .Values.selectorLabels }}
    {{- with .Values.selectorLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.selectorLabels" .)}}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fence.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fence.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
 Postgres Password lookup
*/}}
{{- define "fence.postgres.password" -}}
{{- $localpass := (lookup "v1" "Secret" "postgres" "postgres-postgresql" ) -}}
{{- if $localpass }}
{{- default (index $localpass.data "postgres-password" | b64dec) }}
{{- else }}
{{- default .Values.postgres.password }}
{{- end }}
{{- end }}


{{/*
  Fence JWT Keys Secrets Manager Name
*/}}
{{- define "fence-jwt-keys" -}}
{{- default "fence-jwt-keys" .Values.externalSecrets.fenceJwtKeys }}
{{- end }}

{{/*
  Fence Google App Creds Secrets Manager Name
*/}}
{{- define "fence-google-app-creds-secret" -}}
{{- default "fence-google-app-creds-secret" .Values.externalSecrets.fenceGoogleAppCredsSecret }}
{{- end }}

{{/*
  Fence Google Storage Creds Secrets Manager Name
*/}}
{{- define "fence-google-storage-creds-secret" -}}
{{- default "fence-google-storage-creds-secret" .Values.externalSecrets.fenceGoogleStorageCredsSecret }}
{{- end }}

{{/*
  Fence Config Secrets Manager Name
*/}}
{{- define "fence-config" -}}
{{- default "fence-config" .Values.externalSecrets.fenceConfig }}
{{- end }}
