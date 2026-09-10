{{/*
  Shared dbmate migration runner.

  dbmate takes no lock while migrating: Migrate() reads the applied-version set once up front and
  never re-checks it, so two concurrent processes compute the same pending list and both apply it.
  Running migrations from a Deployment initContainer therefore races once replicaCount exceeds 1.
  These templates move migrations to a single Job with parallelism 1, leaving the Deployment to
  wait rather than migrate.

  Ordering against database creation is inherited, not reimplemented: DBREADY reads the
  `dbcreated` key that common.db_setup_job patches into <chart>-dbcreds. common.db-secret does not
  create that key, so with optional:false the pod stays in CreateContainerConfigError until the
  database exists. Nothing reads the value.
*/}}

{{/*
  Resolved migration settings, so callers and both Jobs agree on one source of truth.
  `dig` throughout: a chart may include these templates without declaring postgres.migrations.
*/}}
{{- define "common.db_migrate.settings" -}}
{{- $chart := dig "migrations" dict (.Values.postgres | default dict) -}}
{{- $global := dig "postgres" "migrations" dict (.Values.global | default dict) -}}
enabled: {{ or (dig "enabled" false $global) (dig "enabled" false $chart) }}
dir: {{ dig "dir" (dig "dir" "" $global) $chart | quote }}
sslmode: {{ dig "sslmode" (dig "sslmode" "disable" $global) $chart | quote }}
{{- end }}

{{/*
  Migration connection. Every value comes from <chart>-dbcreds, so migrations reuse the role
  common.db_setup_job already provisioned rather than a second credential path.

  DB_MIGRATION_* rather than PG*: the service reads PGUSER/PGPASSWORD as its runtime role, and
  naming the migration role the same way would leave no way to tell which role a variable meant
  once the two stop being equal. PGUSER/PGPASSWORD are deliberately absent here.

  That role is sufficient today because common.db_setup_job grants it ALL PRIVILEGES on the
  database and ownership of schema public. CREATEDB is not needed: the container runs
  `dbmate migrate`, which never creates a database, and DBREADY gates it until db_setup_job has.

  A service whose tables use row level security needs a runtime role that owns nothing, and at
  that point DB_MIGRATION_* has to point at a separate owner role instead.
*/}}
{{- define "common.db_migrate.env" -}}
- name: DB_MIGRATION_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: username
      optional: false
- name: DB_MIGRATION_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: password
      optional: false
- name: PGHOST
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: host
      optional: false
- name: PGPORT
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: port
      optional: false
- name: PGDATABASE
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: database
      optional: false
{{- /* Startup gate: absent until common.db_setup_job patches it in. */}}
- name: DBREADY
  valueFrom:
    secretKeyRef:
      name: {{ .Chart.Name }}-dbcreds
      key: dbcreated
      optional: false
{{- end }}

{{/*
  Shell prelude setting DATABASE_URL, shared by the migrating container and by any caller that
  waits on migrations, so the two cannot disagree about which role connects where.

  The password is deliberately absent from the DSN: it is not URL-encoded here, so a password
  containing @, / or : would corrupt the URL. dbmate hands the connection string to lib/pq,
  which falls back to libpq environment variables for anything the URL omits, so PGPASSWORD is
  picked up as-is. Host and port cannot move to the environment the same way - dbmate always
  forces them into the URL.
*/}}
{{- define "common.db_migrate.dsn" -}}
{{- $settings := include "common.db_migrate.settings" . | fromYaml -}}
export PGPASSWORD="$DB_MIGRATION_PASSWORD"
DATABASE_URL="postgresql://${DB_MIGRATION_USER}@${PGHOST}:${PGPORT}/${PGDATABASE}?sslmode={{ $settings.sslmode }}"
{{- end }}

{{/*
  The migrating container. Emitted at column 0; callers nindent it, since a Job and a CronJob
  nest their pod specs at different depths.

  /bin/sh rather than /bin/bash: adopters include alpine-based images with no bash.
*/}}
{{- define "common.db_migrate.container" -}}
{{- $settings := include "common.db_migrate.settings" . | fromYaml -}}
- name: {{ .Chart.Name }}-dbmigrate
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  env:
    {{- include "common.db_migrate.env" . | nindent 4 }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      echo "Running {{ .Chart.Name }} migrations..."
      {{- include "common.db_migrate.dsn" . | nindent 6 }}
      dbmate -u "$DATABASE_URL" -d {{ $settings.dir | quote }} migrate
      echo "Migrations completed."
{{- end }}

{{/*
  Every-deploy migration Job.

  The name carries a hash of the inputs that can change what migrating does, so an unchanged
  deploy re-applies an identical spec (a no-op) instead of failing on Job immutability, while a new
  image produces a new Job. Editing this template's spec without changing those inputs requires
  deleting the old Job once.

  No serviceAccountName: credentials arrive by secretKeyRef, so unlike common.db_setup_job - which
  needs RBAC purely to kubectl patch a secret - this needs none.

  No activeDeadlineSeconds: a container-create failure does not consume backoffLimit, so waiting on
  `dbcreated` is safe, but a deadline would kill the Job while it waits.
*/}}
{{- define "common.db_migrate_job" -}}
{{- $settings := include "common.db_migrate.settings" . | fromYaml -}}
{{- if $settings.enabled }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $hash := printf "%s|%s|%s" $tag $settings.dir $settings.sslmode | sha256sum | trunc 8 -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-dbmigrate-{{ $hash }}
spec:
  {{- /* One migration process at a time. Retries create sequential pods, never parallel ones. */}}
  parallelism: 1
  completions: 1
  backoffLimit: 3
  ttlSecondsAfterFinished: 3600
  template:
    metadata:
      labels:
        {{- /* Required, not cosmetic: common.db_netpolicy grants database egress to
               app in (<chart>, gen3job), and observability selects job logs on it. */}}
        app: gen3job
    spec:
      restartPolicy: OnFailure
      automountServiceAccountToken: false
      containers:
        {{- include "common.db_migrate.container" . | nindent 8 }}
{{- end }}
{{- end }}

{{/*
  Manual migration runner, for backfills and repair.

  A suspended CronJob on an impossible date is this repo's idiom for a Job template that never
  fires by itself - see fence-db-migrate-cronjob and docs/fence-db-migration.md. Trigger with:
    kubectl create job --from=cronjob/<chart>-dbmigrate-cronjob <chart>-dbmigrate-manual
*/}}
{{- define "common.db_migrate_cronjob" -}}
{{- $settings := include "common.db_migrate.settings" . | fromYaml -}}
{{- if $settings.enabled }}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ .Chart.Name }}-dbmigrate-cronjob
spec:
  suspend: true
  {{- /* Feb 31 never arrives; suspend is belt and braces. */}}
  schedule: "0 0 31 2 *"
  jobTemplate:
    spec:
      backoffLimit: 0
      template:
        metadata:
          labels:
            app: gen3job
        spec:
          restartPolicy: Never
          automountServiceAccountToken: false
          containers:
            {{- include "common.db_migrate.container" . | nindent 12 }}
{{- end }}
{{- end }}
