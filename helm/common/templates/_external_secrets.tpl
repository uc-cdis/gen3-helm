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
{{- if and .Values.global.externalSecrets.deploy (not .Values.global.externalSecrets.createLocalK8sSecret) }}
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: {{include "common.SecretStore" .}}
    kind: SecretStore
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


{{/*
  External Secrets Secret Store will allow all charts to allow for authentication to AWS Secrets Manager
*/}}
{{- define "common.secretstore" -}}
{{- if .Values.global.gcp.enabled }}
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: {{.Chart.Name}}-secret-store
spec:
  provider:
    gcpsm:
      projectID: {{ .Values.global.gcp.projectID | quote }}
      auth:
        workloadIdentity:
          serviceAccountRef:
            name: gcp-secret-store-sa
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gcp-secret-store-sa
  annotations:
    iam.gke.io/gcp-service-account: {{ .Values.global.gcp.secretStoreServiceAccount | quote }}
{{- else }}
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: {{.Chart.Name}}-secret-store
spec:
  provider:
    aws:
      service: SecretsManager
      region: {{ .Values.global.aws.region | quote }}
      auth:
        {{- if .Values.global.aws.secretStoreServiceAccount.enabled }}
        jwt:
          serviceAccountRef:
            name: {{ .Values.global.aws.secretStoreServiceAccount.name }}
        {{- else }}
        secretRef:
          accessKeyIDSecretRef:
            name: {{.Chart.Name}}-aws-config
            key: access-key
          secretAccessKeySecretRef:
            name: {{.Chart.Name}}-aws-config
            key: secret-access-key
        {{- end}}
{{- end }}



{{/*
  #  Name of the SecretStore
  #  We want to allow override here, in case a chart is being deployed without the umbrella chart, 
  #  or any other needs to deploy a separate secret store per service.
*/}}

{{/*
  Cluster Secret Store for External Secrets
*/}}
{{- define "common.SecretStore" -}}
{{- if .Values.global.externalSecrets.separateSecretStore }}
  {{- .Chart.Name }}-secret-store
{{- else }}
{{- default "gen3-secret-store"}}
{{- end -}}
{{- end -}}
