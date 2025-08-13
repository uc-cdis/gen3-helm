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
    verbs: ["get", "list", "create", "patch"]
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
                  NEW_SECRET_NAME="$(echo "${TARGET_SECRET}-${date_str}" | tr '_' '-')"
                  kubectl -n "$TARGET_NS" get secret "$TARGET_SECRET" -o json \
                    | jq --arg newdb "$TARGET_DB" \
                          --arg name "$NEW_SECRET_NAME" \
                          '.metadata.name = $name | .data.database = ($newdb | @base64) | del(.metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp, .metadata.annotations, .metadata.managedFields)' \
                    | kubectl apply -f -

                  echo "Applying ESO PushSecret annotation..."
                  kubectl -n "$TARGET_NS" annotate secret "$NEW_SECRET_NAME" \
                    "external-secrets.io/push-to-secret-store=true" \
                    "external-secrets.io/push-secret-store=gen3-secret-store" \
                    "external-secrets.io/push-secret-name=${TARGET_NS}-${NEW_SECRET_NAME}" --overwrite

                  echo "Database copied and secret $NEW_SECRET_NAME created and marked for push to AWS Secrets Manager"
{{- end }}
{{- end }}

{{- end }}
