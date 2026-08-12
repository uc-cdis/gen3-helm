{{- define "s3-monitor.fullname" -}}
s3-monitor
{{- end -}}

{{- define "s3-monitor.labels" -}}
app: s3-monitor
app.kubernetes.io/name: s3-monitor
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
