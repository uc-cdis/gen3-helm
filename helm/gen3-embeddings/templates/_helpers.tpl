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
  Gen3Embeddings g3 Auto Secrets Manager Name
*/}}
{{- define "gen3embeddings-g3auto" -}}
{{- default "gen3embeddings-g3auto" .Values.externalSecrets.gen3EmbeddingsG3auto }}
{{- end }}

{{/*
  Name of the Secret holding secret values projected into the container environment, and the
  Secrets Manager key it is populated from.
*/}}
{{- define "gen3-embeddings.envSecretName" -}}
{{- default (printf "%s-env-secret" (include "gen3-embeddings.name" .)) .Values.externalSecrets.gen3EmbeddingsEnvSecret }}
{{- end }}

{{/*
  Admin credential in "gateway:<password>" form.

  Reused from the existing gen3embeddings-g3auto Secret when one is present, so that the password
  does not rotate on every `helm upgrade` and the deployment's checksum/config annotation only
  changes when configuration actually changes. `lookup` returns nothing during `helm template`,
  so a bare render still produces a fresh password every time; stability only holds against a
  live cluster.

  The round trip is asymmetric and easy to break: base64Authz.txt is written as
  `quote | b64enc`, Kubernetes base64-encodes that again on the way in, and the quote marks end
  up inside the encoded text. So recovering the credential means decoding twice and then
  stripping the quotes that decoding reveals.
*/}}
{{- define "gen3-embeddings.adminLogins" -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace "gen3embeddings-g3auto" -}}
{{- if and $existing (hasKey $existing.data "base64Authz.txt") -}}
{{- index $existing.data "base64Authz.txt" | b64dec | b64dec | trimAll "\"" -}}
{{- else -}}
{{- printf "gateway:%s" (randAlphaNum 32) -}}
{{- end -}}
{{- end }}
