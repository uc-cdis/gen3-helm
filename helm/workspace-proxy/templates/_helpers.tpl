{{/*
Username hash algorithm for per-user resource names. A chart-level usernameHash
wins; otherwise follow global.usernameHash (shared with hatchery).
*/}}
{{- define "workspace-proxy.usernameHash" -}}
{{- if kindIs "invalid" .Values.usernameHash -}}
{{- .Values.global.usernameHash | default "" -}}
{{- else -}}
{{- .Values.usernameHash -}}
{{- end -}}
{{- end -}}
