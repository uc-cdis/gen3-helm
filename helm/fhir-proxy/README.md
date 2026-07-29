# fhir-proxy

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: dev](https://img.shields.io/badge/AppVersion-dev-informational?style=flat-square)

A Helm chart for gen3 FHIR proxy Service

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"fhir-proxy"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| commonLabels.app | string | `"fhir-proxy"` |  |
| config.arboristUrl | string | `"http://arborist-service"` |  |
| config.debug | bool | `true` |  |
| config.debugSkipAuth | bool | `false` |  |
| config.enableOpenTelemetryTraces | bool | `false` |  |
| config.enablePrometheusMetrics | bool | `true` |  |
| config.fhirServerUrl | string | `"http://host.docker.internal:8080"` |  |
| config.isUpstreamCallerTrustedReverseProxy | bool | `true` |  |
| config.otelExporterOtlpEndpoint | string | `"http://127.0.0.1:4318"` |  |
| config.prometheusMultiprocDir | string | `"/var/tmp/prometheus_metrics"` |  |
| config.urlPrefix | string | `"/fhir"` |  |
| criticalService | string | `"false"` |  |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `3` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.environment | string | `"default"` |  |
| global.minAvailable | int | `1` |  |
| global.netPolicy.dbSubnet | string | `""` |  |
| global.netPolicy.enabled | bool | `false` |  |
| global.pdb | bool | `false` |  |
| global.topologySpread.enabled | bool | `false` |  |
| global.topologySpread.maxSkew | int | `1` |  |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| image.pullPolicy | string | `"Never"` |  |
| image.repository | string | `"fhir-proxy"` |  |
| image.tag | string | `"dev"` |  |
| metricsEnabled | bool | `true` |  |
| netPolicy.egressApps[0] | string | `"arborist"` |  |
| netPolicy.ingressApps[0] | string | `"revproxy"` |  |
| partOf | string | `"backend"` |  |
| podAnnotations | object | `{}` |  |
| release | string | `"dev"` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| selectorLabels.app | string | `"fhir-proxy"` |  |
| service.port | int | `8007` |  |
| service.targetPort | int | `8007` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |
