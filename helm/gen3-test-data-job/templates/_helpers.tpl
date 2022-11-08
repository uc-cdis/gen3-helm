{{/*
Expand the name of the chart.
*/}}
{{- define "gen3-test-data-job.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gen3-test-data-job.fullname" -}}
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
{{- define "gen3-test-data-job.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gen3-test-data-job.labels" -}}
helm.sh/chart: {{ include "gen3-test-data-job.chart" . }}
{{ include "gen3-test-data-job.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gen3-test-data-job.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gen3-test-data-job.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gen3-test-data-job.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gen3-test-data-job.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
NEEDS TO BE MODIFIED
Postgres Master Secret Lookup

Usage:
    {{ include "gen3.master-postgres" (dict "key" "database" "context" $) }}

 Lookups for secret is done in this order, until it finds a value:
  - Secret provided via `.Values.global.master.postgres` (Can be database, username, password, host, port)
  - Lookup secret `postgres-postgresql` with property `postgres-password` in `postgres` namespace. (This is for develop installation of gen3)
 

 # https://helm.sh/docs/chart_template_guide/function_list/#coalesce
*/}}
{{- define "gen3.master-postgres2" }}
  {{- $chartName := default "" .context.Chart.Name }}
  
  {{- $valuesPostgres := get .context.Values.global.postgres.master .key}}
  {{- $secret :=  (lookup "v1" "Secret" "postgres" "postgres-postgresql" )}}
  {{- $devPostgresSecret := "" }}
  {{-  if $secret }}
    {{- $devPostgresSecret = (index $secret.data "postgres-password") | b64dec }}
  {{- end }}
  {{- $value := coalesce $valuesPostgres $devPostgresSecret  }}
  {{- printf "%v" $value -}}
{{- end }}