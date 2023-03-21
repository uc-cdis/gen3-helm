{{/*
    Include DD
*/}}

{{- define "common.datadogLabels" -}}
tags.datadoghq.com/env: {{ .Values.environment }}
tags.datadoghq.com/service: {{ .Chart.Name }}
tags.datadoghq.com/version: {{ .Chart.Version }}
{{- end }}

{{- define "common.datadogEnvVar" -}}
- name: DD_ENV
valueFrom:
    fieldRef:
    fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_SERVICE
valueFrom:
    fieldRef:
    fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
valueFrom:
    fieldRef:
    fieldPath: metadata.labels['tags.datadoghq.com/version']
- name: DD_LOGS_INJECTION
value: "true"
- name: DD_PROFILING_ENABLED
value: "true"
- name: DD_TRACE_SAMPLE_RATE
value: "1"
- name: DD_AGENT_HOST
valueFrom:
    fieldRef:
    fieldPath: status.hostIP
{{- end }}