{{/*
  Google Credentials Secrets Manager Name
*/}}
{{- define "google-creds-secret" -}}
{{- default "google-creds-secret" .Values.externalSecrets.googleCredsSecret }}
{{- end }}

{{/*
  DCF Dataservice Settings Secrets Manager Name
*/}}
{{- define "dcf-dataservice-settings-secret" -}}
{{- default "dcf-dataservice-settings-secret" .Values.externalSecrets.dcfDataserviceSettingsSecret }}
{{- end }}

{{/*
  DCF Dataservice JSON Secrets Manager Name
*/}}
{{- define "dcf-dataservice-json-secret" -}}
{{- default "dcf-dataservice-json-secret" .Values.externalSecrets.dcfDataserviceJSONSecret }}
{{- end }}

