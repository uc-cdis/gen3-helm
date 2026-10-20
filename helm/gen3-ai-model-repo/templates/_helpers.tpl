{{- define "gen3-ai-model-repo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gen3-ai-model-repo.labels" -}}
{{- if .Values.commonLabels }}{{ toYaml .Values.commonLabels }}{{ else }}{{ include "common.commonLabels" . }}{{ end }}
{{- end }}

{{- define "gen3-ai-model-repo.selectorLabels" -}}
{{- if .Values.selectorLabels }}{{ toYaml .Values.selectorLabels }}{{ else }}{{ include "common.selectorLabels" . }}{{ end }}
{{- end }}

{{- define "gen3-ai-model-repo.postgres.password" -}}
{{- $localpass := lookup "v1" "Secret" "postgres" "postgres-postgresql" -}}
{{- if $localpass }}{{ default (index $localpass.data "postgres-password" | b64dec) }}{{ else }}{{ default .Values.postgres.password }}{{ end }}
{{- end }}

{{- define "gen3aimodelrepo-g3auto" -}}
{{- default "gen3aimodelrepo-g3auto" .Values.externalSecrets.gen3AiModelRepoG3auto }}
{{- end }}
