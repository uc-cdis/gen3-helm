# alloy

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for deploying Grafana Alloy

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | alloy | 0.9.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy.alloy.clustering.enabled | bool | `true` |  |
| alloy.alloy.configMap.key | string | `"config"` |  |
| alloy.alloy.configMap.name | string | `"alloy-gen3"` |  |
| alloy.alloy.extraPorts[0].name | string | `"faro"` |  |
| alloy.alloy.extraPorts[0].port | int | `12347` |  |
| alloy.alloy.extraPorts[0].protocol | string | `"TCP"` |  |
| alloy.alloy.extraPorts[0].targetPort | int | `12347` |  |
| alloy.alloyConfigmapData | string | `"logging {\n  level    = \"info\"\n  format   = \"json\"\n}\n\notelcol.exporter.otlp \"tempo\" {\n  client {\n    endpoint = \"http://grafana-tempo-distributor.monitoring:4317\"\n    tls {\n        insecure = true\n        insecure_skip_verify = true\n    }\n  }\n}\n\n// loki write endpoint\nloki.write \"endpoint\" {\n  endpoint {\n    url = \"http://grafana-loki-gateway.monitoring:80/loki/api/v1/push\"\n  }\n}\n\nfaro.receiver \"default\" {\n    server {\n      listen_address = \"0.0.0.0\"\n      listen_port = 12347\n      cors_allowed_origins = [\"*\"]\n    }\n\n    extra_log_labels = {\n      service = \"frontend-app\",\n      app_name = \"\",\n      app_environment = \"\",\n      app_namespace = \"\",\n      app_version = \"\",\n    }\n    output {\n        logs   = [loki.write.endpoint.receiver]\n        traces = [otelcol.exporter.otlp.tempo.input]\n    }\n}\n"` |  |
| alloy.ingress.annotations | object | `{}` |  |
| alloy.ingress.enabled | bool | `true` | Enables ingress for Alloy (Faro port) |
| alloy.ingress.faroPort | int | `12347` |  |
| alloy.ingress.hosts[0] | string | `"faro.example.com"` |  |
| alloy.ingress.ingressClassName | string | `"alb"` |  |
| alloy.ingress.labels | object | `{}` |  |
| alloy.ingress.path | string | `"/"` |  |
