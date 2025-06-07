# access-backend

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.1](https://img.shields.io/badge/AppVersion-1.6.1-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.16 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminUsers | string | `""` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].key | string | `"karpenter.sh/capacity-type"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator | string | `"In"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].values[0] | string | `"spot"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].key | string | `"eks.amazonaws.com/capacityType"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].operator | string | `"In"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].values[0] | string | `"SPOT"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].weight | int | `99` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"access-backend"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `25` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| debug | bool | `true` |  |
| externalSecrets | map | `{"createK8sMetadataSecret":false,"dbcreds":null,"metadataG3auto":null}` | External Secrets settings. |
| externalSecrets.createK8sMetadataSecret | string | `false` | Will create the Helm "metadata-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.dbcreds | string | `nil` | Will override the name of the aws secrets manager secret. Default is "Values.global.environment-.Chart.Name-creds" |
| externalSecrets.metadataG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "metadata-g3auto" |
| extraArgs | string | `"{\"endpoint_url\": \"http://dynamodb:8000\", \"region_name\": \"us-east-1\"}"` |  |
| fullnameOverride | string | `""` |  |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any metadata secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/access-backend"` |  |
| image.tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| metricsEnabled | bool | `false` |  |
| nameOverride | string | `""` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"2048Mi"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `false` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"access-backend-sa"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| superAdmins | string | `"jacobdaugherty@uchicago.edu"` |  |
| volumeMounts[0].mountPath | string | `"/src/.env"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"access-backend.env"` |  |
| volumeMounts[1].mountPath | string | `"/src/user.yaml"` |  |
| volumeMounts[1].name | string | `"config-volume"` |  |
| volumeMounts[1].readOnly | bool | `true` |  |
| volumeMounts[1].subPath | string | `"user.yaml"` |  |
