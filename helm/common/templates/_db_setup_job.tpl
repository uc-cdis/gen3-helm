# DB Setup Job
{{- define "common.db-setup-job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-dbcreate
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
            value: "{{ include "gen3.master-postgres" (dict "key" "password" "context" $) }}"
          - name: PGUSER
            value: "{{ include "gen3.master-postgres" (dict "key" "username" "context" $) }}"
          - name: PGPORT
            value: "{{ include "gen3.master-postgres" (dict "key" "port" "context" $) }}"
          - name: PGHOST
            value: "{{ include "gen3.master-postgres" (dict "key" "host" "context" $) }}"
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
        args:
          - |
            echo "SERVICE_PGDB=$SERVICE_PGDB"
            echo "SERVICE_PGUSER=$SERVICE_PGUSER"
            if psql -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB; then
              echo "Database exists"
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
            else
              echo "database does not exist"
              psql -tc "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1 || psql -c "CREATE DATABASE $SERVICE_PGDB;"
              psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER $SERVICE_PGUSER WITH PASSWORD '$SERVICE_PGPASS';"
              psql -c "GRANT ALL ON DATABASE $SERVICE_PGDB TO $SERVICE_PGUSER WITH GRANT OPTION;"
              psql -d $SERVICE_PGDB -c "CREATE EXTENSION ltree; ALTER ROLE $SERVICE_PGUSER WITH LOGIN"
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
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
stringData:
  host: {{ include "gen3.service-postgres" (dict "key" "host" "service" $.Chart.Name "context" $) }}
  database: "{{ include "gen3.service-postgres" (dict "key" "database" "service" $.Chart.Name "context" $) }}"
  username: "{{ include "gen3.service-postgres" (dict "key" "username" "service" $.Chart.Name "context" $) }}"
  password: "{{ include "gen3.service-postgres" (dict "key" "password" "service" $.Chart.Name "context" $) }}"
  port: "{{ include "gen3.service-postgres" (dict "key" "port" "service" $.Chart.Name "context" $) }}"
{{- end }}