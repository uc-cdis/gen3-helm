# DB Setup ServiceAccount
# Needs to update/ create secrets to signal that db is ready for use.
{{- define "common.cloud_db_setup_sa" -}}
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
{{- define "common.cloud_db_setup_job" -}}
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
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: password
                optional: false            
          - name: PGUSER
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: username
                optional: false            
          - name: PGPORT
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: port
                optional: false            
          - name: PGHOST
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: host
                optional: false            
          - name: SERVICE_PGUSER
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-dbcreds
                key: serviceusername
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
                key: servicepassword
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
