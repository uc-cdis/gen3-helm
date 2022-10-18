{{/*
 Postgres Password lookup
*/}}
{{- define "postgres.master.password" -}}
{{- $localpass := (lookup "v1" "Secret" "postgres" "postgres-postgresql" ) -}}
{{- if $localpass }}
{{- default (index $localpass.data "postgres-password" | b64dec) }}
{{- else }}
{{- default $.Values.global.postgres.master.password }}
{{- end }}
{{- end }}



{{- define "db-setup.setup-job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-dbcreate
  annotations:
    "helm.sh/hook": "pre-install,pre-upgrade"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      labels:
        app: gen3job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: db-setup
        image: quay.io/cdis/awshelper:master
        imagePullPolicy: Always
        command: ["/bin/bash", "-c"]
        env:
          - name: PGPASSWORD
            value: "{{ include "postgres.master.password" . }}"
          - name: PGUSER
            value: "{{ $.Values.global.postgres.master.username }}"
          - name: PGPORT
            value: "{{ $.Values.global.postgres.master.port }}"
          - name: PGHOST
            value: "{{ $.Values.global.postgres.host }}"
        args:
          - |
            {{- range .Values.postgres.databases }}
            if psql -lqt | cut -d \| -f 1 | grep -qw {{ .databaseName }}; then
              echo "Database named {{ .databaseName }} already exists."
            else
              psql -tc "SELECT 1 FROM pg_database WHERE datname = '{{ .databaseName }}'" | grep -q 1 || psql -c "CREATE DATABASE {{ .databaseName }};"
              psql -tc "SELECT 1 FROM pg_user WHERE usename = '{{ .username }}'" | grep -q 1 || psql -c "CREATE USER {{ .username }} WITH PASSWORD '{{ .password }}';"
              psql -c "GRANT ALL ON DATABASE {{ .databaseName }} TO {{ .username }} WITH GRANT OPTION;"
              psql -d {{ .databaseName }} -c "CREATE EXTENSION ltree; ALTER ROLE {{ .username }} WITH LOGIN"
            fi
            {{- end }}
{{- end }}

{{ define "db-setup.secret" }}
{{- range .Values.postgres.databases }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .service }}-dbcreds
  annotations:
    "helm.sh/hook": "pre-install,pre-upgrade"
    "helm.sh/resource-policy": "keep"
stringData:
  database: "{{ .databaseName }}"
  username: "{{ .username }}"
  password: "{{ .password }}"
{{- end -}}
{{- end -}}