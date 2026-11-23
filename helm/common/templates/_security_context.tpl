{{/*
Render a pod or container securityContext.

On OpenShift (the security.openshift.io API is present) runAsUser, runAsGroup and
fsGroup are dropped so the restricted-v2 SCC assigns IDs from the namespace's
UID range; hardcoded IDs are rejected when they fall outside that range.
On other clusters (EKS, GKE, kind) the map is rendered unchanged.

Usage:
  securityContext:
    {{- include "common.securityContext" (dict "ctx" . "sc" .Values.securityContext) | nindent 12 }}
*/}}
{{- define "common.securityContext" -}}
{{- $sc := deepCopy (.sc | default dict) -}}
{{- if .ctx.Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
{{- $_ := unset $sc "runAsUser" -}}
{{- $_ := unset $sc "runAsGroup" -}}
{{- $_ := unset $sc "fsGroup" -}}
{{- end -}}
{{- toYaml $sc -}}
{{- end -}}
