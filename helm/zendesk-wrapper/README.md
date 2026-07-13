# zendesk-wrapper

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 Zendesk Wrapper Service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.38 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"zendesk-wrapper"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| autoscaling | object | `{}` |  |
| commonLabels | string | `nil` |  |
| criticalService | string | `"false"` |  |
| env | map | `[{"name":"GEN3_ZENDESK_URL","value":""}]` | Environment variables for the Zendesk wrapper service |
| env[0] | string | `{"name":"GEN3_ZENDESK_URL","value":""}` | Zendesk instance URL (e.g., https://gen3support.zendesk.com) |
| externalSecrets | map | `{"name":"zendesk-wrapper-secret"}` | Secret environment variables (referenced from Kubernetes secrets) |
| externalSecrets.name | string | `"zendesk-wrapper-secret"` | Name of the Kubernetes secret containing the Zendesk API token |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `10` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.environment | string | `"default"` |  |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any zendesk wrapper secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.minAvailable | int | `1` |  |
| global.netPolicy.dbSubnet | string | `""` |  |
| global.netPolicy.enabled | bool | `false` |  |
| global.pdb | bool | `false` |  |
| global.topologySpread.enabled | bool | `false` |  |
| global.topologySpread.maxSkew | int | `1` |  |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/zendesk-wrapper-service"` |  |
| image.tag | string | `""` |  |
| metricsEnabled | string | `nil` |  |
| netPolicy.egressApps[0] | string | `"zendesk-wrapper"` |  |
| netPolicy.ingressApps[0] | string | `"zendesk-wrapper"` |  |
| partOf | string | `"Core-Service"` |  |
| podAnnotations."gen3.io/network-ingress" | string | `"zendesk-wrapper"` |  |
| release | string | `"production"` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| selectorLabels | string | `nil` |  |
| service.httpPort | int | `80` | Port on which the service is exposed |
| service.httpsPort | int | `443` | Secure port on which the service is exposed |
| service.targetPort | int | `80` | Port on which the service is exposed for Zendesk wrapper API |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
