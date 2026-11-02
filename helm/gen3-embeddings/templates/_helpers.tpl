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
  A positive whole number from values, printed without an exponent. Takes a dict of `where` (for
  error messages) and `value`. Accepts a number or a string of digits.
*/}}
{{- define "gen3-embeddings.wholeNumber" -}}
{{- $v := .value }}
{{- if and (kindIs "float64" $v) (eq $v (floor $v)) (gt $v 0.0) }}
{{- int64 $v }}
{{- else if and (or (kindIs "int" $v) (kindIs "int64" $v)) (gt (int64 $v) 0) }}
{{- $v }}
{{- else if and (kindIs "string" $v) (regexMatch "^[0-9]+$" $v) }}
{{- $v }}
{{- else }}
{{- fail (printf "%s must be a positive whole number, got %v" .where $v) }}
{{- end }}
{{- end }}

{{/*
  vectorIndexes.indexes rendered as dbmate index migration files, as a YAML map of file name to
  contents. Each index is written in exactly the shape the service recognizes, which
  services/gen3_embeddings/db/index_migrations/README.md describes: one statement per file,
  transaction:false, CONCURRENTLY, HNSW, and a WHERE clause of exactly `collection_id = <id>`.
  An index in any other shape is ignored by the service, and searches on its collection fall
  back to a sequential scan.
*/}}
{{- define "gen3-embeddings.vectorIndexFiles" -}}
{{- $indexes := dig "indexes" list (.Values.vectorIndexes | default dict) | default list }}
{{- if not (kindIs "slice" $indexes) }}
{{- fail (printf "gen3-embeddings.vectorIndexes.indexes must be a list, got %s." (kindOf $indexes)) }}
{{- end }}
{{- $files := dict }}
{{- $versions := dict }}
{{- range $i, $idx := $indexes }}
{{- $where := printf "gen3-embeddings.vectorIndexes.indexes[%d]" $i }}
{{- if not (kindIs "map" $idx) }}
{{- fail (printf "%s must be a map, got %s." $where (kindOf $idx)) }}
{{- end }}
{{- range $key := keys $idx }}
{{- if not (has $key (list "version" "collectionId" "vectorType" "dimensions" "kind" "params" "drop")) }}
{{- fail (printf "%s has unknown key %s." $where $key) }}
{{- end }}
{{- end }}
{{- range $key := list "version" "collectionId" "vectorType" "dimensions" "kind" }}
{{- if not (hasKey $idx $key) }}
{{- fail (printf "%s is missing %s." $where $key) }}
{{- end }}
{{- end }}
{{- $version := include "gen3-embeddings.wholeNumber" (dict "where" (printf "%s.version" $where) "value" $idx.version) }}
{{- if hasKey $versions $version }}
{{- fail (printf "%s reuses version %s, which dbmate uses to tell migrations apart." $where $version) }}
{{- end }}
{{- $_ := set $versions $version true }}
{{- $collectionId := include "gen3-embeddings.wholeNumber" (dict "where" (printf "%s.collectionId" $where) "value" $idx.collectionId) }}
{{- $dims := include "gen3-embeddings.wholeNumber" (dict "where" (printf "%s.dimensions" $where) "value" $idx.dimensions) | atoi }}
{{- $vectorType := $idx.vectorType }}
{{- if not (has $vectorType (list "vector" "halfvec")) }}
{{- fail (printf "%s.vectorType must be vector or halfvec, got %v." $where $vectorType) }}
{{- end }}
{{- $kind := $idx.kind }}
{{- if not (has $kind (list "cosine" "l2" "ip" "l1" "binary")) }}
{{- fail (printf "%s.kind must be one of cosine, l2, ip, l1, binary, got %v." $where $kind) }}
{{- end }}
{{- /* pgvector's HNSW limits. Above them only a binary index can be built. */}}
{{- $maxDims := ternary 64000 (ternary 2000 4000 (eq $vectorType "vector")) (eq $kind "binary") }}
{{- if gt $dims $maxDims }}
{{- fail (printf "%s: a %s %s HNSW index supports at most %d dimensions, got %d." $where $vectorType $kind $maxDims $dims) }}
{{- end }}
{{- $table := printf "embeddings_%s" $vectorType }}
{{- $name := printf "%s_c%s_hnsw_%s" $table $collectionId $kind }}
{{- $expr := printf "(embedding::%s(%d))" $vectorType $dims }}
{{- $opclass := printf "%s_%s_ops" $vectorType $kind }}
{{- if eq $kind "binary" }}
{{- $expr = printf "(binary_quantize(embedding)::bit(%d))" $dims }}
{{- $opclass = "bit_hamming_ops" }}
{{- end }}
{{- $with := list }}
{{- range $param, $value := ($idx.params | default dict) }}
{{- if not (has $param (list "m" "ef_construction")) }}
{{- fail (printf "%s.params has unknown key %s; only m and ef_construction are supported." $where $param) }}
{{- end }}
{{- $with = append $with (printf "%s = %s" $param (include "gen3-embeddings.wholeNumber" (dict "where" (printf "%s.params.%s" $where $param) "value" $value))) }}
{{- end }}
{{- $create := printf "CREATE INDEX CONCURRENTLY IF NOT EXISTS %s\nON %s USING hnsw (%s %s)" $name $table $expr $opclass }}
{{- if $with }}
{{- $create = printf "%s\nWITH (%s)" $create (join ", " $with) }}
{{- end }}
{{- $create = printf "%s\nWHERE collection_id = %s;" $create $collectionId }}
{{- $drop := printf "DROP INDEX CONCURRENTLY IF EXISTS %s;" $name }}
{{- if $idx.drop }}
{{- $_ := set $files (printf "%s_drop_%s.sql" $version $name) (printf "-- migrate:up transaction:false\n%s\n\n-- migrate:down transaction:false\n%s\n" $drop $create) }}
{{- else }}
{{- $_ := set $files (printf "%s_%s.sql" $version $name) (printf "-- migrate:up transaction:false\n%s\n\n-- migrate:down transaction:false\n%s\n" $create $drop) }}
{{- end }}
{{- end }}
{{- toYaml $files }}
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
