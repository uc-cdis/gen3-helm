# gen3-ai-model-repo

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: main](https://img.shields.io/badge/AppVersion-main-informational?style=flat-square)

A Helm chart for the Gen3 AI model repository service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.39 |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| automountServiceAccountToken | bool | `false` |  |
| autoscaling | object | `{}` |  |
| commonLabels | string | `nil` |  |
| criticalService | string | `"false"` |  |
| debug | bool | `false` |  |
| env[0].name | string | `"GEN3_DEBUG"` |  |
| env[0].value | string | `"false"` |  |
| env[1].name | string | `"GUNICORN_WORKERS"` |  |
| env[1].value | string | `"2"` |  |
| externalSecrets.createK8sGen3AiModelRepoSecret | bool | `false` |  |
| externalSecrets.dbcreds | string | `nil` |  |
| externalSecrets.gen3AiModelRepoG3auto | string | `nil` |  |
| externalSecrets.pushSecret | bool | `false` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.externalSecrets.createLocalK8sSecret | bool | `false` |  |
| global.externalSecrets.deploy | bool | `false` |  |
| global.externalSecrets.separateSecretStore | bool | `false` |  |
| global.postgres.dbCreate | bool | `true` |  |
| global.postgres.externalSecret | string | `""` |  |
| global.postgres.master.host | string | `""` |  |
| global.postgres.master.password | string | `""` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| global.topologySpread.enabled | bool | `false` |  |
| gunicornWorkers | int | `2` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/gen3_ai_model_repo"` |  |
| image.tag | string | `"main"` |  |
| metricsEnabled | string | `nil` |  |
| nameOverride | string | `""` |  |
| partOf | string | `"AI"` |  |
| postgres.database | string | `nil` |  |
| postgres.dbCreate | string | `nil` |  |
| postgres.dbRestore | bool | `false` |  |
| postgres.host | string | `nil` |  |
| postgres.password | string | `nil` |  |
| postgres.port | string | `"5432"` |  |
| postgres.separate | bool | `false` |  |
| postgres.username | string | `nil` |  |
| postgresql.primary.persistence.enabled | bool | `false` |  |
| release | string | `"production"` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| revisionHistoryLimit | int | `3` |  |
| selectorLabels | string | `nil` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| storage.localPath | string | `"/data/models"` |  |
| storage.provider | string | `"local"` |  |
| volumeMounts | list | `[]` |  |
