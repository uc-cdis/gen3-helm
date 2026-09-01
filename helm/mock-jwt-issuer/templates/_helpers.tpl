{{/*
Name used for every resource in this chart. Deliberately independent of the
release name so the in-cluster DNS name (and therefore the issuer URL) stays
predictable.
*/}}
{{- define "mock-jwt-issuer.fullname" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "mock-jwt-issuer.labels" -}}
app.kubernetes.io/name: {{ include "mock-jwt-issuer.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ include "mock-jwt-issuer.fullname" . }}
{{- end }}

{{- define "mock-jwt-issuer.selectorLabels" -}}
app: {{ include "mock-jwt-issuer.fullname" . }}
{{- end }}

{{/*
The issuer URL this server advertises. Defaults to the cluster-local Service
DNS name; a port suffix is only added when the Service is not on port 80.
*/}}
{{- define "mock-jwt-issuer.issuer" -}}
{{- if .Values.issuer }}
{{- .Values.issuer | trimSuffix "/" }}
{{- else if eq (int .Values.service.port) 80 }}
{{- printf "http://%s.%s.svc.cluster.local" (include "mock-jwt-issuer.fullname" .) .Release.Namespace }}
{{- else }}
{{- printf "http://%s.%s.svc.cluster.local:%d" (include "mock-jwt-issuer.fullname" .) .Release.Namespace (int .Values.service.port) }}
{{- end }}
{{- end }}

{{/*
Where the private key comes from: a secret this chart creates when
jwtKeys.privateKey is set, otherwise an existing secret (fence's, by default).
*/}}
{{- define "mock-jwt-issuer.secretName" -}}
{{- if .Values.jwtKeys.privateKey }}
{{- printf "%s-jwt-keys" (include "mock-jwt-issuer.fullname" .) }}
{{- else }}
{{- required "set jwtKeys.existingSecret or jwtKeys.privateKey" .Values.jwtKeys.existingSecret }}
{{- end }}
{{- end }}

{{- define "mock-jwt-issuer.secretKey" -}}
{{- if .Values.jwtKeys.privateKey }}
{{- "jwt_private_key.pem" }}
{{- else }}
{{- required "set jwtKeys.existingSecretKey" .Values.jwtKeys.existingSecretKey }}
{{- end }}
{{- end }}
