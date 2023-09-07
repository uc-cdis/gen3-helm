{{/*
  Service DB Creds Secrets Manager Name
*/}}
{{- define "common.externalSecret.dbcreds.name" -}}
{{- if .Values.externalSecrets.dbcreds }}
  {{- default .Values.externalSecrets.dbcreds }}
{{- else }}
  {{- .Values.global.environment }}- {{- .Chart.Name }}-creds
{{- end -}}
{{- end -}}


{{/*
    ExternalSecrets Object
*/}}
{{- define "common.externalSecret.db" -}}
{{ if .Values.global.externalSecrets.deploy }}
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: {{include "cluster-secret-store" .}}
    kind: ClusterSecretStore
  target:
    name: {{ $.Chart.Name }}-dbcreds
    creationPolicy: Owner
  dataFrom:
  - extract:
      key: {{include "common.externalSecret.dbcreds.name" .}}
      conversionStrategy: Default
      decodingStrategy: None
{{- end }}
{{- end -}}
