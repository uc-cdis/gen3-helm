{{- define "dataUploadCron.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dataUploadCron.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "dataUploadCron.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "dataUploadCron.labels" -}}
app.kubernetes.io/name: {{ include "dataUploadCron.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "dataUploadCron.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "dataUploadCron.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "dataUploadCron.stateConfigMapName" -}}
{{- default (printf "%s-state" (include "dataUploadCron.fullname" .)) .Values.configmaps.state.name -}}
{{- end -}}

{{- define "dataUploadCron.pendingConfigMapName" -}}
{{- default (printf "%s-pending" (include "dataUploadCron.fullname" .)) .Values.configmaps.pending.name -}}
{{- end -}}

{{- define "dataUploadCron.slackSecretName" -}}
{{- default (printf "%s-slack" (include "dataUploadCron.fullname" .)) .Values.slack.secretName -}}
{{- end -}}
