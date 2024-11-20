{{/*
  Templates for network policies that can be used by various subcharts
*/}}

{{- define "common.db_netpolicy" -}}
  {{- if .Values.global.netPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .Chart.Name }}-db-netpolicy
spec:
  egress:
  {{- range .Values.global.netPolicy.dbSubnets }}
  - to:
    - ipBlock:
        cidr: {{ . }}
  {{- end }}
  podSelector:
    matchLabels: 
      app: {{ .Chart.Name }}
  policyTypes:
  - Egress
  {{- end }}
{{- end }}

{{ define "common.ingress_netpolicy" -}}
  {{- if .Values.global.netPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .Chart.Name }}-ingress-netpolicy
spec:
  podSelector:
    matchLabels:
      app: {{ .Chart.Name }}
  ingress:
    - from:
      - podSelector:
          matchExpressions:
          - key: app
            operator: In
            values: {{ toYaml .Values.netPolicy.ingressApps | nindent 12 }}
  policyTypes:
   - Ingress
  {{- end }}
{{- end }}

{{ define "common.egress_netpolicy" -}}
  {{- if .Values.global.netPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .Chart.Name }}-egress-netpolicy
spec:
  podSelector:
    matchExpressions:
    - key: app
      operator: In
      values: {{ toYaml .Values.netPolicy.ingressApps | nindent 6 }} 
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: {{ .Chart.Name }}
  policyTypes:
   - Egress
  {{- end }}
{{- end }}