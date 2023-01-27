# audit

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"audit"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| autoscaling.enabled | string | `"enabled"` |  |
| autoscaling.maxReplicas | int | `4` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| env[0].name | string | `"DEBUG"` |  |
| env[0].value | string | `"false"` |  |
| env[1].name | string | `"ARBORIST_URL"` |  |
| env[1].valueFrom.configMapKeyRef.key | string | `"arborist_url"` |  |
| env[1].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| env[1].valueFrom.configMapKeyRef.optional | bool | `true` |  |
| fullnameOverride | string | `""` |  |
| global.ddEnabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| global.dispatcherJobNum | int | `10` |  |
| global.environment | string | `"default"` |  |
| global.hostname | string | `"localhost"` |  |
| global.kubeBucket | string | `"kube-gen3"` |  |
| global.logsBucket | string | `"logs-gen3"` |  |
| global.netPolicy | bool | `true` |  |
| global.portalApp | string | `"gitops"` |  |
| global.postgres.db_create | bool | `true` |  |
| global.postgres.master.host | string | `nil` |  |
| global.postgres.master.password | string | `nil` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| global.publicDataSets | bool | `true` |  |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` |  |
| global.syncFromDbgap | bool | `false` |  |
| global.tierAccessLevel | string | `"libre"` |  |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/audit-service"` |  |
| image.tag | string | `"master"` |  |
| imagePullSecrets | list | `[]` |  |
| initEnv | object | `{}` |  |
| initVolumeMounts[0].mountPath | string | `"/src/audit-service-config.yaml"` |  |
| initVolumeMounts[0].name | string | `"config-volume"` |  |
| initVolumeMounts[0].readOnly | bool | `true` |  |
| initVolumeMounts[0].subPath | string | `"audit-service-config.yaml"` |  |
| labels."tags.datadoghq.com/service" | string | `"audit"` |  |
| labels.app | string | `"audit"` |  |
| labels.authprovider | string | `"yes"` |  |
| labels.netnolimit | string | `"yes"` |  |
| labels.public | string | `"yes"` |  |
| labels.release | string | `"production"` |  |
| labels.userhelper | string | `"yes"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgres.database | string | `"audit"` |  |
| postgres.db_create | string | `nil` |  |
| postgres.host | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"audit"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | float | `1` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | float | `0.1` |  |
| resources.requests.memory | string | `"12Mi"` |  |
| secrets.sqs.region | string | `"us-east-1"` |  |
| secrets.sqs.url | string | `"http://sqs.com"` |  |
| securityContext | object | `{}` |  |
| selectorLabels.app | string | `"audit"` |  |
| server.debug | bool | `false` |  |
| server.pull_from_queue | bool | `false` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::707767160287:role/gen3_service/emalinowskiv1--default--audit-sqs-sender"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"audit-service-sa"` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/src/audit-service-config.yaml"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"audit-service-config.yaml"` |  |
| volumes[0].name | string | `"config-volume"` |  |
| volumes[0].secret.secretName | string | `"audit-g3auto"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
