{{/*
    Datadog Labels and Environment variables that will be inserted into the deployment.yaml of any chart the sets ddEnabled to "true".
    Will use the parent chart's name and versionn as well as the values "environment", "datadogLogsInjection", "datadogProfilingEnabled", and "datadogTraceSampleRate" defined in the values.yaml file. 
*/}}

{{- define "common.datadogLabels" -}}
tags.datadoghq.com/env: {{ .Values.global.environment }}
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
  value: {{ .Values.datadogLogsInjection | quote }}
- name: DD_PROFILING_ENABLED
  value: {{ .Values.datadogProfilingEnabled | quote }}
- name: DD_TRACE_SAMPLE_RATE
  value: {{ .Values.datadogTraceSampleRate | quote }}
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
{{- end }}