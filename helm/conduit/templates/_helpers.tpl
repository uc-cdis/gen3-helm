{{/*
Expand the name of the chart.
*/}}
{{- define "conduit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "conduit.labels" -}}
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
{{- define "conduit.selectorLabels" -}}
{{- if .Values.selectorLabels }}
    {{- with .Values.selectorLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.selectorLabels" .)}}
{{- end }}
{{- end }}

{{/*
Selector for Services that must reach only the current leader. The leader
patches its own pod with this label, so the selector resolves to 0 or 1 pod.
Without leader election every replica is active and the label is never set.
*/}}
{{- define "conduit.activeSelectorLabels" -}}
{{ include "conduit.selectorLabels" . }}
{{- if .Values.leaderElection.enabled }}
{{ .Values.leaderElection.podLabelKey }}: {{ .Values.leaderElection.podLabelValue | quote }}
{{- end }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "conduit.serviceAccountName" -}}
{{- default "conduit-server" .Values.serviceAccount.name }}
{{- end }}

{{/*
Rendered server.json. Arbitrary server config passes through .Values.serverConfig;
listen addresses, the cert backend and leader election are owned by the chart
because the Deployment, Services and RBAC depend on them.
*/}}
{{- define "conduit.serverConfig" -}}
{{- $cfg := deepCopy .Values.serverConfig }}
{{- $_ := set $cfg "http_addr" (printf ":%d" (int .Values.ports.http)) }}
{{- $_ = set $cfg "grpc_addr" (printf ":%d" (int .Values.ports.grpc)) }}
{{- $_ = set $cfg "admin_addr" (printf ":%d" (int .Values.ports.admin)) }}
{{- $_ = set $cfg "cert_backend" "kubernetes" }}
{{- $_ = set $cfg "kubernetes" (dict "namespace" .Release.Namespace) }}
{{- $names := list (printf "conduit-service.%s.svc.cluster.local" .Release.Namespace) (printf "conduit-service.%s.svc" .Release.Namespace) "conduit-service" }}
{{- with .Values.grpcLoadBalancer.hostname }}
{{- $names = append $names . }}
{{- end }}
{{- $names = concat $names (default list .Values.serverConfig.server_names) | uniq }}
{{- $_ = set $cfg "server_names" $names }}
{{- $le := dict "enabled" .Values.leaderElection.enabled }}
{{- if .Values.leaderElection.enabled }}
{{- $le = dict "enabled" true "namespace" .Release.Namespace "lock_name" .Values.leaderElection.lockName "lease_duration" .Values.leaderElection.leaseDuration "renew_deadline" .Values.leaderElection.renewDeadline "retry_period" .Values.leaderElection.retryPeriod "pod_label_key" .Values.leaderElection.podLabelKey "pod_label_value" .Values.leaderElection.podLabelValue }}
{{- end }}
{{- $_ = set $cfg "leader_election" $le }}
{{- toPrettyJson $cfg }}
{{- end }}
