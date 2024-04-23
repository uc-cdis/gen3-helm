{{/*
  Postgres service secret lookup. 
  Usage:
    {{ include "gen3.service-postgres" (dict "key" "password" "service" "fence" "context" $) }}


  Params:
  - key - String - Required - Name of the key in the secret.
  - service - String - Which service are you looking up secret for? 
  - context - Context - Required - Parent context.


 Lookups for postgres service secret is done in this order, until it finds a value:
  - Secret provided via `.Values.postgres` (Can be database, username, password, host, port)
  - Lookup secret `{{service}}-dbcreds` with key `password` 
  - Generate a random string, as we can assume this is a fresh install at that point.
 
*/}}
{{- define "gen3.service-postgres" -}}
  {{- $chartName := default "" .context.Chart.Name }}
  {{- $valuesPostgres := get .context.Values.postgres .key }}
  {{- $localSecretPass := "" }}
  {{- $secretData := (lookup "v1" "Secret" $.context.Release.Namespace (printf "%s-%s" $chartName "dbcreds")).data }}
  {{- if $secretData }}
    {{- if hasKey $secretData .key }}
      {{- $localSecretPass = index $secretData .key | b64dec }}
    {{- else }}
      {{- printf "\nERROR: The secret \"%s\" does not contain the key \"%s\"\n" (printf "%s-%s" $chartName "dbcreds") .key | fail -}}
    {{- end }}
  {{- end }}
  {{- $randomPassword := "" }}
  {{- $valuesGlobalPostgres := get .context.Values.global.postgres.master .key}}
  {{- if eq .key "password" }}
    {{- $randomPassword = randAlphaNum 20 }}
    {{- $valuesGlobalPostgres = "" }}
  {{- end }}
  {{- $value := coalesce $valuesPostgres $localSecretPass $randomPassword $valuesGlobalPostgres}}
  {{- printf "%v" $value -}}
{{- end }}


{{/*
Postgres Master Secret Lookup

Usage:
    {{ include "gen3.master-postgres" (dict "key" "database" "context" $) }}

 Lookups for secret is done in this order, until it finds a value:
  - Secret provided via `.Values.global.master.postgres` (Can be database, username, password, host, port)
  - Lookup secret `postgres-postgresql` with property `postgres-password` in `postgres` namespace. (This is for develop installation of gen3)
 

 # https://helm.sh/docs/chart_template_guide/function_list/#coalesce
*/}}
{{- define "gen3.master-postgres" }}
  {{- $chartName := .context.Chart.Name }}
  
  {{- $valuesPostgres := get .context.Values.global.postgres.master .key}}
  {{- $secret :=  (lookup "v1" "Secret" "default" "gen3-postgresql" )}}
  {{- $devPostgresSecret := "" }}
  {{-  if $secret }}
    {{- $devPostgresSecret = (index $secret "data" "postgres-password") | b64dec }}
  {{- end }}
  {{- $value := coalesce $valuesPostgres $devPostgresSecret  }}
  {{- printf "%v" $value -}}
{{- end }}


