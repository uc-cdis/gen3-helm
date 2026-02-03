{{ define "common.serviceaccount" -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{- include "app.serviceAccountName" . | nindent 4 }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
