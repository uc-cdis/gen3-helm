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
                name: {{ .Release.Name }}-postgresql
                key: postgres-password
                optional: false
            {{- else }}
           # Store secrets in cloud vaults or aws secrets manager for environments other than dev
           # value:  {{ .Values.global.postgres.master.password | quote}}
            valueFrom:
              secretKeyRef:
                name: postgresql-secret
                key: postgres-password
                optional: false            
            {{- end }}
          - name: PGUSER
            #value: {{ .Values.global.postgres.master.username | quote }}
            valueFrom:
              secretKeyRef:
                name: postgresql-secret
                key: postgres-username
                optional: false            
          - name: PGPORT
            {{- if $.Values.global.dev }}
            value: {{ .Values.global.postgres.master.port | quote }}
            {{- else }}
            valueFrom:
              secretKeyRef:
                name: postgresql-secret
                key: postgres-port
                optional: false            
            {{- end }}
          - name: PGHOST
            {{- if $.Values.global.dev }}
            value: "{{ .Release.Name }}-postgresql"
            {{- else }}
            #value: {{ .Values.global.postgres.master.host | quote }}
            valueFrom:
              secretKeyRef:
                name: postgresql-secret
                key: postgres-host
                optional: false            
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


{{/* 
Create k8s secrets for connecting to postgres 
*/}}
# DB Secrets
{{- define "common.db-secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
data:
{{- if $.Values.global.postgres.cloudsecrets.enabled }}
  {{ $secret := ( lookup "v1" "Secret" .Release.Namespace  "postgresql-secret"  ) }}
  database: {{  index $secret.data "database" | b64enc | quote}}
  username: {{  index $secret.data "username" | b64enc | quote}}
  port: {{  index $secret.data "port" | b64enc | quote}}
  password: {{  index $secret.data "password" | b64enc | quote}}
  host: {{  index $secret.data "host" | b64enc | quote}}
{{- else }}
  database: {{ ( $.Values.postgres.database | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote}}
  username: {{ ( $.Values.postgres.username | default (printf "%s_%s" $.Chart.Name $.Release.Name)  ) | b64enc | quote}}
  port: {{ $.Values.postgres.port | b64enc | quote }}
  password: {{ include "gen3.service-postgres" (dict "key" "password" "service" $.Chart.Name "context" $) | b64enc | quote }}
  {{- if $.Values.global.dev }}
  host: {{ (printf "%s-%s" $.Release.Name "postgresql" ) | b64enc | quote }}
  {{- else }}
  host: {{ ( $.Values.postgres.host | default ( $.Values.global.postgres.master.host)) | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end}}