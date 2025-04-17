{{/*
    Gen3 Chart Labels
    Will use the parent chart's chart, release, and version as well as the values "release", "criticalService", and "partOf" defined in the values.yaml file. 
    These values can be completely overwritten with the "selectorLabels" and "commonLabels" provided in the parent chart's values.yaml file. 
    "selectorLabels" are mainly used for the matchLabels and pod labels in the deployment. 
    "commonLabels" are mainly used for the deployment's labels. 
*/}}

{{- define "common.commonLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/part-of: {{ .Values.partOf }}
app.kubernetes.io/managed-by: "Helm"
app: {{ .Chart.Name }}
{{- if eq .Values.criticalService "true"}}
critical-service: "true"
{{- else }}
critical-service: "false"
{{- end }}
{{- if eq .Values.release "production"}}
release: "production"
{{- else }}
release: "dev"
{{- end }}
{{- end }}

{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Chart.Name }}
{{- if eq .Values.release "production"}}
release: "production"
{{- else }}
release: "dev"
{{- end }}
{{- end }}

{{- define "common.extraLabels" -}}
hostname: {{ .Values.global.hostname }}
{{- if .Values.extraLabels }}
    {{- with .Values.extraLabels }}
    {{- toYaml . }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "common.grafanaAnnotations" -}}
prometheus.io/path: /metrics
prometheus.io/scrape: "true"
{{- end }}