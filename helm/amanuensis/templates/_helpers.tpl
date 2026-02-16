{{/*
Expand the name of the chart.
*/}}
{{- define "amanuensis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "amanuensis.fullname" -}}
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
{{- define "amanuensis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "amanuensis.labels" -}}
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
{{- define "amanuensis.selectorLabels" -}}
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
{{- define "amanuensis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "amanuensis.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
 Postgres Password lookup
*/}}
{{- define "amanuensis.postgres.password" -}}
{{- $localpass := (lookup "v1" "Secret" "postgres" "postgres-postgresql" ) -}}
{{- if $localpass }}
{{- default (index $localpass.data "postgres-password" | b64dec) }}
{{- else }}
{{- default .Values.postgres.password }}
{{- end }}
{{- end }}


{{/*
  amanuensis Config Secrets Manager Name
*/}}
{{- define "amanuensis-config" -}}
{{- default "amanuensis-config" .Values.externalSecrets.amanuensisConfig }}
{{- end }}

{{/*
  amanuensis should config job run
*/}}
{{- define "amanuensis.shouldRunJob" -}}
{{- $existingSecretConfig := lookup "v1" "Secret" .Release.Namespace (printf "amanuensis-config") }}
{{- $existingSecretCreds := lookup "v1" "Secret" .Release.Namespace (printf "amanuensis-creds") }}
{{- if and 
  (and $existingSecretConfig $existingSecretConfig.data (hasKey $existingSecretConfig.data "amanuensis-config.yaml"))
  (and $existingSecretCreds $existingSecretCreds.data (hasKey $existingSecretCreds.data "creds.json")) 
}}
  false
{{- else }}
  true
{{- end }}
{{- end }}