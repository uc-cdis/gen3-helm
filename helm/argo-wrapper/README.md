# <no value>

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 Argo Wrapper Service

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"argo-wrapper"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| dataDog.enabled | bool | `false` |  |
| dataDog.env | string | `"dev"` |  |
| environment | string | `"default"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/argo-wrapper"` |  |
| image.tag | string | `""` |  |
| indexdAdminUser | string | `"fence"` |  |
| internalS3Bucket | string | `"argo-internal-bucket"` |  |
| livenessProbe.httpGet.path | string | `"/test"` |  |
| livenessProbe.httpGet.port | int | `8000` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| podAnnotations."gen3.io/network-ingress" | string | `"argo-wrapper"` |  |
| ports[0].containerPort | int | `8000` |  |
| ports[0].protocol | string | `"TCP"` |  |
| pvc | string | `"test-pvc"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| s3Bucket | string | `"argo-artifact-downloadable"` |  |
| scalingGroups[0].user1 | string | `"workflow1"` |  |
| scalingGroups[1].user2 | string | `"workflow2"` |  |
| scalingGroups[2].user3 | string | `"workflow3"` |  |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| volumeMounts[0].mountPath | string | `"/argo.json"` |  |
| volumeMounts[0].name | string | `"argo-config"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"argo.json"` |  |
| volumes[0].configMap.items[0].key | string | `"argo.json"` |  |
| volumes[0].configMap.items[0].path | string | `"argo.json"` |  |
| volumes[0].configMap.name | string | `"manifest-argo"` |  |
| volumes[0].name | string | `"argo-config"` |  |

