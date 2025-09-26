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
  AWS Credentials Secrets Manager Name
*/}}
{{- define "external-secrets.awsCredsSecretName" -}}
{{- if .Values.externalSecrets.awsCredsSecret -}}
{{- .Values.externalSecrets.awsCredsSecret -}}
{{- else -}}
aws-creds-secret
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
  AWS Credentials Secrets Manager Name
*/}}
{{- define "external-secrets.dcfAwsCredsSecretName" -}}
{{- if .Values.externalSecrets.dcfAwsCredsSecret -}}
{{- .Values.externalSecrets.dcfAwsCredsSecret -}}
{{- else -}}
aws-creds-secret
{{- end -}}
{{- end -}}