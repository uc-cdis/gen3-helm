
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
            secretName: {{.Chart.Name}}-aws-config
      containers:
        - name: create-indices
          image: quay.io/cdis/awshelper:master
          env:
            - name: GEN3_HOME
              value: /home/ubuntu/cloud-automation
            - name: ESHOST
              value: {{ default "gen3-elasticsearch-master:9200"  $.Values.esEndpoint }}
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
              export ESHOST="${ESHOST:-"elasticsearch:9200"}"
              until curl -s -f -o /dev/null "http://$ESHOST"
              do
                gen3_log_info "ES not available at http://$ESHOST. Sleeping."
                sleep 5
              done

              mkdir -p es
              cd es
              gen3_log_info "aws sts get-caller-identity"
              aws sts get-caller-identity
              
              for index in $indices
              do
                echo "aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/${index}__data.json ."
                aws s3 cp "s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/${index}__data.json" .
                
                echo "aws s3 cp s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/$i{ndex}__mapping.json ."
                aws s3 cp "s3://$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/${index}__mapping.json" .

                
                gen3_log_info "ls"
                ls
                gen3_log_info "Creating Mapping ..."
                elasticdump --input "/home/ubuntu/es/${index}__mapping.json" --output=http://$ESHOST/$index --type mapping
                sleep 10
                gen3_log_info "Restoring data...."
                elasticdump --input "/home/ubuntu/es/${index}__data.json" --output=http://$ESHOST/$index --type data --limit 10000
              done
{{- end }}
