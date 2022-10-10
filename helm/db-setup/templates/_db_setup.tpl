{{- define "db-setup.setup-job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup
spec:
  template:
    metadata:
      labels:
        app: gen3job
      annotations:
        "helm.sh/hook": pre-install
        "helm.sh/hook-weight": "-5"
        "helm.sh/hook-delete-policy": hook-succeeded
    spec:
      restartPolicy: OnFailure
      containers:
      - name: db-setup
        image: quay.io/cdis/awshelper:master
        imagePullPolicy: Always
        command: ["/bin/bash", "-c"]
        args:
          - |
            export PGPASSWORD="{{ $.Values.postgres.master.password }}"
            {{- range .Values.postgres.databases }}
            psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -tc "SELECT 1 FROM pg_database WHERE datname = '{{ .databaseName }}'" | grep -q 1 || psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -c "CREATE DATABASE {{ .databaseName }};"
            psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -tc "SELECT 1 FROM pg_user WHERE usename = '{{ .username }}'" | grep -q 1 || psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -c "CREATE USER {{ .username }} WITH PASSWORD '{{ .password }}';"
            psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -c "GRANT ALL ON DATABASE {{ .databaseName }} TO {{ .username }} WITH GRANT OPTION;"
            psql -h {{ $.Values.postgres.host }} -U {{ $.Values.postgres.master.username }} -p {{ $.Values.postgres.master.port }} -d {{ .databaseName }} -c "CREATE EXTENSION ltree; ALTER ROLE {{ .username }} WITH LOGIN" 
            {{- end }}
{{- end -}}