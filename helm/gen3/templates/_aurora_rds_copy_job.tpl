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
      backoffLimit: 0
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

                  TABLE_OWNERSHIP_CMD="DO \$\$ DECLARE tbl record; BEGIN FOR tbl IN (SELECT table_schema || '.' || table_name AS full_table_name FROM information_schema.tables WHERE table_schema = 'public') LOOP EXECUTE 'ALTER TABLE ' || tbl.full_table_name || ' OWNER TO \"$TARGET_USER\";'; END LOOP; END \$\$;"
                  psql -h "$AURORA_HOST" -U "$AURORA_USER" -d "$TARGET_DB" -c "$TABLE_OWNERSHIP_CMD"
                  if [ $? -eq 0 ]; then
                    echo "Successfully set table ownership to $TARGET_USER"
                  fi

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

                  # Build JSON string from secret data for AWS console readability
                  echo "Building JSON secret string for AWS..."
                  JSON_STRING="{"
                  FIRST=true
                  for key in $SECRET_KEYS; do
                    if [ "$FIRST" = false ]; then
                      JSON_STRING="$JSON_STRING,"
                    fi
                    VALUE=$(kubectl -n "$TARGET_NS" get secret "$NEW_SECRET_NAME" -o jsonpath="{.data.$key}" | base64 --decode)
                    # Escape quotes and backslashes in the value to prevent JSON syntax errors
                    VALUE_ESCAPED=$(echo "$VALUE" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
                    JSON_STRING="$JSON_STRING\"$key\":\"$VALUE_ESCAPED\""
                    FIRST=false
                  done
                  JSON_STRING="$JSON_STRING}"

                  # Create secret with JSON string for AWS
                  kubectl -n "$TARGET_NS" create secret generic "${NEW_SECRET_NAME}-json" \
                    --from-literal=secretString="$JSON_STRING"

                  # Generate PushSecret for JSON format (readable in AWS console)
                  cat > /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml << PUSHSECRET_EOF
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
                        name: ${NEW_SECRET_NAME}-json
                    data:
                      - match:
                          secretKey: secretString
                          remoteRef:
                            remoteKey: "$AWS_SECRET_KEY"
                        metadata:
                          secretPushFormat: string
                  PUSHSECRET_EOF

                  # Apply the dynamically generated PushSecret
                  kubectl apply -f /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml
                  rm /tmp/pushsecret-$(echo $date_str | tr '_' '-').yaml

                  echo "Database copied successfully: $TARGET_DB"
                  echo "Kubernetes secret created: $NEW_SECRET_NAME"
                  echo "JSON secret created: ${NEW_SECRET_NAME}-json"
                  echo "PushSecret created with string format for AWS console readability"
                  echo "AWS Secrets Manager key: $AWS_SECRET_KEY"
                  echo "Database timestamp: $date_str"
{{- end }}
{{- end }}

{{- end }}
