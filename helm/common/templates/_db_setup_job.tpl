# DB Setup ServiceAccount
# Needs to update/ create secrets to signal that db is ready for use.
{{- define "common.db_setup_sa" -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Chart.Name }}-dbcreate-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ .Chart.Name }}-dbcreate-role
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ .Chart.Name }}-dbcreate-rolebinding
subjects:
- kind: ServiceAccount
  name: {{ .Chart.Name }}-dbcreate-sa
  namespace: {{ .Release.Namespace }}
roleRef:
  kind: Role
  name: {{ .Chart.Name }}-dbcreate-role
  apiGroup: rbac.authorization.k8s.io
{{- end }}

# DB Setup Job
{{- define "common.db_setup_job" -}}
{{- if or $.Values.global.postgres.dbCreate $.Values.postgres.dbCreate }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-dbcreate
spec:
  template:
    metadata:
      labels:
      # TODO : READ FROM CENTRAL FUNCTION TOO?
        app: gen3job
    spec:
      serviceAccountName: {{ .Chart.Name }}-dbcreate-sa
      restartPolicy: Never
      containers:
      - name: db-setup
        # TODO: READ THIS IMAGE FROM GLOBAL VALUES?
        image: quay.io/cdis/awshelper:master
        imagePullPolicy: Always
        command: ["/bin/bash", "-c"]
        env:
          - name: PGPASSWORD
            {{- if $.Values.global.dev }}
            valueFrom:
              secretKeyRef:
                name: {{ .Values.postgres.host | default (printf "%s-postgresql" .Release.Name) }}
                key: postgres-password
                optional: false
            {{- else if $.Values.global.postgres.externalSecret }}
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.global.postgres.externalSecret }}
                key: password
                optional: false
            {{- else }}
            value: {{ .Values.global.postgres.master.password | quote }}
            {{- end }}
          - name: PGUSER
          {{- if $.Values.global.postgres.externalSecret }}
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.global.postgres.externalSecret }}
                key: username
                optional: false
          {{- else }}
            value: {{ .Values.global.postgres.master.username | quote }}
          {{- end }}
          - name: PGPORT
          {{- if $.Values.global.postgres.externalSecret }}
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.global.postgres.externalSecret }}
                key: port
                optional: false
          {{- else }}
            value: {{ .Values.global.postgres.master.port | quote }}
          {{- end }}
          - name: PGHOST
            {{- if $.Values.global.dev }}
            value: {{ .Values.postgres.host | default (printf "%s-postgresql" .Release.Name) }}
            {{- else if $.Values.global.postgres.externalSecret }}
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.global.postgres.externalSecret }}
                key: host
                optional: false
            {{- else }}
            value: {{ .Values.global.postgres.master.host | quote }}
            {{- end }}
          - name: SERVICE_PGUSER
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: username
                optional: false
          - name: SERVICE_PGDB
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: database
                optional: false
          - name: SERVICE_PGPASS
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: password
                optional: false
          - name: GEN3_HOME
            value: /home/ubuntu/cloud-automation
        args:
          - |
            #!/bin/bash
            set -e

            source "${GEN3_HOME}/gen3/lib/utils.sh"
            gen3_load "gen3/gen3setup"

            echo "PGHOST=$PGHOST"
            echo "PGPORT=$PGPORT"
            echo "PGUSER=$PGUSER"

            echo "SERVICE_PGDB=$SERVICE_PGDB"
            echo "SERVICE_PGUSER=$SERVICE_PGUSER"

            until pg_isready -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -d template1
            do
              >&2 echo "Postgres is unavailable - sleeping"
              sleep 5
            done
            >&2 echo "Postgres is up - executing command"

            if psql -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB; then
              gen3_log_info "Database exists"
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"

              # Update secret to signal that db is ready, and services can start
              kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'
            else
              echo "database does not exist"
              psql -tc "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1 || psql -c "CREATE DATABASE \"$SERVICE_PGDB\";"
              gen3_log_info psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS';"
              psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS';"
              psql -c "GRANT ALL ON DATABASE \"$SERVICE_PGDB\" TO \"$SERVICE_PGUSER\" WITH GRANT OPTION;"
              psql -d $SERVICE_PGDB -c "CREATE EXTENSION ltree; ALTER ROLE \"$SERVICE_PGUSER\" WITH LOGIN"
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"

              # Update secret to signal that db has been created, and services can start
              kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'
            fi
{{- end }}
{{- end }}


{{/*
Create k8s secrets for connecting to postgres
*/}}
# DB Secrets
{{- define "common.db-secret" -}}
{{- if or (not .Values.global.externalSecrets.deploy) (and .Values.global.externalSecrets.deploy .Values.global.externalSecrets.createLocalK8sSecret) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
  labels:
    app: gen3-created-by-hook
data:
  {{- $existingSecret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-dbcreds" .Chart.Name)) }}
  {{- if $existingSecret }}
    database: {{ index $existingSecret.data "database" | quote }}
    username: {{ index $existingSecret.data "username" | quote }}
    port: {{ index $existingSecret.data "port" | quote }}
    password: {{ index $existingSecret.data "password" | quote }}
    host: {{ index $existingSecret.data "host" | quote }}
    {{- if index $existingSecret.data "dbcreated" }}
    dbcreated: {{ index $existingSecret.data "dbcreated" | quote }}
    {{- end }}
  {{- else }}
    database: {{ ( $.Values.postgres.database | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote }}
    username: {{ ( $.Values.postgres.username | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote }}
    port: {{ $.Values.postgres.port | b64enc | quote }}
    password: {{ include "gen3.service-postgres" (dict "key" "password" "service" $.Chart.Name "context" $) | b64enc | quote }}
    {{- if $.Values.global.dev }}
    host: {{ ($.Values.postgres.host | default (printf "%s-%s" $.Release.Name "postgresql") ) | b64enc | quote }}
    {{- else }}
    host: {{ ( $.Values.postgres.host | default ( $.Values.global.postgres.master.host)) | b64enc | quote }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
  Bootstrap Secret for PushSecret to populate External Secret
*/}}
{{- define "common.secret.db.bootstrap" -}}
{{- if and $.Values.global.externalSecrets.deploy (or $.Values.global.externalSecrets.pushSecret .Values.externalSecrets.pushSecret) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $.Chart.Name }}-dbcreds-bootstrap
  labels:
    app.kubernetes.io/name: {{ $.Chart.Name }}
type: Opaque
data:
  database: {{ ( $.Values.postgres.database | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote}}
  username: {{ ( $.Values.postgres.username | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote}}
  port: {{ $.Values.postgres.port | b64enc | quote }}
  password: {{ include "gen3.service-postgres" (dict "key" "password" "service" $.Chart.Name "context" $) | b64enc | quote }}
  {{- if $.Values.global.dev }}
  host: {{ (printf "%s-%s" $.Release.Name "postgresql" ) | b64enc | quote }}
  {{- else }}
  host: {{ ( $.Values.postgres.host | default ( $.Values.global.postgres.master.host)) | b64enc | quote }}
  {{- end }}
  dbcreated: {{ "true" | b64enc | quote }}
{{- end }}
{{- end -}}


{{- define "common.db-push-secret" -}}
{{- if and $.Values.global.externalSecrets.deploy (or $.Values.global.externalSecrets.pushSecret .Values.externalSecrets.pushSecret) }}
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
spec:
  updatePolicy: IfNotExists
  refreshInterval: 2m
  secretStoreRefs:
    {{- if ne .Values.global.externalSecrets.clusterSecretStoreRef "" }}
    - name: {{ .Values.global.externalSecrets.clusterSecretStoreRef }}
      kind: ClusterSecretStore
    {{- else }}
    - name: {{include "common.SecretStore" .}}
      kind: SecretStore
    {{- end }}
  selector:
    secret:
      name: {{ $.Chart.Name }}-dbcreds-bootstrap
  data:
    - match:
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
{{- end }}
{{- end -}}
