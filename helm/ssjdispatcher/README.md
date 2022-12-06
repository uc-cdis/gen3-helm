# <no value>

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 ssjdispatcher

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"ssjdispatcher"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| automountServiceAccountToken | bool | `true` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| awsRegion | string | `"us-east-1"` |  |
| awsStsRegionalEndpoints | string | `"regional"` |  |
| dispatcherJobNum | string | `"10"` |  |
| fullnameOverride | string | `""` |  |
| gen3Namespace | string | `"default"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"nginx"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| indexing | string | `"707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/indexs3client:2022.08"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| labels.netnolimit | string | `"yes"` |  |
| labels.public | string | `"yes"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| resources.limits.cpu | float | `1` |  |
| resources.limits.memory | string | `"2400Mi"` |  |
| resources.requests.cpu | float | `0.1` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext | object | `{}` |  |
| selectorLabels.app | string | `"ssjdispatcher"` |  |
| selectorLabels.release | string | `"production"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.name | string | `"ssjdispatcher-service-account"` |  |
| ssjcreds.jobName | string | `"indexing"` |  |
| ssjcreds.jobPassword | string | `"replace_with_password"` |  |
| ssjcreds.jobPattern | string | `"s3://test-12345678901234-upload/*"` |  |
| ssjcreds.jobRequestCpu | string | `"500m"` |  |
| ssjcreds.jobRequestMem | string | `"0.5Gi"` |  |
| ssjcreds.jobUrl | string | `"http://indexd-service/index"` |  |
| ssjcreds.jobUser | string | `"ssj"` |  |
| ssjcreds.metadataservicePassword | string | `"replace_with_password"` |  |
| ssjcreds.metadataserviceUrl | string | `"http://revproxy-service/mds"` |  |
| ssjcreds.metadataserviceUsername | string | `"gateway"` |  |
| ssjcreds.sqsUrl | string | `"https://sqs.us-east-1.amazonaws.com/12345678901234/test-upload_data_upload"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/credentials.json"` |  |
| volumeMounts[0].name | string | `"ssjdispatcher-creds-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"credentials.json"` |  |
| volumes[0].name | string | `"ssjdispatcher-creds-volume"` |  |
| volumes[0].secret.secretName | string | `"ssjdispatcher-creds"` |  |

