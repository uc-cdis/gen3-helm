# s3-monitor

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: ActiveMQDuckDB](https://img.shields.io/badge/AppVersion-ActiveMQDuckDB-informational?style=flat-square)

s3-monitor (ActiveMQ + DuckDB): per-tenant S3 metadata sync into a Parquet lake, published to Amazon MQ, with an optional real-time S3 event recorder Lambda. All code runs from the quay.io/cdis/s3-monitor image; this chart holds only configuration, EKS objects and AWS resources (Crossplane). Operator guide: GUIDE.md.

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.region | string | `"us-east-1"` | AWS region of the buckets, lake, MQ and the recorder Lambda. |
| backoffLimit | int | `2` | Retries of a failed run. |
| concurrencyPolicy | string | `"Forbid"` | CronJob concurrency policy. Keep Forbid: runs must not overlap. |
| config.apply | bool | `false` | false = dry run: scan and log, write nothing to the lake and publish nothing. |
| config.assumeRoleArn | string | `""` | Optional role the CronJob assumes for S3 access (e.g. tenant buckets in another account). |
| config.lake.bucket | string | `""` | Bucket of the Parquet lake. |
| config.lake.kmsKeyArn | string | `""` | KMS key of the lake bucket, if it uses one. |
| config.lake.prefix | string | `"vectis"` | Key prefix of the lake inside the bucket. |
| config.lookbackDays | int | `3` | Days of S3 history each run scans. |
| config.mq.destinationPrefix | string | `"/queue/s3monitor.ingest"` | Queue prefix; tenant queues are <prefix>.<tenant id> and <prefix>.<tenant id>.failures |
| config.mq.resolveIpv4 | bool | `false` | Resolve broker hostnames to IPv4 before connecting. |
| config.mq.secretArn | string | `""` | Secrets Manager ARN of the MQ credentials (username/password). |
| config.mq.secretKmsKeyArn | string | `""` | KMS key of that secret, if it is a customer-managed key. |
| config.mq.stompEndpoints | list | `[]` | Amazon MQ STOMP endpoints, e.g. stomp+ssl://b-xxxx-1.mq.us-east-1.amazonaws.com:61614 |
| config.tenants | list | `[]` |  |
| config.useFipsAwsEndpoints | bool | `true` | Use FIPS S3/STS endpoints. |
| eksClusterName | string | `""` | EKS cluster name (required; shown in the job's startup log and checked by the config schema). |
| enabled | bool | `false` | Deploy s3-monitor. In the gen3 umbrella chart this is the `s3-monitor.enabled` condition. |
| eventRecorder.architecture | string | `"arm64"` | Lambda architecture: arm64 or amd64. The image must be built for it. |
| eventRecorder.enabled | bool | `false` | Deploy the S3 event recorder Lambda (Crossplane) for tenants with s3_event.enabled. |
| eventRecorder.logRetentionDays | int | `30` | Retention of /aws/lambda/<function> logs. |
| eventRecorder.memorySize | int | `1024` | Lambda memory (MB). |
| eventRecorder.removeNotifications | bool | `false` | With enabled=false: still run the notifications Job once to remove this release's entries from the tenant buckets. Set it for the sync that turns the recorder off. |
| eventRecorder.timeoutSeconds | int | `120` | Lambda timeout (seconds, max 900). |
| failedJobsHistoryLimit | int | `1` | Failed Jobs to keep. |
| fullnameOverride | string | `""` | Prefix of the Kubernetes object names. Defaults to s3-monitor-activemq, so it never collides with the legacy s3-monitor in vectis-overlays. |
| global.crossplane.accountId | string | `""` | AWS account id. Quote it. |
| global.crossplane.enabled | bool | `false` | Create the IAM roles (and the recorder Lambda) with Crossplane. |
| global.crossplane.oidcProviderUrl | string | `""` | EKS cluster OIDC provider, without https:// |
| global.crossplane.providerConfigName | string | `"provider-aws"` | Crossplane ProviderConfig (crossplane-contrib/provider-aws). |
| global.environment | string | `""` | Environment name; prefix of every AWS resource name (<environment>-<namespace>-...). |
| iam.tenantsPerPolicy | int | `8` | Tenants per CronJob IAM policy (IAM limits: 6,144 characters per policy, 10 policies per role). |
| image.digest | string | `""` | Optional sha256 digest. When set, the CronJob, the Jobs and the Lambda run exactly this build. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"quay.io/cdis/s3-monitor"` | s3-monitor image (all Python and shell code). Built and pushed by the s3-monitor-activemq repo. |
| image.tag | string | `"ActiveMQDuckDB"` | Image tag. |
| imagePullSecrets | list | `[]` | Image pull secrets, if the quay.io repository is private. |
| resources | map | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | CronJob resources. DuckDB works in memory, so leave headroom. |
| schedule | string | `"*/5 * * * *"` | CronJob schedule. |
| serviceAccount.annotations | map | `{}` | Annotations when Crossplane is off (e.g. an existing eks.amazonaws.com/role-arn). |
| serviceAccount.create | bool | `true` | Create the CronJob's ServiceAccount. |
| serviceAccount.name | string | `"s3-monitor-activemq-sa"` | CronJob ServiceAccount. With Crossplane its IRSA role is <environment>-<namespace>-<name>. |
| setupJobs.backoffLimit | int | `10` | Retries; the Jobs wait for Crossplane to create their AWS dependencies. |
| setupJobs.notificationsDryRun | bool | `false` | Only print the bucket notification changes. |
| setupJobs.resources | map | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Setup Job resources. |
| setupJobs.ttlSecondsAfterFinished | int | `3600` | Seconds before a finished setup Job is deleted. |
| setupServiceAccount.name | string | `"s3-monitor-activemq-setup"` | ServiceAccount of the setup Jobs (ECR image copy, bucket notifications). Created only with the event recorder. |
| successfulJobsHistoryLimit | int | `3` | Successful Jobs to keep. |
| ttlSecondsAfterFinished | int | `600` | Seconds before a finished Job is deleted. |
