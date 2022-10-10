{{/*
Expand the name of the chart.
*/}}
{{- define "guppy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "guppy.fullname" -}}
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
{{- define "guppy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guppy.labels" -}}
helm.sh/chart: {{ include "guppy.chart" . }}
{{ include "guppy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guppy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guppy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "guppy.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "guppy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guppy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define tierAccessLevel
*/}}
{{- define "guppy.tierAccessLevel" -}}
{{- if .Values.global }}
{{- .Values.global.tierAccessLevel }}
{{- else}}
{{- .Values.tierAccessLevel }}
{{- end }}
{{- end }}

{{/*
Define ddEnabled
*/}}
{{- define "guppy.ddEnabled" -}}
{{- if .Values.global }}
{{- .Values.global.ddEnabled }}
{{- else}}
{{- .Values.dataDog.enabled }}
{{- end }}
{{- end }}