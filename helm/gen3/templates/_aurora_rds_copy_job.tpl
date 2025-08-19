{{- define "gen3.auroraRdsCopyJob" }}

# aurora-db-copy-access.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aurora-db-copy-sa
  namespace: {{ .Values.auroraRdsCopyJob.targetNamespace }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aurora-db-copy-secret-reader
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "create", "patch", "update"]
  - apiGroups: ["external-secrets.io"]
    resources: ["pushsecrets"]
    verbs: ["get", "list", "create", "patch", "update", "delete"]
  - apiGroups: ["external-secrets.io"]
    resources: ["secretstores"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aurora-db-copy-sa-binding-{{ .Values.auroraRdsCopyJob.targetNamespace }}
subjects:
  - kind: ServiceAccount
    name: aurora-db-copy-sa
    namespace: {{ .Values.auroraRdsCopyJob.targetNamespace }}
roleRef:
  kind: ClusterRole
  name: aurora-db-copy-secret-reader
  apiGroup: rbac.authorization.k8s.io

{{- if .Values.auroraRdsCopyJob.enabled }}
{{- range .Values.auroraRdsCopyJob.services }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: aurora-db-copy-{{ .serviceName }}
  namespace: {{ $.Values.auroraRdsCopyJob.targetNamespace }}
  annotations:
    "cronjob.kubernetes.io/disabled": "true"
spec:
  schedule: "0 0 31 3 *" 
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      backoffLimit: 2
      template:
        metadata:
          labels:
            app: aurora-db-copy-job
        spec:
          serviceAccountName: aurora-db-copy-sa
          restartPolicy: Never
          containers:
            - name: aurora-db-copy-container
              image: 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/awshelper:master
              command:
                - /bin/bash
                - -c
                - |-
                  set -euo pipefail

                  get_secret() {
                    kubectl -n "$1" get secret "$2" -o jsonpath="{.data.$3}" | base64 --decode
                  }

                  truncate_identifier() {
                    local name="$1"
                    echo "$name" | cut -c1-63
                  }

                  SOURCE_NS="{{ $.Values.auroraRdsCopyJob.sourceNamespace }}"
                  TARGET_NS="{{ $.Values.auroraRdsCopyJob.targetNamespace }}"
                  SOURCE_SECRET="{{ .sourceSecret }}"
                  TARGET_SECRET="{{ .targetSecret }}"
                  AURORA_SECRET="{{ $.Values.auroraRdsCopyJob.auroraMasterSecret }}"

                  SOURCE_DB=$(get_secret "$SOURCE_NS" "$SOURCE_SECRET" database)
                  SOURCE_HOST=$(get_secret "$SOURCE_NS" "$SOURCE_SECRET" host)
                  TARGET_HOST=$(get_secret "$TARGET_NS" "$TARGET_SECRET" host)
                  TARGET_USER=$(get_secret "$TARGET_NS" "$TARGET_SECRET" username)

                  AURORA_HOST=$(get_secret "$TARGET_NS" "$AURORA_SECRET" db_host)
                  AURORA_USER=$(get_secret "$TARGET_NS" "$AURORA_SECRET" db_username)
                  AURORA_PASS=$(get_secret "$TARGET_NS" "$AURORA_SECRET" db_password)

                  echo "DEBUG: SOURCE_DB=$SOURCE_DB, SOURCE_HOST=$SOURCE_HOST, TARGET_USER=$TARGET_USER"
                  echo "DEBUG: AURORA_HOST=$AURORA_HOST, AURORA_USER=$AURORA_USER"

                  if [[ "$SOURCE_HOST" != "$TARGET_HOST" ]] || [[ "$TARGET_HOST" != "$AURORA_HOST" ]]; then
                    echo "WARNING: Host mismatch detected! Proceeding anyway."
                  fi

                  export PGPASSWORD="$AURORA_PASS"

                  db_exists=$(psql -h "$AURORA_HOST" -U "$AURORA_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$SOURCE_DB'")
                  if [[ "$db_exists" != "1" ]]; then
                    echo "ERROR: Source DB does not exist: $SOURCE_DB" >&2
                    exit 1
                  fi

                  date_str=$(date '+%y%m%d_%H%M%S')
                  target_db_name="{{ .serviceName }}_{{ $.Values.auroraRdsCopyJob.targetNamespace | replace "-" "_" }}_${date_str}"
                  TARGET_DB=$(truncate_identifier "$target_db_name")
                  echo "DEBUG: TARGET_DB=$TARGET_DB"

                  psql -h "$AURORA_HOST" -U "$AURORA_USER" -d postgres -c "GRANT \"$TARGET_USER\" TO \"$AURORA_USER\";"
                  psql -h "$AURORA_HOST" -U "$AURORA_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$SOURCE_DB' AND pid <> pg_backend_pid();"
                  psql -h "$AURORA_HOST" -U "$AURORA_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$SOURCE_DB' AND pid <> pg_backend_pid();"
                  psql -h "$AURORA_HOST" -U "$AURORA_USER" -d postgres -c "CREATE DATABASE \"$TARGET_DB\" WITH TEMPLATE \"$SOURCE_DB\" OWNER \"$TARGET_USER\";"

                  echo "::CLONED_DB_NAME::{{ .serviceName }}=$TARGET_DB"

                  echo "Creating new secret with updated database name..."
                  NEW_SECRET_NAME="{{ .serviceName }}-dbcreds-$(echo $date_str | tr '_' '-')"
                  kubectl -n "$TARGET_NS" get secret "$TARGET_SECRET" -o json \
                    | jq --arg newdb "$TARGET_DB" \
                          --arg name "$NEW_SECRET_NAME" \
                          '.metadata.name = $name | .data.database = ($newdb | @base64) | del(.metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp, .metadata.annotations, .metadata.managedFields)' \
                    | kubectl apply -f -

                  echo "Creating PushSecret for AWS Secrets Manager..."
                  
                  # Create AWS secret key with timestamp (convert underscores to hyphens for AWS)
                  AWS_SECRET_KEY="${TARGET_NS}-{{ .serviceName }}-creds-$(echo $date_str | tr '_' '-')"
                  
                  echo "Database name: $TARGET_DB"
                  echo "Local secret name: $NEW_SECRET_NAME"  
                  echo "AWS Secret Manager key: $AWS_SECRET_KEY"
                  
                  # Dynamically detect ALL keys in the secret
                  SECRET_KEYS=$(kubectl -n "$TARGET_NS" get secret "$NEW_SECRET_NAME" -o jsonpath='{.data}' | jq -r 'keys[]')
                  KEY_COUNT=$(echo $SECRET_KEYS | wc -w)
                  echo "Found $KEY_COUNT keys: $(echo $SECRET_KEYS | tr '\n' ' ')"
                  
                  # Generate PushSecret with dynamic key mappings
                  cat > /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml << 'PUSHSECRET_EOF'
                  apiVersion: external-secrets.io/v1alpha1
                  kind: PushSecret
                  metadata:
                    name: aurora-pushsecret-{{ .serviceName }}-$(echo $date_str | tr '_' '-')
                    namespace: ${TARGET_NS}
                    labels:
                      service: {{ .serviceName }}
                      aurora-copy-timestamp: "$(echo $date_str | tr '_' '-')"
                  spec:
                    deletionPolicy: Delete
                    refreshInterval: 30s
                    secretStoreRefs:
                      - name: gen3-secret-store
                        kind: SecretStore
                    selector:
                      secret:
                        name: ${NEW_SECRET_NAME}
                    data:
                  PUSHSECRET_EOF
                  
                  # Dynamically add each key as individual property mapping
                  for key in $SECRET_KEYS; do
                    cat >> /tmp/pushsecret-${date_str}.yaml << MAPPING_EOF
                      - match:
                          secretKey: $key
                          remoteRef:
                            remoteKey: "$AWS_SECRET_KEY"
                            property: $key
                  MAPPING_EOF
                  done
                  
                  # Apply the dynamically generated PushSecret
                  kubectl apply -f /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml
                  rm /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml
                  
                  echo "Database copied successfully: $TARGET_DB"
                  echo "Kubernetes secret created: $NEW_SECRET_NAME"
                  echo "PushSecret created with $KEY_COUNT key mappings"
                  echo ""
                  echo "AWS Secrets Manager key: $AWS_SECRET_KEY"
                  echo "Secret keys mapped: $(echo $SECRET_KEYS | tr '\n' ' ')"
                  echo "Database timestamp: $date_str"
                  echo ""
                  echo "Database copied and secret $NEW_SECRET_NAME created"
{{- end }}
{{- end }}

{{- end }}
