# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for Kubernetes

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"manifestservice"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| automountServiceAccountToken | bool | `false` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| env[0].name | string | `"REQUESTS_CA_BUNDLE"` |  |
| env[0].value | string | `"/etc/ssl/certs/ca-certificates.crt"` |  |
| env[1].name | string | `"MANIFEST_SERVICE_CONFIG_PATH"` |  |
| env[1].value | string | `"/var/gen3/config/config.json"` |  |
| env[2].name | string | `"GEN3_DEBUG"` |  |
| env[2].value | string | `"False"` |  |
| labels.public | string | `"yes"` |  |
| labels.s3 | string | `"yes"` |  |
| labels.userhelper | string | `"yes"` |  |
| manifestserviceG3auto.awsaccesskey | string | `""` |  |
| manifestserviceG3auto.awssecretkey | string | `""` |  |
| manifestserviceG3auto.bucketName | string | `"testbucket"` |  |
| manifestserviceG3auto.hostname | string | `"testinstall"` |  |
| manifestserviceG3auto.prefix | string | `"test"` |  |
| resources.limits.cpu | float | `1` |  |
| resources.limits.memory | string | `"1024Mi"` |  |
| resources.requests.cpu | float | `0.5` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| selectorLabels.app | string | `"manifestservice"` |  |
| selectorLabels.release | string | `"production"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| terminationGracePeriodSeconds | int | `50` |  |
| volumeMounts[0].mountPath | string | `"/var/gen3/config/"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumes[0].name | string | `"config-volume"` |  |
| volumes[0].secret.secretName | string | `"manifestservice-g3auto"` |  |

