{{/*
  Google Credentials Secrets Manager Name
*/}}
{{- define "external-secrets.googleCredsSecretName" -}}
{{- if .Values.externalSecrets.googleCredsSecret -}}
{{- .Values.externalSecrets.googleCredsSecret -}}
{{- else -}}
google-creds-secret
{{- end -}}
{{- end -}}

{{/*
  DCF Dataservice Settings Secrets Manager Name
*/}}
{{- define "external-secrets.dcfDataserviceSettingsSecretName" -}}
{{- if .Values.externalSecrets.dcfDataserviceSettingsSecret -}}
{{- .Values.externalSecrets.dcfDataserviceSettingsSecret -}}
{{- else -}}
dcf-dataservice-settings-secrets
{{- end -}}
{{- end -}}

{{/*
  DCF Dataservice JSON Secrets Manager Name
*/}}
{{- define "dcf-dataservice-json-secret" -}}
{{- default "dcf-dataservice-json-secret" .Values.externalSecrets.dcfDataserviceJSONSecret }}
{{- end }}

