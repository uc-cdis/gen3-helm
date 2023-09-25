{{/*
Expand the name of the chart.
*/}}
{{- define "peregrine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "peregrine.fullname" -}}
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
{{- define "peregrine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "peregrine.labels" -}}
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
{{- define "peregrine.selectorLabels" -}}
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
{{- define "peregrine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "peregrine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
 Postgres Password lookup
*/}}
{{- define "peregrine.postgres.password" -}}
{{- $masterpass := (lookup "v1" "Secret" "postgres" "postgres-postgresql" ) -}}
# {{- $localpass := (lookup "v1" "Secret" .Release.Namespace "{{ .Chart.Name }}-dbcreds" ) -}}
{{- if $localpass }}
{{- default (index $masterpass.data "postgres-password" | b64dec) }}
{{- else }}
{{- default .Values.postgres.password }}
{{- end }}
{{- end }}

{{/*
Define dictionaryUrl
*/}}
{{- define "peregrine.dictionaryUrl" -}}
{{- if .Values.global }}
{{- .Values.global.dictionaryUrl }}
{{- else}}
{{- .Values.dictionaryUrl }}
{{- end }}
{{- end }}
