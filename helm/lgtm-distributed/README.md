# lgtm-distributed

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 6.59.4](https://img.shields.io/badge/AppVersion-6.59.4-informational?style=flat-square)

Umbrella chart for a distributed Loki, Grafana, Tempo and Mimir stack

**Homepage:** <https://grafana.com/oss/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| timberhill |  |  |

## Source Code

* <https://grafana.github.io/helm-charts>
* <https://github.com/grafana/grafana>
* <https://github.com/grafana/loki>
* <https://github.com/grafana/mimir>
* <https://github.com/grafana/tempo>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | grafana(grafana) | ^7.3.9 |
| https://grafana.github.io/helm-charts | loki(loki-distributed) | ^0.74.3 |
| https://grafana.github.io/helm-charts | mimir(mimir-distributed) | ^5.3.0 |
| https://grafana.github.io/helm-charts | tempo(tempo-distributed) | ^1.9.9 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| grafana.alerting."contactpoints.yaml".secret.apiVersion | int | `1` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].name | string | `"slack"` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].orgId | int | `1` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].receivers[0].settings.group | string | `"slack"` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].receivers[0].settings.summary | string | `"{{ `{{ include \"default.message\" . }}` }}\n"` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].receivers[0].settings.url | string | `"https://hooks.slack.com/services/XXXXXXXXXX"` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].receivers[0].type | string | `"Slack"` |  |
| grafana.alerting."contactpoints.yaml".secret.contactPoints[0].receivers[0].uid | string | `"first_uid"` |  |
| grafana.alerting."rules.yaml".apiVersion | int | `1` |  |
| grafana.alerting."rules.yaml".groups[0].folder | string | `"Alerts"` |  |
| grafana.alerting."rules.yaml".groups[0].interval | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].name | string | `"Alerts"` |  |
| grafana.alerting."rules.yaml".groups[0].orgId | int | `1` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].annotations.summary | string | `"Alert: HTTP 500 errors detected in the environment: {{`{{ $labels.clusters }}`}}"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.expr | string | `"sum by (cluster) (count_over_time({cluster=~\".+\"} | json | http_status_code=\"500\" [1h])) > 0"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].title | string | `"HTTP 500 errors detected"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[0].uid | string | `"edwb8zgcvq96oc"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].annotations.description | string | `"Error in usersync job detected in cluster {{`{{ $labels.clusters }}`}}, namespace {{`{{ $labels.namespace }}`}}."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].annotations.summary | string | `"Error Logs Detected in Usersync Job"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.expr | string | `"sum by (cluster, namespace) (count_over_time({ app=\"gen3job\", job_name=~\"usersync-.*\"} |= \"ERROR - could not revoke policies from user `N/A`\" [5m])) > 1"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].title | string | `"Error Logs Detected in Usersync Job"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[1].uid | string | `"adwb9vhb7irr4b"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].annotations.description | string | `"Panic detected in app {{`{{ $labels.app }}`}} within cluster {{`{{ $labels.clusters }}`}}."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].annotations.summary | string | `"Hatchery panic"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.expr | string | `"sum by (cluster) (count_over_time({app=\"hatchery\"} |= \"panic\" [5m])) > 1"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].title | string | `"Hatchery panic in {{`{{ env.name }}`}}"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[2].uid | string | `"ddwbc12l6wc8wf"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].annotations.description | string | `"Detected 431 HTTP status codes in the logs within the last 5 minutes."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].annotations.summary | string | `"Http status code 431"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.expr | string | `"sum(count_over_time({cluster=~\".+\"} | json | http_status_code=\"431\" [5m])) >= 2"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].title | string | `"Http status code 431"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[3].uid | string | `"cdwbcbphz1zb4a"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].annotations.description | string | `"High number of info status logs detected in the indexd service in cluster {{`{{ $labels.clusters }}`}}."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].annotations.summary | string | `"Indexd is getting an excessive amount of traffic"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.expr | string | `"sum by (cluster) (count_over_time({cluster=~\".+\", app=\"indexd\", status=\"info\"} [5m])) > 50000"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].title | string | `"Indexd is getting an excessive amount of traffic"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[4].uid | string | `"bdwbck1lgwdfka"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].annotations.description | string | `"More than 10 errors detected in the karpenter namespace in cluster {{`{{ $labels.clusters }}`}} related to providerRef not found."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].annotations.summary | string | `"Karpenter Resource Mismatch"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.expr | string | `"sum by (cluster) (count_over_time({namespace=\"karpenter\", cluster=~\".+\"} |= \"ERROR\" |= \"not found\" |= \"getting providerRef\" [5m])) > 10\n"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].title | string | `"Karpenter Resource Mismatch"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[5].uid | string | `"fdwbe5t439zpcd"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].annotations.description | string | `"More than 1000 \"limiting requests, excess\" errors detected in service {{`{{ $labels.app }}`}} (cluster: {{`{{ $labels.clusters }}`}}) within the last 5 minutes."` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].annotations.summary | string | `"Nginx is logging excessive \" limiting requests, excess:\""` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].condition | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].datasourceUid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.datasource.type | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.datasource.uid | string | `"loki"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.editorMode | string | `"code"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.expr | string | `"sum by (app, cluster) (count_over_time({app=~\".+\", cluster=~\".+\"} |= \"status:error\" |= \"limiting requests, excess:\" [5m])) > 1000"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.hide | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.intervalMs | int | `1000` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.maxDataPoints | int | `43200` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].model.refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].queryType | string | `"instant"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].refId | string | `"A"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].relativeTimeRange.from | int | `600` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].data[0].relativeTimeRange.to | int | `0` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].execErrState | string | `"KeepLast"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].for | string | `"5m"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].isPaused | bool | `false` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].labels | object | `{}` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].noDataState | string | `"OK"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].notification_settings.receiver | string | `"Slack"` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].title | string | `"Nginx is logging excessive \" limiting requests, excess:\""` |  |
| grafana.alerting."rules.yaml".groups[0].rules[6].uid | string | `"fdwbeuftc7400c"` |  |
| grafana.datasources | object | `{"datasources.yaml":{"apiVersion":1,"datasources":[{"isDefault":false,"name":"Loki","type":"loki","uid":"loki","url":"http://{{ .Release.Name }}-loki-gateway"},{"isDefault":true,"name":"Mimir","type":"prometheus","uid":"prom","url":"http://{{ .Release.Name }}-mimir-nginx/prometheus"},{"isDefault":false,"jsonData":{"lokiSearch":{"datasourceUid":"loki"},"serviceMap":{"datasourceUid":"prom"},"tracesToLogsV2":{"datasourceUid":"loki"},"tracesToMetrics":{"datasourceUid":"prom"}},"name":"Tempo","type":"tempo","uid":"tempo","url":"http://{{ .Release.Name }}-tempo-query-frontend:3100"}]}}` | Grafana data sources config. Connects to all three by default |
| grafana.datasources."datasources.yaml".datasources | list | `[{"isDefault":false,"name":"Loki","type":"loki","uid":"loki","url":"http://{{ .Release.Name }}-loki-gateway"},{"isDefault":true,"name":"Mimir","type":"prometheus","uid":"prom","url":"http://{{ .Release.Name }}-mimir-nginx/prometheus"},{"isDefault":false,"jsonData":{"lokiSearch":{"datasourceUid":"loki"},"serviceMap":{"datasourceUid":"prom"},"tracesToLogsV2":{"datasourceUid":"loki"},"tracesToMetrics":{"datasourceUid":"prom"}},"name":"Tempo","type":"tempo","uid":"tempo","url":"http://{{ .Release.Name }}-tempo-query-frontend:3100"}]` | Datasources linked to the Grafana instance. Override if you disable any components. |
| grafana.enabled | bool | `true` | Deploy Grafana if enabled. See [upstream readme](https://github.com/grafana/helm-charts/tree/main/charts/grafana#configuration) for full values reference. |
| loki.enabled | bool | `true` | Deploy Loki if enabled. See [upstream readme](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed#values) for full values reference. |
| mimir | object | `{"alertmanager":{"resources":{"requests":{"cpu":"20m"}}},"compactor":{"resources":{"requests":{"cpu":"20m"}}},"distributor":{"resources":{"requests":{"cpu":"20m"}}},"enabled":true,"ingester":{"replicas":2,"resources":{"requests":{"cpu":"20m"}},"zoneAwareReplication":{"enabled":false}},"minio":{"resources":{"requests":{"cpu":"20m"}}},"overrides_exporter":{"resources":{"requests":{"cpu":"20m"}}},"querier":{"replicas":1,"resources":{"requests":{"cpu":"20m"}}},"query_frontend":{"resources":{"requests":{"cpu":"20m"}}},"query_scheduler":{"replicas":1,"resources":{"requests":{"cpu":"20m"}}},"rollout_operator":{"resources":{"requests":{"cpu":"20m"}}},"ruler":{"resources":{"requests":{"cpu":"20m"}}},"store_gateway":{"resources":{"requests":{"cpu":"20m"}},"zoneAwareReplication":{"enabled":false}}}` | Mimir chart values. Resources are set to a minimum by default. |
| mimir.enabled | bool | `true` | Deploy Mimir if enabled. See [upstream values.yaml](https://github.com/grafana/mimir/blob/main/operations/helm/charts/mimir-distributed/values.yaml) for full values reference. |
| tempo.enabled | bool | `true` | Deploy Tempo if enabled.  See [upstream readme](https://github.com/grafana/helm-charts/blob/main/charts/tempo-distributed/README.md#values) for full values reference. |
| tempo.ingester.replicas | int | `3` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
