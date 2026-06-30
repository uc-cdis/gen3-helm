{{- define "common.nginxSidecar.values" -}}
{{- $global := .Values.global.nginxSidecar | default dict -}}
{{- $local := .Values.nginxSidecar | default dict -}}
{{- mergeOverwrite (deepCopy $global) $local | toYaml -}}
{{- end }}

{{- define "common.nginxSidecar.enabled" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled }}true{{- end -}}
{{- end }}

{{- define "common.nginxSidecar.targetPortName" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled -}}
https-sidecar
{{- else -}}
http
{{- end -}}
{{- end }}

{{- define "common.nginxSidecar.servicePortName" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end }}

{{- define "common.nginxSidecar.scheme" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if and $nginx.enabled $nginx.tls.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end }}

{{- define "common.nginxSidecar.upstreamScheme" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if and $nginx.enabled $nginx.tls.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end }}

{{- define "common.nginxSidecar.annotations" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if and $nginx.enabled $nginx.metrics.enabled }}
k8s.grafana.com/scrape: "true"
k8s.grafana.com/metrics.portName: "nginx-metrics"
k8s.grafana.com/metrics.path: "/metrics"
{{- end }}
{{- end }}

{{- define "common.nginxSidecar.volumes" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled }}
- name: nginx-sidecar-config
  configMap:
    name: {{ default (printf "%s-nginx-sidecar" .Chart.Name) $nginx.configMapName }}
- name: nginx-sidecar-cache
  emptyDir: {}
- name: nginx-sidecar-run
  emptyDir: {}
{{- if $nginx.tls.enabled }}
- name: nginx-sidecar-tls
  secret:
    secretName: {{ default (printf "%s-nginx-sidecar-tls" .Chart.Name) $nginx.tls.secretName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "common.nginxSidecar.containers" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled }}
- name: nginx-sidecar
  image: {{ default "nginx:1.27-alpine" $nginx.image | quote }}
  imagePullPolicy: {{ default "IfNotPresent" $nginx.imagePullPolicy }}
  ports:
    - name: https-sidecar
      containerPort: {{ default 8443 $nginx.listenPort }}
      protocol: TCP
    {{- if $nginx.metrics.enabled }}
    - name: nginx-status
      containerPort: {{ default 8081 $nginx.metrics.stubStatusPort }}
      protocol: TCP
    {{- end }}
  volumeMounts:
    - name: nginx-sidecar-config
      mountPath: /etc/nginx/conf.d
    {{- if $nginx.tls.enabled }}
    - name: nginx-sidecar-tls
      mountPath: /etc/nginx/tls
      readOnly: true
    {{- end }}
    - name: nginx-sidecar-cache
      mountPath: /var/cache/nginx
    - name: nginx-sidecar-run
      mountPath: /var/run    
  {{- with $nginx.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}

{{- if $nginx.metrics.enabled }}
- name: nginx-prometheus-exporter
  image: {{ default "nginx/nginx-prometheus-exporter:1.4.2" $nginx.metrics.image | quote }}
  imagePullPolicy: {{ default "IfNotPresent" $nginx.metrics.imagePullPolicy }}
  args:
    - -nginx.scrape-uri=http://127.0.0.1:{{ default 8081 $nginx.metrics.stubStatusPort }}/stub_status
  ports:
    - name: nginx-metrics
      containerPort: {{ default 9113 $nginx.metrics.port }}
      protocol: TCP
  {{- with $nginx.metrics.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}