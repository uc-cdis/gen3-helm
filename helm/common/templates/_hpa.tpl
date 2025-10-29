{{- define "common.hpa" -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{.Chart.Name}}-hpa
  labels:
    {{- include "arborist.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{.Chart.Name}}-deployment
  minReplicas: {{ default .Values.global.autoscaling.minReplicas .Values.autoscaling.minReplicas }}
  maxReplicas: {{ default .Values.global.autoscaling.maxReplicas .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if default .Values.global.autoscaling.averageCPUValue .Values.autoscaling.averageCPUValue }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: AverageValue
        averageValue: {{ default .Values.global.autoscaling.averageCPUValue .Values.autoscaling.averageCPUValue }}
    {{- end }}
    {{- if default .Values.global.autoscaling.averageMemoryValue .Values.autoscaling.averageMemoryValue }}
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: {{ default .Values.global.autoscaling.averageMemoryValue .Values.autoscaling.averageMemoryValue }}
    {{- end }}
{{- end }}