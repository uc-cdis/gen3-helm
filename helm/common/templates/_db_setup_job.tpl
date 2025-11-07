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
                name: {{ .Release.Name }}-postgresql
                key: postgres-password
                optional: false
            {{- else if $.Values.global.postgres.externalSecret }}
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.global.postgres.externalSecret }}
                key: password
                optional: false
            {{- else }}
            value:  {{ .Values.global.postgres.master.password | quote}}
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
            value: "{{ .Release.Name }}-postgresql"
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
          {{- if and (.Values.global.externalSecrets.deploy) (.Values.global.externalSecrets.dbCreate) (.Values.postgres.bootstrap) }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds-bootstrap
                key: username
                optional: false
          {{- else }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: username
                optional: false
          {{- end }}
          - name: SERVICE_PGDB
          {{- if and (.Values.global.externalSecrets.deploy) (.Values.global.externalSecrets.dbCreate) (.Values.postgres.bootstrap) }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds-bootstrap
                key: database
                optional: false
          {{- else }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: database
                optional: false
          {{- end }}
          - name: SERVICE_PGPASS
          {{- if and (.Values.global.externalSecrets.deploy) (.Values.global.externalSecrets.dbCreate) (.Values.postgres.bootstrap) }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: password
                optional: true
          - name: SERVICE_PGPASS_BOOTSTRAP
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds-bootstrap
                key: password
                optional: false
          {{- else }}
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: password
                optional: false
          {{- end }}
          - name: GEN3_HOME
            value: /home/ubuntu/cloud-automation
        args:
          - |
            #!/usr/bin/env bash
            set -euo pipefail

            echo "PGHOST=$PGHOST"
            echo "PGPORT=$PGPORT"
            echo "PGUSER=$PGUSER"
            echo "SERVICE_PGDB=$SERVICE_PGDB"
            echo "SERVICE_PGUSER=$SERVICE_PGUSER"

            # bootstrap mode if SERVICE_PGPASS_BOOTSTRAP exists (non-empty)
            BOOTSTRAP_MODE="false"
            if [[ -n "${SERVICE_PGPASS_BOOTSTRAP:-}" ]]; then
              BOOTSTRAP_MODE="true"
            fi

            # choose active password:
            # - prefer final secret (SERVICE_PGPASS) if present
            # - else, in bootstrap mode use bootstrap password
            # - else (non-bootstrap and no secret), fail fast
            if [[ -n "${SERVICE_PGPASS:-}" ]]; then
              ACTIVE_PGPASS="$SERVICE_PGPASS"
            elif [[ "$BOOTSTRAP_MODE" == "true" && -n "${SERVICE_PGPASS_BOOTSTRAP:-}" ]]; then
              ACTIVE_PGPASS="$SERVICE_PGPASS_BOOTSTRAP"
            fi

            until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1
            do
              >&2 echo "Postgres is unavailable - sleeping"
              sleep 5
            done
            >&2 echo "Postgres is up - executing command"

            db_exists() {
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -Atqc \
                "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1
            }

            user_exists() {
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -Atqc \
                "SELECT 1 FROM pg_roles WHERE rolname = '$SERVICE_PGUSER'" | grep -q 1
            }

            export PGPASSWORD="$ACTIVE_PGPASS"

            if db_exists; then
              echo "Database exists"
              psql -d "$SERVICE_PGDB" -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -c "\conninfo"
            else
              echo "Database does not exist; creating (idempotent)"
              # Create DB (ignore if already created by a race)
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -c "CREATE DATABASE \"$SERVICE_PGDB\";" || true

              # Ensure role exists and has the chosen password + LOGIN
              if user_exists; then
                psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -c "ALTER ROLE \"$SERVICE_PGUSER\" WITH LOGIN PASSWORD '$ACTIVE_PGPASS';"
              else
                psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -c "CREATE ROLE \"$SERVICE_PGUSER\" WITH LOGIN PASSWORD '$ACTIVE_PGPASS';"
              fi

              # Grants + extension (safe/idempotent)
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d template1 -c "GRANT ALL ON DATABASE \"$SERVICE_PGDB\" TO \"$SERVICE_PGUSER\";"
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d "$SERVICE_PGDB" -c "CREATE EXTENSION IF NOT EXISTS ltree;"
              psql -h "$PGHOST" -p "$PGPORT" -U "$SERVICE_PGUSER" -d "$SERVICE_PGDB" -c "\conninfo"
            fi

            # Signal ready by patching the final secret's dbcreated=true (base64 of "true\n")
            FINAL_SECRET="{{ .Chart.Name }}-dbcreds"
            if [[ "$BOOTSTRAP_MODE" == "true" ]]; then
              # in bootstrap mode, patch only if the final secret already exists
              if kubectl get "secret/$FINAL_SECRET" >/dev/null 2>&1; then
                kubectl patch "secret/$FINAL_SECRET" -p '{"data":{"dbcreated":"dHJ1ZQo="}}' >/dev/null
                echo "Patched $FINAL_SECRET with dbcreated=true (bootstrap mode)"
              else
                echo "Final secret not present yet (bootstrap); skipping patch"
              fi
            else
              # non-bootstrap: final secret must exist; if not, fail to surface misconfig
              if kubectl get "secret/$FINAL_SECRET" >/dev/null 2>&1; then
                kubectl patch "secret/$FINAL_SECRET" -p '{"data":{"dbcreated":"dHJ1ZQo="}}' >/dev/null
                echo "Patched $FINAL_SECRET with dbcreated=true"
              else
                echo "ERROR: Final secret '$FINAL_SECRET' missing in non-bootstrap mode." >&2
                exit 1
              fi
            fi

            # #!/bin/bash
            # set -e

            # source "${GEN3_HOME}/gen3/lib/utils.sh"
            # gen3_load "gen3/gen3setup"

            # echo "PGHOST=$PGHOST"
            # echo "PGPORT=$PGPORT"
            # echo "PGUSER=$PGUSER"

            # echo "SERVICE_PGDB=$SERVICE_PGDB"
            # echo "SERVICE_PGUSER=$SERVICE_PGUSER"

            # until pg_isready -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -d template1
            # do
            #   >&2 echo "Postgres is unavailable - sleeping"
            #   sleep 5
            # done
            # >&2 echo "Postgres is up - executing command"

            # if psql -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB; then
            #   gen3_log_info "Database exists"

            #   # Bootstrap logic for External Secrets:
            #   # On first run, SERVICE_PGPASS won't exist (secret not synced yet) — use bootstrap password.
            #   # If SERVICE_PGPASS is set, the secret already exists in Secrets Manager — use it to avoid recreating the DB.
            #   if [[ -n "${SERVICE_PGPASS}" ]]; then
            #     echo "service pgpass exists"
            #     PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
            #   else
            #     echo "service pgpass does not exist, using bootstrap password"
            #     PGPASSWORD=$SERVICE_PGPASS_BOOTSTRAP psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
            #   fi
            #     # Update secret to signal that db is ready, and services can start
            #     kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'

            # else
            #   echo "database does not exist"
            #   if [[ -n "${SERVICE_PGPASS}" ]]; then
            #     echo "service pgpass exists"
            #     psql -tc "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1 || psql -c "CREATE DATABASE \"$SERVICE_PGDB\";"
            #     gen3_log_info psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS';"
            #     psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS';"
            #     psql -c "GRANT ALL ON DATABASE \"$SERVICE_PGDB\" TO \"$SERVICE_PGUSER\" WITH GRANT OPTION;"
            #     psql -d $SERVICE_PGDB -c "CREATE EXTENSION ltree; ALTER ROLE \"$SERVICE_PGUSER\" WITH LOGIN"
            #     PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
            #   else
            #     echo "service pgpass does not exist, using bootstrap password"
            #     psql -tc "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1 || psql -c "CREATE DATABASE \"$SERVICE_PGDB\";"
            #     gen3_log_info psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS_BOOTSTRAP';"
            #     psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER \"$SERVICE_PGUSER\" WITH PASSWORD '$SERVICE_PGPASS_BOOTSTRAP';"
            #     psql -c "GRANT ALL ON DATABASE \"$SERVICE_PGDB\" TO \"$SERVICE_PGUSER\" WITH GRANT OPTION;"
            #     psql -d $SERVICE_PGDB -c "CREATE EXTENSION ltree; ALTER ROLE \"$SERVICE_PGUSER\" WITH LOGIN"
            #     PGPASSWORD=$SERVICE_PGPASS_BOOTSTRAP psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
            #   fi
            #     # Update secret to signal that db has been created, and services can start
            #     kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'
            # fi
{{- end}}
{{- end }}


{{/*
Create k8s secrets for connecting to postgres
*/}}
# DB Secrets
{{- define "common.db-secret" -}}
{{- if and 
      (or 
        (not .Values.global.externalSecrets.deploy)
        (and .Values.global.externalSecrets.deploy .Values.global.externalSecrets.dbCreate)
      )
      (not .Values.postgres.bootstrap)
}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
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
{{- end }}
{{- end }}

{{/*
  Bootstrap Secret for PushSecret to populate External Secret
*/}}
{{- define "common.secret.db.bootstrap" -}}
{{- if and (.Values.global.externalSecrets.deploy) (.Values.global.externalSecrets.dbCreate) (.Values.postgres.bootstrap) }}
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
{{- if and (.Values.global.externalSecrets.deploy) (.Values.global.externalSecrets.dbCreate) (.Values.postgres.bootstrap) }}
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: {{ $.Chart.Name }}-dbcreds
spec:
  updatePolicy: IfNotExists
  refreshInterval: 15s
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
        secretKey: password
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: password
    - match:
        secretKey: username
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: username
    - match:
        secretKey: host
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: host
    - match:
        secretKey: port
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: port
    - match:
        secretKey: database
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: database
    - match:
        secretKey: dbcreated
        remoteRef:
          remoteKey: {{ include "common.externalSecret.dbcreds.name" . }}
          property: dbcreated
{{- end }}
{{- end -}}
