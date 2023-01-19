# sheepdog

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=flat-square)

A Helm chart for gen3 Sheepdog Service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.0 |
| file://../gen3-test-data-job | gen3-test-data-job | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"sheepdog"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| arboristUrl | string | `"http://arborist-service.default.svc.cluster.local"` |  |
| authNamespace | string | `"default"` |  |
| automountServiceAccountToken | bool | `false` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| dataDog.enabled | bool | `false` |  |
| dataDog.env | string | `"dev"` |  |
| ddEnv | string | `nil` |  |
| ddLogsInjection | string | `nil` |  |
| ddProfilingEnabled | string | `nil` |  |
| ddService | string | `nil` |  |
| ddTraceAgentHostname | string | `nil` |  |
| ddTraceEnabled | string | `nil` |  |
| ddTraceSampleRate | string | `nil` |  |
| ddVersion | string | `nil` |  |
| dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| fenceUrl | string | `"http://fence-service"` |  |
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
| image.repository | string | `"quay.io/cdis/sheepdog"` |  |
| image.tag | string | `"helm-test"` |  |
| indexdUrl | string | `"http://indexd-service"` |  |
| livenessProbe.httpGet.path | string | `"/_status?timeout=20"` |  |
| livenessProbe.httpGet.port | int | `80` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| podAnnotations."gen3.io/network-ingress" | string | `"sheepdog"` |  |
| ports[0].containerPort | int | `80` |  |
| ports[1].containerPort | int | `443` |  |
| postgres.database | string | `"sheepdog"` |  |
| postgres.db_create | string | `nil` |  |
| postgres.db_restore | bool | `false` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"sheepdog"` |  |
| readinessProbe.httpGet.path | string | `"/_status?timeout=2"` |  |
| readinessProbe.httpGet.port | int | `80` |  |
| readinessProbe.initialDelaySeconds | int | `30` |  |
| releaseLabel | string | `"production"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | float | `1` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | float | `0.3` |  |
| resources.requests.memory | string | `"12Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| secrets.fence.database | string | `"fence"` |  |
| secrets.fence.host | string | `"postgres-postgresql.postgres.svc.cluster.local"` |  |
| secrets.fence.password | string | `"postgres"` |  |
| secrets.fence.user | string | `"postgres"` |  |
| secrets.gdcapi.secretKey | string | `nil` |  |
| secrets.indexd.password | string | `"postgres"` |  |
| secrets.sheepdog.database | string | `"sheepdog"` |  |
| secrets.sheepdog.host | string | `"postgres-postgresql.postgres.svc.cluster.local"` |  |
| secrets.sheepdog.password | string | `"postgres"` |  |
| secrets.sheepdog.user | string | `"postgres"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| terminationGracePeriodSeconds | int | `50` |  |
| volumeMounts[0].mountPath | string | `"/var/www/sheepdog/wsgi.py"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"wsgi.py"` |  |
| volumeMounts[1].mountPath | string | `"/var/www/sheepdog/creds.json"` |  |
| volumeMounts[1].name | string | `"creds-volume"` |  |
| volumeMounts[1].readOnly | bool | `true` |  |
| volumeMounts[1].subPath | string | `"creds.json"` |  |
| volumeMounts[2].mountPath | string | `"/var/www/sheepdog/config_helper.py"` |  |
| volumeMounts[2].name | string | `"config-volume"` |  |
| volumeMounts[2].readOnly | bool | `true` |  |
| volumeMounts[2].subPath | string | `"config_helper.py"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
