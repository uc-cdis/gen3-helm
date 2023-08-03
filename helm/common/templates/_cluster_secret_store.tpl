{{/*
    External Secrets Secret Store will allow all charts to allow for authentication to AWS Secrets Manager
*/}}
{{ define "common.secretstore" -}}
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: {{.Chart.Name}}-secret-store
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: {{.Chart.Name}}-aws-config
            key: access-key
            namespace: default
          secretAccessKeySecretRef:
            name: {{.Chart.Name}}-aws-config
            key: secret-access-key
            namespace: default
{{- end }}