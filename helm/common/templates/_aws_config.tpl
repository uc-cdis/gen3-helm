{{/*
    Credentials for all AWS stuff.
*/}}
{{ define "common.awsconfig" -}}
{{- if not .Values.global.aws.externalSecrets.enabled }}
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
{{- else }}
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{.Chart.Name}}-aws-config
spec:
  secretStoreRef:
  {{- if ne .Values.global.externalSecrets.clusterSecretStoreRef  "" }}
    name: {{ .Values.global.externalSecrets.clusterSecretStoreRef }}
    kind: ClusterSecretStore
  {{- else }}
    name: {{include "common.SecretStore" .}}
    kind: SecretStore
  {{- end  }}
  target:
    name: {{.Chart.Name}}-aws-config
    creationPolicy: Owner
    template:
      type: Opaque
  data:
    - secretKey: access-key
      remoteRef:
        key: {{ .Values.global.aws.externalSecrets.externalSecretAwsCreds }}
        property: access-key
    - secretKey: secret-access-key
      remoteRef:
        key: {{ .Values.global.aws.externalSecrets.externalSecretAwsCreds }}
        property: secret-access-key
    - secretKey: credentials
      remoteRef:
        key: {{ .Values.global.aws.externalSecrets.externalSecretAwsCreds }}
        property: credentials
{{- end }}
{{- end }}