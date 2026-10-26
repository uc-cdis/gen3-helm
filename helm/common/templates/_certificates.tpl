{{- define "common.nginxSidecar.certificate" -}}
{{- $global := .Values.global.nginxSidecar | default dict -}}
{{- $local := .Values.nginxSidecar | default dict -}}
{{- $nginx := mergeOverwrite (deepCopy $global) $local -}}
{{- if and $nginx.enabled $nginx.tls.enabled }}
{{- $serviceName := coalesce $nginx.serviceName (printf "%s-service" .Chart.Name) -}}
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ $serviceName }}-nginx-sidecar
spec:
  secretName: {{ coalesce $nginx.tls.secretName (printf "%s-nginx-sidecar-tls" .Chart.Name) }}
  dnsNames:
    - {{ $serviceName }}
    - {{ $serviceName }}.{{ .Release.Namespace }}.svc
    - {{ $serviceName }}.{{ .Release.Namespace }}.svc.cluster.local
  issuerRef:
    name: {{ default "gen3-internal-ca" $nginx.tls.issuerRef.name }}
    kind: {{ default "Issuer" $nginx.tls.issuerRef.kind }}
{{- end }}
{{- end }}