{{/* 
    Gen3 HorizontalPodAutoscaler
    HPA will allow pods to scale up and down based on usage or other metrics
    Will use parent chart's name
*/}}
{{ define "common.horizontal_pod_autoscaler" -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Chart.Name }}-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include (printf "%s.fullname" .Chart.Name )}}
  maxReplicas: 1
  minReplicas: 1
  metrics:
    - resource:
        name: cpu
        target:
          averageUtilization: 40
          type: Utilization
{{- end }}