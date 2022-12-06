# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 indexd

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
| db_create | bool | `true` |  |
| env[0].name | string | `"GEN3_DEBUG"` |  |
| env[0].value | string | `"False"` |  |
| fullnameOverride | string | `""` |  |
| global.dev | bool | `true` |  |
| global.postgres.master.host | string | `nil` |  |
| global.postgres.master.password | string | `nil` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/cdis/indexd"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgres.database | string | `"indexd"` |  |
| postgres.db_restore | bool | `false` |  |
| postgres.host | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.username | string | `"indexd"` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| secrets.userdb.fence | string | `nil` |  |
| secrets.userdb.gateway | string | `nil` |  |
| secrets.userdb.gdcapi | string | `nil` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/var/www/indexd/local_settings.py"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"local_settings.py"` |  |
| volumes[0].name | string | `"config-volume"` |  |
| volumes[0].secret.secretName | string | `"indexd-settings"` |  |
| volumes[1].name | string | `"creds-volume"` |  |
| volumes[1].secret.secretName | string | `"indexd-creds"` |  |

