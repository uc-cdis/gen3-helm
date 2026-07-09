{{/*
Expand the name of the chart.
*/}}
{{- define "funnel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "funnel.fullname" -}}
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
{{- define "funnel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "funnel.labels" -}}
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
{{- define "funnel.selectorLabels" -}}
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
{{- define "funnel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "funnel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
  Funnel g3 Auto Secrets Manager Name
*/}}
{{- define "funnel-g3auto" -}}
{{- default "funnel-g3auto" .Values.externalSecrets.funnelG3auto }}
{{- end }}


{{/*
  Funnel OIDC client Secrets Manager Name
*/}}
{{- define "funnel-oidc-client" -}}
{{- default "funnel-oidc-client" .Values.externalSecrets.funnelOidcClient }}
{{- end }}

{{/*
Parse a Go duration string (e.g. "10s", "90s", "5m", "1h") into whole seconds.
Only the s/m/h suffixes are supported; an unsuffixed value is treated as seconds.
Returns 0 when the input is empty or unparseable.
*/}}
{{- define "funnel.durationSeconds" -}}
{{- $d := . | toString | trim -}}
{{- $seconds := 0 -}}
{{- if hasSuffix "h" $d -}}
{{- $seconds = mul (trimSuffix "h" $d | int) 3600 -}}
{{- else if hasSuffix "m" $d -}}
{{- $seconds = mul (trimSuffix "m" $d | int) 60 -}}
{{- else if hasSuffix "s" $d -}}
{{- $seconds = trimSuffix "s" $d | int -}}
{{- else if $d -}}
{{- $seconds = $d | int -}}
{{- end -}}
{{- $seconds -}}
{{- end }}

{{/*
Derive the cleanup CronJob schedule from Kubernetes.ReconcileRate unless
cleanup.schedule is set explicitly.
*/}}
{{- define "funnel.cleanupSchedule" -}}
{{- if .Values.cleanup.schedule -}}
{{- .Values.cleanup.schedule -}}
{{- else -}}
{{- $seconds := include "funnel.durationSeconds" .Values.Kubernetes.ReconcileRate | int -}}
{{- $minutes := div (add $seconds 59) 60 -}}
{{- if lt $minutes 1 }}{{- $minutes = 1 -}}{{- end -}}
{{- $offset := .Values.cleanup.scheduleOffsetMinutes | default 0 | int -}}
{{- if and (le $minutes 59) (eq (mod 60 $minutes) 0) -}}
{{- printf "%d-59/%d * * * *" $offset $minutes -}}
{{- else if le $minutes 59 -}}
{{- printf "%d/%d * * * *" $offset $minutes -}}
{{- else -}}
{{- $hours := div (add $minutes 59) 60 -}}
{{- printf "%d */%d * * *" $offset $hours -}}
{{- end -}}
{{- end -}}
{{- end }}
