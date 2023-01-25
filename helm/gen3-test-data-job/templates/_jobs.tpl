
{{/* 
Generate Test data
*/}}
{{- define "gen3-test-data-job.gentestdata-job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: gentestdata-job-{{ randAlphaNum 6 | lower }}
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: gen3job
    spec:
      serviceAccountName: useryaml-job
      volumes:
        - name: yaml-merge
          configMap:
            name: "fence-yaml-merge"
        - name: shared-data
          emptyDir: {}
# -----------------------------------------------------------------------------
# DEPRECATED! Remove when all commons are no longer using local_settings.py
#             for fence.
# -----------------------------------------------------------------------------
        - name: old-config-volume
          secret:
            secretName: "fence-secret"
        - name: creds-volume
          secret:
            secretName: "fence-creds"
        - name: config-helper
          configMap:
            name: config-helper
        - name: json-secret-volume
          secret:
            secretName: "fence-json-secret"
# -----------------------------------------------------------------------------
        - name: config-volume
          secret:
            secretName: "fence-config"
        - name: fence-jwt-keys
          secret:
            secretName: "fence-jwt-keys"
      containers:
      - name: auto-qa
        image: quay.io/cdis/data-simulator:master
        imagePullPolicy: Always
        env:
          - name: PYTHONPATH
            value: /var/www/fence
          - name: DICTIONARY_URL
            valueFrom:
              configMapKeyRef:
                name: manifest-global
                key: dictionary_url
          - name: HOSTNAME
            valueFrom:
              configMapKeyRef:
                name: global
                key: hostname
          - name: TEST_PROGRAM
            value: "{{ .Values.gentestdata.test_program }}"
          - name: TEST_PROJECT
            value: "{{ .Values.gentestdata.test_project  }}"
          - name: MAX_EXAMPLES
            value: "{{ .Values.gentestdata.max_examples }}"
          - name: SUBMISSION_ORDER
            value: "{{ .Values.gentestdata.submission_order }}"
        volumeMounts:
          - name: shared-data
            mountPath: /mnt/shared
        command: ["/bin/bash" ]
        args:
          - "-c"
          - |
            let count=0
            while [[ ! -f /mnt/shared/access_token.txt && $count -lt 50 ]]; do
              echo "waiting for /mnt/shared/access_token.txt";
              sleep 2
              let count=$count+1
            done

            mkdir -p /TestData
            data-simulator simulate --url $DICTIONARY_URL --path /TestData --program $TEST_PROGRAM --project $TEST_PROJECT --max_samples $MAX_EXAMPLES

            echo "define submission order"
            data-simulator submission_order --url $DICTIONARY_URL --path /TestData --node_name $SUBMISSION_ORDER

            echo "Preparing to submit data"
            data-simulator submitting_data --host https://$HOSTNAME --dir /TestData/ --project "$TEST_PROGRAM/$TEST_PROJECT" --access_token /mnt/shared/access_token.txt
            echo "All Done - always succeed to avoid k8s retries"
      - name: fence
        image: {{ .Values.fence.image }}
        imagePullPolicy: Always
        env:
          - name: PYTHONPATH
            value: /var/www/fence
          - name: SUBMISSION_USER
            value: "{{ .Values.gentestdata.submission_user }}"
          - name: TOKEN_EXPIRATION
            value: "3600"
          - name: FENCE_PUBLIC_CONFIG
            valueFrom:
              configMapKeyRef:
                name: manifest-fence
                key: fence-config-public.yaml
                optional: true
        volumeMounts:
# -----------------------------------------------------------------------------
# DEPRECATED! Remove when all commons are no longer using local_settings.py
#             for fence.
# -----------------------------------------------------------------------------
          - name: "old-config-volume"
            readOnly: true
            mountPath: "/var/www/fence/local_settings.py"
            subPath: local_settings.py
          - name: "creds-volume"
            readOnly: true
            mountPath: "/var/www/fence/creds.json"
            subPath: creds.json
          - name: "config-helper"
            readOnly: true
            mountPath: "/var/www/fence/config_helper.py"
            subPath: config_helper.py
          - name: "json-secret-volume"
            readOnly: true
            mountPath: "/var/www/fence/fence_credentials.json"
            subPath: fence_credentials.json
# -----------------------------------------------------------------------------
          - name: "config-volume"
            readOnly: true
            mountPath: "/var/www/fence/fence-config-secret.yaml"
            subPath: fence-config.yaml
          - name: "yaml-merge"
            readOnly: true
            mountPath: "/var/www/fence/yaml_merge.py"
            subPath: yaml_merge.py
          - name: "fence-jwt-keys"
            readOnly: true
            mountPath: "/fence/jwt-keys.tar"
            subPath: "jwt-keys.tar"
          - name: shared-data
            mountPath: /mnt/shared
        command: ["/bin/bash" ]
        args:
            - "-c"
            - |
              echo "${FENCE_PUBLIC_CONFIG:-""}" > "/var/www/fence/fence-config-public.yaml"
              python /var/www/fence/yaml_merge.py /var/www/fence/fence-config-public.yaml /var/www/fence/fence-config-secret.yaml > /var/www/fence/fence-config.yaml
              if [ -f /fence/jwt-keys.tar ]; then
                cd /fence
                tar xvf jwt-keys.tar
                if [ -d jwt-keys ]; then
                  mkdir -p keys
                  mv jwt-keys/* keys/
                fi
              fi
              echo "generate access token"
              echo "fence-create --path fence token-create --type access_token --username $SUBMISSION_USER  --scopes openid,user,test-client --exp $TOKEN_EXPIRATION"
              tempFile="$(mktemp -p /tmp token.txt_XXXXXX)"
              success=false
              count=0
              sleepTime=10
              # retry loop
              while [[ $count -lt 3 && $success == false ]]; do
                if fence-create --path fence token-create --type access_token --username $SUBMISSION_USER  --scopes openid,user,test-client --exp $TOKEN_EXPIRATION > "$tempFile"; then
                  echo "fence-create success!"
                  tail -1 "$tempFile" > /mnt/shared/access_token.txt
                  # base64 --decode complains about invalid characters - don't know why
                  awk -F . '{ print $2 }' /mnt/shared/access_token.txt | base64 --decode 2> /dev/null
                  success=true
                else
                  echo "fence-create failed!"
                  cat "$tempFile"
                  echo "sleep for $sleepTime, then retry"
                  sleep "$sleepTime"
                  let sleepTime=$sleepTime+$sleepTime
                fi
                let count=$count+1
              done
              if [[ $success != true ]]; then
                echo "Giving up on fence-create after $count retries - failed to create valid access token"
              fi
              echo ""
              echo "All Done - always succeed to avoid k8s retries"
      restartPolicy: Never
{{- end }}

{{/* 
A job that will create test indices with data for guppy to run upon 
deployment since it requires indices to be present.
*/}}
{{ define "gen3-test-data-job.create-test-indices" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-create-test-indices
spec:
  template:
    metadata:
      labels:
        app: gen3job
    spec:
      restartPolicy: Never
    #   serviceAccountName: gitops-sa
    #   securityContext:
    #     fsGroup: 1000
      volumes:
        - name: cred-volume
          secret:
            secretName: aws-config
      containers:
        - name: create-indices
          image: quay.io/cdis/awshelper:master
          env:
            - name: GEN3_HOME
              value: /home/ubuntu/cloud-automation
            - name: GUPPY_INDICES
              value: {{ range $.Values.indices }} {{ .index }} {{ end }}
            - name: GUPPY_CONFIGINDEX
              value: {{ .Values.configIndex }}
            - name: ENVIRONMENT
              value: {{ $.Values.global.environment }}
            - name: BUCKET
              value: {{ $.Values.global.dbRestoreBucket }}
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
              source "${GEN3_HOME}/gen3/lib/utils.sh"
              gen3_load "gen3/gen3setup"
              export indices="$GUPPY_CONFIGINDEX $GUPPY_INDICES"
              export ESHOST="${ESHOST:-"gen3-elasticsearch:9200"}"
              sleep 75
              echo "aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/ . --recursive"
              aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/ . --recursive
              for index in $indices
              do
                elasticdump --input /home/ubuntu/"$index"__mapping.json --output=http://gen3-elasticsearch:9200/$index --type mapping
                elasticdump --input /home/ubuntu/"$index"__data.json --output=http://gen3-elasticsearch:9200/$index --type data
              done
              rm dev*
{{- end }}


{{/* 
A job that will restore a db using a pgdump file from s3 with bogus data
*/}}
{{ define "gen3-test-data-job.create-test-dbs" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-test-pgdump
spec:
  template:
    metadata:
      labels:
        app: gen3job
    spec:
      restartPolicy: OnFailure
    #   serviceAccountName: gitops-sa
    #   securityContext:
    #     fsGroup: 1000
      volumes:
        - name: cred-volume
          secret:
            secretName: aws-config
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
            - name: DBREADY
              valueFrom:
                secretKeyRef:
                  name: {{ .Chart.Name }}-dbcreds
                  key: dbcreated
                  optional: false
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
              sleep 60
              aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/pgdumps/ . --recursive
              echo "PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -f db$SERVICE_PGDB.backup"
              PGPASSWORD=$SERVICE_PGPASS psql -d $SERVICE_PGDB -h $PGHOST -p $PGPORT -U $SERVICE_PGUSER -f db$SERVICE_PGDB.backup
              rm db*
          livenessProbe:
            exec:
              command:
              - /bin/bash
              - -c
              - |
                echo "PGPASSWORD=$PGPASSWORD psql -U $PGUSER -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB"
                if PGPASSWORD=$PGPASSWORD psql -U $PGUSER -lqt | cut -d \| -f 1 | grep -qw $SERVICE_PGDB; then 
                  exit 0
                else
                  exit 1
                fi
            initialDelaySeconds: 5
            periodSeconds: 5
{{- end }}
