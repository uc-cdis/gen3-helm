{{/*
    Gen3 Pod Disruption Budgets
    Pdb will help increase availability by ensuring that one pod for each service is always avialable. 
    Will use the parent chart's name.
*/}}
{{ define "common.pod_disruption_budget" -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ .Chart.Name }}-pdb
spec:
  minAvailable: {{ .Values.global.minAvialable }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
{{- end }}