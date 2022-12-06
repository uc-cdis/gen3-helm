# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 arborist

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| env[0].name | string | `"JWKS_ENDPOINT"` |  |
| env[0].value | string | `"http://fence-service/.well-known/jwks"` |  |
| env[1].name | string | `"PGPASSWORD"` |  |
| env[1].valueFrom.secretKeyRef.key | string | `"password"` |  |
| env[1].valueFrom.secretKeyRef.name | string | `"arborist-dbcreds"` |  |
| env[1].valueFrom.secretKeyRef.optional | bool | `false` |  |
| env[2].name | string | `"PGUSER"` |  |
| env[2].valueFrom.secretKeyRef.key | string | `"username"` |  |
| env[2].valueFrom.secretKeyRef.name | string | `"arborist-dbcreds"` |  |
| env[2].valueFrom.secretKeyRef.optional | bool | `false` |  |
| env[3].name | string | `"PGDATABASE"` |  |
| env[3].valueFrom.secretKeyRef.key | string | `"database"` |  |
| env[3].valueFrom.secretKeyRef.name | string | `"arborist-dbcreds"` |  |
| env[3].valueFrom.secretKeyRef.optional | bool | `false` |  |
| env[4].name | string | `"PGHOST"` |  |
| env[4].valueFrom.secretKeyRef.key | string | `"host"` |  |
| env[4].valueFrom.secretKeyRef.name | string | `"arborist-dbcreds"` |  |
| env[4].valueFrom.secretKeyRef.optional | bool | `false` |  |
| env[5].name | string | `"PGPORT"` |  |
| env[5].valueFrom.secretKeyRef.key | string | `"port"` |  |
| env[5].valueFrom.secretKeyRef.name | string | `"arborist-dbcreds"` |  |
| env[5].valueFrom.secretKeyRef.optional | bool | `false` |  |
| env[6].name | string | `"PGSSLMODE"` |  |
| env[6].value | string | `"disable"` |  |
| fullnameOverride | string | `""` |  |
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
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/cdis/arborist"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgres.database | string | `"arborist"` |  |
| postgres.db_create | string | `nil` |  |
| postgres.host | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"arborist"` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts | string | `nil` |  |
| volumes[0].name | string | `"creds-volume"` |  |
| volumes[0].secret.secretName | string | `"arborist-dbcreds"` |  |

