{{/*
    Credentials for all AWS stuff.
*/}}
{{ define "common.awsconfig" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{.Chart.Name}}-aws-config
type: Opaque
stringData:
  credentials: |
    [default]
        aws_access_key_id={{ .Values.secrets.awsAccessKeyId | default .Values.global.aws.awsAccessKeyId}}
        aws_secret_access_key={{ .Values.secrets.awsSecretAccessKey | default .Values.global.aws.awsSecretAccessKey}}
data:
  access-key: {{ .Values.secrets.awsAccessKeyId | default .Values.global.aws.awsAccessKeyId | b64enc }}
  secret-access-key: {{ .Values.secrets.awsSecretAccessKey | default .Values.global.aws.awsSecretAccessKey | b64enc }}
{{- end }}