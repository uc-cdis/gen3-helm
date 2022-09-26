{{/*
Expand the name of the chart.
*/}}
{{- define "requestor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "requestor.fullname" -}}
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
{{- define "requestor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "requestor.labels" -}}
helm.sh/chart: {{ include "requestor.chart" . }}
{{ include "requestor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "requestor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "requestor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "requestor.name" . }}
release: {{ .Values.releaseLabel }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "requestor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "requestor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define ddEnabled
*/}}
{{- define "requestor.ddEnabled" -}}
{{- if .Values.global }}
{{- .Values.global.ddEnabled }}
{{- else}}
{{- .Values.dataDog.enabled }}
{{- end }}
{{- end }}