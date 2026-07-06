{{- define "common.nginxSidecar.configmap" -}}
{{- $nginx := include "common.nginxSidecar.values" . | fromYaml -}}
{{- if $nginx.enabled }}
{{- $upstreamPort := coalesce .Values.service.targetPort .Values.service.port .Values.port -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ default (printf "%s-nginx-sidecar" .Chart.Name) $nginx.configMapName }}
data:
  default.conf: |
    server {
      listen {{ default 8443 $nginx.listenPort }}{{ if $nginx.tls.enabled }} ssl{{ end }};

      {{- if $nginx.tls.enabled }}
      ssl_certificate     /etc/nginx/tls/tls.crt;
      ssl_certificate_key /etc/nginx/tls/tls.key;
      {{- end }}

      location / {
        proxy_pass http://127.0.0.1:{{ $upstreamPort }};
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto {{ ternary "https" "http" $nginx.tls.enabled }};

        proxy_connect_timeout {{ default "5s" $nginx.proxyConnectTimeout }};
        proxy_send_timeout {{ default "60s" $nginx.proxySendTimeout }};
        proxy_read_timeout {{ default "60s" $nginx.proxyReadTimeout }};
      }
    }

    {{- if $nginx.metrics.enabled }}
    server {
      listen 127.0.0.1:{{ default 8081 $nginx.metrics.stubStatusPort }};

      location /stub_status {
        stub_status;
        access_log off;
        allow 127.0.0.1;
        deny all;
      }
    }
    {{- end }}
{{- end }}
{{- end }}