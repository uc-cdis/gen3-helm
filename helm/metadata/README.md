# metadata

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=flat-square)

A Helm chart for gen3 Metadata Service

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
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"metadata"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| aggMdsNamespace | string | `nil` |  |
| args[0] | string | `"-c"` |  |
| args[1] | string | `"/env/bin/alembic upgrade head\n"` |  |
| automountServiceAccountToken | bool | `false` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| command[0] | string | `"/bin/sh"` |  |
| containerPort[0].containerPort | int | `80` |  |
| dataDog.enabled | bool | `false` |  |
| dataDog.env | string | `"dev"` |  |
| debug | bool | `false` |  |
| esEndpoint | string | `"gen3-elasticsearch:9200"` |  |
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
| image.repository | string | `"quay.io/cdis/metadata-service"` |  |
| image.tag | string | `"master"` |  |
| initContainerName | string | `"metadata-db-migrate"` |  |
| initResources.limits.cpu | float | `0.8` |  |
| initResources.limits.memory | string | `"512Mi"` |  |
| initVolumeMounts[0].mountPath | string | `"/src/.env"` |  |
| initVolumeMounts[0].name | string | `"config-volume-g3auto"` |  |
| initVolumeMounts[0].readOnly | bool | `true` |  |
| initVolumeMounts[0].subPath | string | `"metadata.env"` |  |
| livenessProbe.httpGet.path | string | `"/_status"` |  |
| livenessProbe.httpGet.port | int | `80` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| postgres.database | string | `"metadata"` |  |
| postgres.db_create | string | `nil` |  |
| postgres.db_restore | bool | `false` |  |
| postgres.host | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"metadata"` |  |
| readinessProbe.httpGet.path | string | `"/_status"` |  |
| readinessProbe.httpGet.port | int | `80` |  |
| releaseLabel | string | `"production"` |  |
| replicaCount | int | `1` |  |
| resources | string | `nil` |  |
| revisionHistoryLimit | int | `2` |  |
| service.port[0].name | string | `"http"` |  |
| service.port[0].port | int | `80` |  |
| service.port[0].protocol | string | `"TCP"` |  |
| service.port[0].targetPort | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAnnotations."getambassador.io/config" | string | `"---\napiVersion: ambassador/v1\nambassador_id: \"gen3\"\nkind:  Mapping\nname:  metadata_mapping\nprefix: /index/\nservice: http://metadata-service:80\n"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| useAggMds | string | `nil` |  |
| volumeMounts[0].mountPath | string | `"/src/.env"` |  |
| volumeMounts[0].name | string | `"config-volume-g3auto"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"metadata.env"` |  |
| volumeMounts[1].mountPath | string | `"/aggregate_config.json"` |  |
| volumeMounts[1].name | string | `"config-volume"` |  |
| volumeMounts[1].readOnly | bool | `true` |  |
| volumeMounts[1].subPath | string | `"aggregate_config.json"` |  |
| volumeMounts[2].mountPath | string | `"/metadata.json"` |  |
| volumeMounts[2].name | string | `"config-manifest"` |  |
| volumeMounts[2].readOnly | bool | `true` |  |
| volumeMounts[2].subPath | string | `"json"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
