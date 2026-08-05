# vectis-overlays

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Vectis overlay API services (guppy-compat, siem, search-auth-proxy)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.34 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.externalSecrets.clusterSecretStoreRef | string | `""` |  |
| guppyCompat.enabled | bool | `false` |  |
| guppyCompat.env.GUPPY_COMPAT_MAX_LIMIT | string | `"5000"` |  |
| guppyCompat.image.pullPolicy | string | `"Always"` |  |
| guppyCompat.image.repository | string | `"quay.io/cdis/gen3-vectis"` |  |
| guppyCompat.image.tag | string | `"guppy-compat-v1"` |  |
| guppyCompat.replicaCount | int | `1` |  |
| guppyCompat.resources.limits.cpu | string | `"500m"` |  |
| guppyCompat.resources.limits.memory | string | `"512Mi"` |  |
| guppyCompat.resources.requests.cpu | string | `"50m"` |  |
| guppyCompat.resources.requests.memory | string | `"128Mi"` |  |
| guppyCompat.serviceAccount.annotations | object | `{}` |  |
| guppyCompat.serviceAccount.create | bool | `true` |  |
| guppyCompat.serviceAccount.name | string | `"guppy-compat-service"` |  |
| migrations.enabled | bool | `false` |  |
| rds.database | string | `"postgres"` |  |
| rds.endpoint | string | `""` |  |
| rds.port | string | `"5432"` |  |
| rds.secretName | string | `""` |  |
| s3Monitor.aws.region | string | `"us-east-1"` |  |
| s3Monitor.db.database | string | `"postgres"` |  |
| s3Monitor.db.host | string | `""` |  |
| s3Monitor.db.port | string | `"5432"` |  |
| s3Monitor.db.schema | string | `"vectis"` |  |
| s3Monitor.db.secretName | string | `""` |  |
| s3Monitor.db.secretTargetName | string | `"s3-monitor-db-creds"` |  |
| s3Monitor.db.table | string | `"s3_metadata"` |  |
| s3Monitor.enabled | bool | `false` |  |
| s3Monitor.failedJobsHistoryLimit | int | `1` |  |
| s3Monitor.image.pullPolicy | string | `"IfNotPresent"` |  |
| s3Monitor.image.repository | string | `"python"` |  |
| s3Monitor.image.tag | string | `"3.11-slim"` |  |
| s3Monitor.initImage.pullPolicy | string | `"IfNotPresent"` |  |
| s3Monitor.initImage.repository | string | `"busybox"` |  |
| s3Monitor.initImage.tag | string | `"1.36"` |  |
| s3Monitor.resources.limits.cpu | string | `"500m"` |  |
| s3Monitor.resources.limits.memory | string | `"512Mi"` |  |
| s3Monitor.resources.requests.cpu | string | `"50m"` |  |
| s3Monitor.resources.requests.memory | string | `"128Mi"` |  |
| s3Monitor.s3.bucket | string | `""` |  |
| s3Monitor.s3.prefix | string | `""` |  |
| s3Monitor.schedule | string | `"*/5 * * * *"` |  |
| s3Monitor.serviceAccount.annotations | object | `{}` |  |
| s3Monitor.serviceAccount.create | bool | `true` |  |
| s3Monitor.serviceAccount.name | string | `"s3-monitor-sa"` |  |
| s3Monitor.successfulJobsHistoryLimit | int | `3` |  |
| searchAuthProxy.apiGateway.apiId | string | `""` |  |
| searchAuthProxy.apiGateway.region | string | `"us-east-1"` |  |
| searchAuthProxy.appDsnSecretName | string | `""` |  |
| searchAuthProxy.enabled | bool | `true` |  |
| searchAuthProxy.env.SEARCH_API_TLS_VERIFY | string | `""` |  |
| searchAuthProxy.env.SEARCH_PROXY_DEFAULT_LIMIT | string | `"50"` |  |
| searchAuthProxy.env.SEARCH_PROXY_MAX_LIMIT | string | `"1000"` |  |
| searchAuthProxy.hostAliases | list | `[]` |  |
| searchAuthProxy.image.pullPolicy | string | `"Always"` |  |
| searchAuthProxy.image.repository | string | `"quay.io/cdis/gen3-vectis"` |  |
| searchAuthProxy.image.tag | string | `"search-auth-proxy-v1"` |  |
| searchAuthProxy.postgresDsnSecretRef.key | string | `"postgres_dsn"` |  |
| searchAuthProxy.postgresDsnSecretRef.name | string | `"vectis-search-auth-proxy"` |  |
| searchAuthProxy.replicaCount | int | `1` |  |
| searchAuthProxy.resources.limits.cpu | string | `"500m"` |  |
| searchAuthProxy.resources.limits.memory | string | `"512Mi"` |  |
| searchAuthProxy.resources.requests.cpu | string | `"50m"` |  |
| searchAuthProxy.resources.requests.memory | string | `"128Mi"` |  |
| searchAuthProxy.serviceAccount.annotations | object | `{}` |  |
| searchAuthProxy.serviceAccount.create | bool | `true` |  |
| searchAuthProxy.serviceAccount.name | string | `"search-auth-proxy"` |  |
| searchAuthProxy.serviceName | string | `"search-auth-proxy"` |  |
| searchAuthProxy.siemBackend.baseUrl | string | `""` |  |
| searchAuthProxy.siemBackend.indexes | string | `"security_event,audit_event,threat_indicator"` |  |
| searchAuthProxy.siemBackend.searchApiRequireSigv4 | string | `"true"` |  |
| searchAuthProxy.siemBackend.siemRequireSigv4 | string | `"auto"` |  |
| searchAuthProxy.snapshotsBucket | string | `""` |  |
| searchAuthProxy.snapshotsKeyPrefix | string | `"snapshots/"` |  |
| siemService.enabled | bool | `true` |  |
| siemService.env.DB_SCHEMA | string | `"vectis"` |  |
| siemService.env.SIEM_DEFAULT_LIMIT | string | `"250"` |  |
| siemService.env.SIEM_MAX_LIMIT | string | `"2000"` |  |
| siemService.env.SIEM_VIEWS_S3_BUCKET | string | `""` |  |
| siemService.env.SIEM_VIEWS_S3_ENABLED | string | `"false"` |  |
| siemService.env.SIEM_VIEWS_S3_KEY | string | `"siem/views.json"` |  |
| siemService.image.pullPolicy | string | `"Always"` |  |
| siemService.image.repository | string | `"quay.io/cdis/gen3-vectis"` |  |
| siemService.image.tag | string | `"siem-service-v1"` |  |
| siemService.replicaCount | int | `1` |  |
| siemService.resources.limits.cpu | string | `"500m"` |  |
| siemService.resources.limits.memory | string | `"512Mi"` |  |
| siemService.resources.requests.cpu | string | `"50m"` |  |
| siemService.resources.requests.memory | string | `"128Mi"` |  |
| siemService.serviceAccount.annotations | object | `{}` |  |
| siemService.serviceAccount.create | bool | `true` |  |
| siemService.serviceAccount.name | string | `"siem-service"` |  |
