# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 Requestor Service

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"requestor"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| arboristUrl | string | `"http://arborist-service"` |  |
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
| global.ddEnabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| global.dispatcherJobNum | int | `10` |  |
| global.environment | string | `"default"` |  |
| global.hostname | string | `"localhost"` |  |
| global.kubeBucket | string | `"kube-gen3"` |  |
| global.logsBucket | string | `"logs-gen3"` |  |
| global.netPolicy | string | `"on"` |  |
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
| image.repository | string | `"quay.io/cdis/requestor"` |  |
| image.tag | string | `"feat_dbenvvar"` |  |
| initContainerName | string | `"requestor-db-migrate"` |  |
| initResources.limits.cpu | float | `0.8` |  |
| initResources.limits.memory | string | `"512Mi"` |  |
| livenessProbe.httpGet.path | string | `"/_status"` |  |
| livenessProbe.httpGet.port | int | `80` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| postgres.database | string | `"requestor"` |  |
| postgres.db_create | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"requestor"` |  |
| readinessProbe.httpGet.path | string | `"/_status"` |  |
| readinessProbe.httpGet.port | int | `80` |  |
| releaseLabel | string | `"production"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | float | `0.8` |  |
| resources.limits.memory | string | `"1024Mi"` |  |
| resources.requests.cpu | float | `0.1` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| service.port[0].name | string | `"http"` |  |
| service.port[0].port | int | `80` |  |
| service.port[0].protocol | string | `"TCP"` |  |
| service.port[0].targetPort | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| volumeMounts | string | `nil` |  |

