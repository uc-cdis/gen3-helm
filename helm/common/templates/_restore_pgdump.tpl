{{/* 
A job that will restore a db using a pgdump file from s3 with bogus data
*/}}
{{ define "common.s3_pg_restore" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-pgrestore
spec:
  template:
    metadata:
      labels:
        app: gen3job
    spec:
      serviceAccountName: {{ .Chart.Name }}-dbcreate-sa
      restartPolicy: Never
      volumes:
        - name: cred-volume
          secret:
            secretName: {{.Chart.Name}}-aws-config
            {{- if .Values.global.aws.useLocalSecret.enabled -}}
              secretName: {{ .Values.global.aws.useLocalSecret.localSecretName }}
            {{ else }}
              secretName: {{.Chart.Name}}-aws-config
            {{ end }}
      containers:
        - name: restore-dbs
          image: quay.io/cdis/awshelper:master
          imagePullPolicy: Always
          env:
            - name: PGPASSWORD
              {{- if $.Values.global.dev }}
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-postgresql
                  key: postgres-password
                  optional: false
              {{- else }}
              value:  {{ .Values.global.postgres.master.password | quote}}
              {{- end }}
            - name: PGUSER
              value: {{ .Values.global.postgres.master.username | quote }}
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
            - name: ENVIRONMENT
              value: {{ .Values.global.environment }}
            - name: BUCKET
              value: {{ .Values.global.dbRestoreBucket }}
            - name: VERSION
              value: {{ .Chart.Version }}
          volumeMounts:
            - name: cred-volume
              mountPath: "/home/ubuntu/.aws/credentials"
              subPath: credentials
          command: [ "/bin/bash" ]
          args:
            - "-c"
            - |
              set -e
              source "${GEN3_HOME}/gen3/lib/utils.sh"
              gen3_load "gen3/gen3setup"
              gen3_log_info "Starting the s3_pg_restore job."
              
              
              until pg_isready -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -d template1
              do
                >&2 echo "Postgres is unavailable - sleeping"
                sleep 5
              done
              >&2 echo "Postgres is up - executing command"


              if psql -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB; then
                gen3_log_err "Database exists. Please drop database, or use another database as target"
                # Test connection before patching secret
                PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"

                # Update secret to signal that db has been created, and services can start
                kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'
              else
                gen3_log_info "Verify aws cli is setup properly"
                gen3_log_info "aws sts get-caller-identity"
                aws sts get-caller-identity

                FILE={{ .Chart.Name }}.sql
                gen3_log_info "aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/pgdumps/$FILE . "
                aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/pgdumps/$FILE . 

                gen3_log_info "S3 Copy finished. Moving on to DB restore"
                gen3_log_info "Attempting to create database, and restore pg_dump"
                psql -tc "SELECT 1 FROM pg_database WHERE datname = '$SERVICE_PGDB'" | grep -q 1 || psql -c "CREATE DATABASE $SERVICE_PGDB;"
                psql -tc "SELECT 1 FROM pg_user WHERE usename = '$SERVICE_PGUSER'" | grep -q 1 || psql -c "CREATE USER $SERVICE_PGUSER WITH PASSWORD '$SERVICE_PGPASS';"
                psql -c "GRANT ALL ON DATABASE $SERVICE_PGDB TO $SERVICE_PGUSER WITH GRANT OPTION;"
                psql -d $SERVICE_PGDB -c "CREATE EXTENSION ltree; ALTER ROLE $SERVICE_PGUSER WITH LOGIN"
                PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"
                
                gen3_log_info "Starting restore.."
                gen3_log_info "PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -f $FILE"
                PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -f $FILE

                gen3_log_info "db restored"
              fi
              
              # Test connection before patching secret
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -c "\conninfo"

              # Update secret to signal that db has been created, and services can start
              kubectl patch secret/{{ .Chart.Name }}-dbcreds -p '{"data":{"dbcreated":"dHJ1ZQo="}}'
              
{{- end }}
