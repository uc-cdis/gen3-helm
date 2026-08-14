# s3-monitor

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

Helm chart for the S3 Monitor CronJob (syncs S3 object metadata into Postgres and publishes new/updated files to RabbitMQ)

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| args | list | `[]` |  |
| command | list | `[]` |  |
| env.apply | string | `"true"` |  |
| env.clusterId | string | `"gen3-qa-vectis-rdscluster7e964c7d-lqk85dtnbh5j"` |  |
| env.dbName | string | `"postgres"` |  |
| env.rabbitmqPort | string | `"5671"` |  |
| env.rabbitmqUrl | string | `"b-60a6d3ee-83ab-4602-b0e6-d89bd97315be.mq.us-east-1.on.aws"` |  |
| env.rdsSecretName | string | `"RdsSecretB4544A18-GrJ4o16zGYiT"` |  |
| env.region | string | `"us-east-1"` |  |
| env.s3Bucket | string | `"gen3-qa-vectis-config"` |  |
| externalSecret.enabled | bool | `true` |  |
| externalSecret.passwordProperty | string | `"password"` |  |
| externalSecret.refreshInterval | string | `"1h"` |  |
| externalSecret.remoteKey | string | `"qa-vectis/s3-monitor/rabbitmq"` |  |
| externalSecret.secretName | string | `"s3-monitor-rabbitmq-secret"` |  |
| externalSecret.secretStoreKind | string | `"ClusterSecretStore"` |  |
| externalSecret.secretStoreName | string | `"aws-secrets-manager"` |  |
| externalSecret.usernameProperty | string | `"username"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/s3-monitor"` |  |
| image.tag | string | `"master"` |  |
| job.backoffLimit | int | `2` |  |
| job.concurrencyPolicy | string | `"Forbid"` |  |
| job.failedJobsHistoryLimit | int | `1` |  |
| job.successfulJobsHistoryLimit | int | `3` |  |
| job.ttlSecondsAfterFinished | int | `600` |  |
| namespace | string | `"qa-vectis"` |  |
| rabbitmq.password | string | `nil` |  |
| rabbitmq.username | string | `"vectis"` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| schedule | string | `"*/5 * * * *"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"s3-monitor-sa"` |  |
| serviceAccount.roleArn | string | `"arn:aws:iam::707767160287:role/s3-monitor-role"` |  |
