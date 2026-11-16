{{- define "healCronjobs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "healCronjobs.labels" -}}
app.kubernetes.io/name: {{ include "healCronjobs.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Name of the ConfigMap holding a job's script.
Usage: include "healCronjobs.scriptConfigMapName" (dict "name" $name)
*/}}
{{- define "healCronjobs.scriptConfigMapName" -}}
{{- printf "%s-script" .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Image for a job. Precedence: job.image > global.awshelper_container_image > chart default image.
Usage: include "healCronjobs.image" (dict "job" $job "root" $)
*/}}
{{- define "healCronjobs.image" -}}
{{- $job := .job -}}
{{- $root := .root -}}
{{- if and $job.image $job.image.repository -}}
{{- printf "%s:%s" $job.image.repository (default $root.Values.image.tag $job.image.tag) -}}
{{- else if $root.Values.global.awshelper_container_image -}}
{{- $root.Values.global.awshelper_container_image -}}
{{- else -}}
{{- printf "%s:%s" $root.Values.image.repository $root.Values.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "healCronjobs.pullPolicy" -}}
{{- if and .job.image .job.image.pullPolicy -}}
{{- .job.image.pullPolicy -}}
{{- else -}}
{{- .root.Values.image.pullPolicy -}}
{{- end -}}
{{- end -}}
