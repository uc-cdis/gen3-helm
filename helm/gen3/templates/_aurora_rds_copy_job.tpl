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

# aurora-db-copy-job.yaml
{{- if .Values.auroraRdsCopyJob.enabled }}
{{- range .Values.auroraRdsCopyJob.services }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: aurora-db-copy-{{ .serviceName }}-{{ now | date "060204_150405" }}
  namespace: {{ $.Values.auroraRdsCopyJob.targetNamespace }}
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
          image: 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/awshelper:latest
          command:
            - "/bin/bash"
            - "-c"
            - |
              set -euo pipefail

              get_secret() {
                kubectl -n "$1" get secret "$2" -o jsonpath="{.data.$3}" | base64 --decode
              }

              SOURCE_NS={{ $.Values.auroraRdsCopyJob.sourceNamespace }}
              TARGET_NS={{ $.Values.auroraRdsCopyJob.targetNamespace }}
              SOURCE_SECRET={{ .sourceSecret }}
              TARGET_SECRET={{ .targetSecret }}
              AURORA_SECRET={{ $.Values.auroraRdsCopyJob.auroraMasterSecret }}

              SOURCE_DB=$(get_secret "$SOURCE_NS" "$SOURCE_SECRET" database)
              SOURCE_HOST=$(get_secret "$SOURCE_NS" "$SOURCE_SECRET" host)
              TARGET_HOST=$(get_secret "$TARGET_NS" "$TARGET_SECRET" host)
              TARGET_USER=$(get_secret "$TARGET_NS" "$TARGET_SECRET" username)

              AURORA_HOST=$(get_secret "$TARGET_NS" "$AURORA_SECRET" host)
              AURORA_USER=$(get_secret "$TARGET_NS" "$AURORA_SECRET" username)
              AURORA_PASS=$(get_secret "$TARGET_NS" "$AURORA_SECRET" password)

              if [[ "$SOURCE_HOST" != "$TARGET_HOST" || "$TARGET_HOST" != "$AURORA_HOST" ]]; then
                echo "Host mismatch detected!"; exit 1
              fi

              TARGET_DB="{{ .serviceName }}_$(date '+%y%m%d_%H%M%S')"

              export PGPASSWORD="$AURORA_PASS"

              psql -h "$AURORA_HOST" -U "$AURORA_USER" -d postgres <<EOF
              GRANT "$TARGET_USER" TO "$AURORA_USER";
              SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$SOURCE_DB' AND pid <> pg_backend_pid();
              CREATE DATABASE "$TARGET_DB" WITH TEMPLATE "$SOURCE_DB" OWNER "$TARGET_USER";
              EOF

              psql -h "$AURORA_HOST" -U "$AURORA_USER" -d "$TARGET_DB" <<EOF
              DO \$\$ DECLARE tbl record;
              BEGIN
                FOR tbl IN SELECT table_schema || '.' || table_name FROM information_schema.tables WHERE table_schema = 'public'
                LOOP
                  EXECUTE 'ALTER TABLE ' || tbl.full_table_name || ' OWNER TO "$TARGET_USER";';
                END LOOP;
              END \$\$;
              EOF

              echo "::CLONED_DB_NAME::{{ .serviceName }}=$TARGET_DB"

              if {{ $.Values.auroraRdsCopyJob.writeToK8sSecret | quote }} == "true"; then
                PATCH="{\"data\":{\"{{ .serviceName }}\":\"$TARGET_DB\"}}"
                if kubectl -n "$TARGET_NS" get secret cloned-db-names >/dev/null 2>&1; then
                  kubectl -n "$TARGET_NS" patch secret cloned-db-names --type merge -p "$PATCH"
                else
                  kubectl -n "$TARGET_NS" create secret generic cloned-db-names \
                    --from-literal={{ .serviceName }}="$TARGET_DB"
                fi
              fi

              if {{ $.Values.auroraRdsCopyJob.writeToAwsSecret | quote }} == "true"; then
                aws secretsmanager update-secret --secret-id "$TARGET_SECRET" \
                  --secret-string "$(aws secretsmanager get-secret-value --secret-id $TARGET_SECRET | jq '.SecretString' | jq --arg db "$TARGET_DB" '.database=$db')"
              fi

              echo "Database copied successfully: $SOURCE_DB -> $TARGET_DB"
{{- end }}
{{- end }}

{{- end }}

