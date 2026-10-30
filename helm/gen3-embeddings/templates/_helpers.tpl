{{/*
Expand the name of the chart.
*/}}
{{- define "gen3-embeddings.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gen3-embeddings.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gen3-embeddings.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gen3-embeddings.labels" -}}
{{- if .Values.commonLabels }}
    {{- with .Values.commonLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.commonLabels" .)}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gen3-embeddings.selectorLabels" -}}
{{- if .Values.selectorLabels }}
    {{- with .Values.selectorLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.selectorLabels" .)}}
{{- end }}
{{- end }}

{{/*
  Name of the Secret holding secret values projected into the container environment, and the
  Secrets Manager key it is populated from.
*/}}
{{- define "gen3-embeddings.envSecretName" -}}
{{- default (printf "%s-env-secret" (include "gen3-embeddings.name" .)) .Values.externalSecrets.gen3EmbeddingsEnvSecret }}
{{- end }}

{{/*
  Resolved settings for the role the service connects as, kept apart from the role that owns the
  tables. The owner can switch row level security off on its own tables, so the service runs as a
  role that owns nothing and holds only what services/gen3_embeddings/db/app_user.sql grants.
*/}}
{{- define "gen3-embeddings.appUser" -}}
{{- $appUser := .Values.postgres.appUser | default dict -}}
enabled: {{ dig "enabled" true $appUser }}
username: {{ dig "username" "" $appUser | default (printf "%s_%s_app" .Chart.Name .Release.Name) | quote }}
secretName: {{ printf "%s-app-dbcreds" .Chart.Name | quote }}
{{- end }}

{{/*
  The app role's password: the one already in the Secret if there is one, so an upgrade does not
  rotate it, and a new random one otherwise. The app-user Job sets whatever this is on the role,
  so a regenerated Secret brings the role back in step on the next run. Pods already running keep
  the old password until they restart.
*/}}
{{- define "gen3-embeddings.appUserPassword" -}}
{{- $settings := include "gen3-embeddings.appUser" . | fromYaml -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $settings.secretName).data | default dict -}}
{{- if hasKey $existing "password" }}
{{- index $existing "password" | b64dec }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}

{{/*
  Admin credentials for creating the app role, from the same sources common.db_setup_job reads.
  Only the admin can CREATE ROLE: the owner role has no CREATEROLE. Host and port are not here;
  the Job takes them from <chart>-dbcreds so the role lands on the server the service uses.
*/}}
{{- define "gen3-embeddings.adminPgEnv" -}}
- name: ADMIN_PGUSER
{{- if .Values.global.postgres.externalSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.postgres.externalSecret }}
      key: username
      optional: false
{{- else }}
  value: {{ .Values.global.postgres.master.username | quote }}
{{- end }}
- name: ADMIN_PGPASSWORD
{{- if .Values.global.dev }}
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: postgres-password
      optional: false
{{- else if .Values.global.postgres.externalSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.postgres.externalSecret }}
      key: password
      optional: false
{{- else }}
  value: {{ .Values.global.postgres.master.password | quote }}
{{- end }}
{{- end }}

{{/*
  Shell that blocks until every migration is applied, for containers that need the finished
  schema. Expects DATABASE_URL, from common.db_migrate.dsn. Emitted at column 0; callers nindent.

  Waits rather than migrates: the dbmigrate Job is the only writer. Polls the database instead of
  the Job because ttlSecondsAfterFinished reaps the Job, so a pod starting later would wait on an
  object that no longer exists.

  dbmate status --quiet exits 0 with nothing pending, 1 with migrations pending, and 2 on any
  other error. Treating 2 as "keep waiting" would turn a bad DSN into a pod that hangs in Init
  forever, so it gets a bounded retry.
*/}}
{{- define "gen3-embeddings.waitForMigrations" -}}
{{- $migrations := include "common.db_migrate.settings" . | fromYaml -}}
attempts=0
until_ready() {
  set +e
  dbmate -u "$DATABASE_URL" -d {{ $migrations.dir | quote }} status --quiet
  rc=$?
  set -e
  return $rc
}
while true; do
  if until_ready; then
    echo "Migrations up to date."
    break
  fi
  if [ "$rc" -eq 1 ]; then
    attempts=0
    echo "Waiting for migrations to be applied..."
  else
    attempts=$((attempts + 1))
    echo "dbmate status failed (rc=$rc), attempt ${attempts}/30"
    if [ "$attempts" -ge 30 ]; then
      echo "Giving up waiting for migrations."
      exit 1
    fi
  fi
  sleep 5
done
{{- end }}

{{/*
  Renders one extraEnv or secretEnv value as an unquoted string. Takes a dict of `field` (the
  values key, for error messages), `key` and `value`. Helm reads unquoted numbers in values files
  as float64, which print in exponent form from 1000000 up (1e+06), so whole numbers are printed
  as integers instead.
*/}}
{{- define "gen3-embeddings.envValue" -}}
{{- $v := .value }}
{{- if or (kindIs "map" $v) (kindIs "slice" $v) }}
{{- fail (printf "gen3-embeddings.%s[%s] must be a scalar, got %s. Use `env` for anything needing `valueFrom`." .field .key (kindOf $v)) }}
{{- else if kindIs "invalid" $v }}
{{- else if and (kindIs "float64" $v) (eq $v (floor $v)) }}
{{- int64 $v }}
{{- else }}
{{- $v }}
{{- end }}
{{- end }}
