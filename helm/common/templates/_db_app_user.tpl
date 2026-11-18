{{/*
  A second database role for the service, beside the <chart>-dbcreds role. The dbcreds role owns
  the tables and runs migrations, and an owner can switch row level security off on its own
  tables, so a service relying on row level security connects as this role instead, which owns
  nothing. Opt-in per chart with postgres.appUser.enabled.

  common.db_setup_job creates the role, or resets its password, on every run, using the admin
  connection it already has. Its credentials follow the same local/External Secrets split as
  <chart>-dbcreds. Table privileges are the chart's business: they can only be granted once the
  migrations have created the tables.
*/}}

{{/*
  Resolved settings, so every template agrees on names.
*/}}
{{- define "common.db_app_user.settings" -}}
{{- $appUser := dig "appUser" dict (.Values.postgres | default dict) -}}
{{- $owner := dig "username" "" (.Values.postgres | default dict) | default (printf "%s_%s" .Chart.Name .Release.Name) -}}
enabled: {{ dig "enabled" false $appUser }}
username: {{ dig "username" "" $appUser | default (printf "%s_app" $owner) | quote }}
secretName: {{ printf "%s-app-dbcreds" .Chart.Name | quote }}
{{- end }}

{{/*
  Secrets Manager name of the app role's credentials.
*/}}
{{- define "common.externalSecret.appDbcreds.name" -}}
{{- if .Values.externalSecrets.appDbcreds }}
  {{- .Values.externalSecrets.appDbcreds }}
{{- else }}
  {{- .Values.global.environment }}- {{- .Chart.Name }}-app-creds
{{- end -}}
{{- end -}}

{{/*
  The app role's password: the one already in the Secret if there is one, a new random one
  otherwise. Same approach as gen3.service-postgres for <chart>-dbcreds.
*/}}
{{- define "common.db_app_user.password" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $settings.secretName).data | default dict -}}
{{- if hasKey $existing "password" }}
{{- index $existing "password" | b64dec }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}

{{/*
  Local Secret with the app role's credentials, rendered when <chart>-dbcreds is rendered locally.
*/}}
{{- define "common.db-app-secret" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
{{- if and $settings.enabled (or (not .Values.global.externalSecrets.deploy) .Values.global.externalSecrets.createLocalK8sSecret) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $settings.secretName }}
data:
  username: {{ $settings.username | b64enc | quote }}
  password: {{ include "common.db_app_user.password" . | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
  ExternalSecret for the app role's credentials, mirroring common.externalSecret.db.
*/}}
{{- define "common.externalSecret.appDb" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
{{- if and $settings.enabled .Values.global.externalSecrets.deploy (not .Values.global.externalSecrets.createLocalK8sSecret) }}
apiVersion: {{ include "common.externalSecrets.apiVersion" . }}
kind: ExternalSecret
metadata:
  name: {{ $settings.secretName }}
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: {{ include "common.SecretStore" . }}
    kind: SecretStore
  target:
    name: {{ $settings.secretName }}
    creationPolicy: Owner
  dataFrom:
  - extract:
      key: {{ include "common.externalSecret.appDbcreds.name" . }}
      conversionStrategy: Default
      decodingStrategy: None
{{- end }}
{{- end -}}

{{/*
  Bootstrap Secret seeding the app role's Secrets Manager entry, mirroring
  common.secret.db.bootstrap. Only the first push lands: the PushSecret is IfNotExists.
*/}}
{{- define "common.secret.appDb.bootstrap" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
{{- if and $settings.enabled .Values.global.externalSecrets.deploy (or .Values.global.externalSecrets.pushSecret .Values.externalSecrets.pushSecret) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $settings.secretName }}-bootstrap
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
type: Opaque
data:
  username: {{ $settings.username | b64enc | quote }}
  password: {{ include "common.db_app_user.password" . | b64enc | quote }}
{{- end }}
{{- end -}}

{{/*
  PushSecret for the bootstrap above. Applied by common.db_setup_job, like common.db-push-secret.
*/}}
{{- define "common.app-db-push-secret" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: {{ $settings.secretName }}
spec:
  updatePolicy: IfNotExists
  refreshInterval: 2m
  secretStoreRefs:
    {{- if ne .Values.global.externalSecrets.clusterSecretStoreRef "" }}
    - name: {{ .Values.global.externalSecrets.clusterSecretStoreRef }}
      kind: ClusterSecretStore
    {{- else }}
    - name: {{ include "common.SecretStore" . }}
      kind: SecretStore
    {{- end }}
  selector:
    secret:
      name: {{ $settings.secretName }}-bootstrap
  data:
    - match:
        remoteRef:
          remoteKey: {{ include "common.externalSecret.appDbcreds.name" . }}
{{- end -}}

{{/*
  The part of common.db_setup_job's script that creates the app role. Runs on every run, whether
  or not the database already existed, as the admin connection set up there. Emitted at column 0;
  the caller nindents it.
*/}}
{{- define "common.db_app_user.setup" -}}
{{- $settings := include "common.db_app_user.settings" . | fromYaml -}}
{{- $secret := $settings.secretName -}}
{{- if and .Values.global.externalSecrets.deploy (or .Values.global.externalSecrets.pushSecret .Values.externalSecrets.pushSecret) }}
echo "Creating PushSecret {{ $secret }} ..."
echo '{{ include "common.app-db-push-secret" . | b64enc }}' | base64 --decode | kubectl -n {{ .Release.Namespace }} apply -f -
kubectl -n {{ .Release.Namespace }} wait --for=condition=Ready pushsecret/{{ $secret }} --timeout=300s
{{- end }}
# Read at run time rather than mounted: with External Secrets the Secret exists only once the
# remote entry does, and mounting it would keep this Job from starting at all.
echo "Waiting for secret {{ $secret }} ..."
for i in $(seq 1 60); do
  kubectl -n {{ .Release.Namespace }} get secret {{ $secret }} >/dev/null 2>&1 && break
  sleep 5
done
APP_PGUSER="$(kubectl -n {{ .Release.Namespace }} get secret {{ $secret }} -o jsonpath='{.data.username}' | base64 -d)"
APP_PGPASSWORD="$(kubectl -n {{ .Release.Namespace }} get secret {{ $secret }} -o jsonpath='{.data.password}' | base64 -d)"
if [ -z "$APP_PGUSER" ] || [ -z "$APP_PGPASSWORD" ]; then
  echo "ERROR: {{ $secret }} has no username or password"
  exit 1
fi
# Setting the password on every run keeps the role in step with the Secret. The admin owns the
# database, so it grants CONNECT; table privileges come from the chart once the tables exist.
echo "Creating or updating app role $APP_PGUSER ..."
psql -X -v ON_ERROR_STOP=1 -d "$SERVICE_PGDB" \
  -v app_user="$APP_PGUSER" -v app_password="$APP_PGPASSWORD" -v owner_user="$SERVICE_PGUSER" <<'SQL'
SELECT format(
    'DO $$ BEGIN RAISE EXCEPTION ''%%'', %L; END $$',
    format('The app role (%s) must differ from the admin and table owner roles.', :'app_user')
)
WHERE :'app_user' IN (current_user, :'owner_user') \gexec
SELECT format(
    'DO $$ BEGIN RAISE EXCEPTION ''%%'', %L; END $$',
    format('Role %s exists and is SUPERUSER or BYPASSRLS; the app role must be neither.', :'app_user')
)
FROM pg_roles WHERE rolname = :'app_user' AND (rolsuper OR rolbypassrls) \gexec
SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS',
    :'app_user', :'app_password'
)
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'app_user') \gexec
SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'app_user', :'app_password') \gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), :'app_user') \gexec
SQL
{{- end }}
