{{/* Whether a one-time Job should be skipped: global.skipExistingJobs is set and the Job already exists */}}
{{- define "common.job.exists" -}}
{{- if .ctx.Values.global.skipExistingJobs }}
{{- if lookup "batch/v1" "Job" .ctx.Release.Namespace .name }}true{{- end }}
{{- end }}
{{- end }}
