
{{/* 
A job that will create test indices with data for guppy to run upon 
deployment since it requires indices to be present.
*/}}
{{ define "common.s3_restore_indices" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-restore-indices
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
              set -e
              source "${GEN3_HOME}/gen3/lib/utils.sh"
              gen3_load "gen3/gen3setup"
              export indices="$GUPPY_CONFIGINDEX $GUPPY_INDICES"
              export ESHOST="${ESHOST:-"gen3-elasticsearch:9200"}"
              sleep 75
              mkdir -p es
              cd es
              gen3_log_info "aws sts get-caller-identity"
              aws sts get-caller-identity
              echo "aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/ . --recursive"
              aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/ . --recursive
              ls
              for index in $indices
              do
                elasticdump --input /home/ubuntu/es/"$index"__mapping.json --output=http://{{ .Release.Name }}-elasticsearch:9200/$index --type mapping
                elasticdump --input /home/ubuntu/es/"$index"__data.json --output=http://{{ .Release.Name }}-elasticsearch:9200/$index --type data
              done
{{- end }}