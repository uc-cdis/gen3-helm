# s3-monitor

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: ActiveMQDuckDB](https://img.shields.io/badge/AppVersion-ActiveMQDuckDB-informational?style=flat-square)

s3-monitor (ActiveMQ + DuckDB): drains an SQS queue of S3 ObjectCreated notifications, publishes each new or changed object to Amazon MQ and records it in a Parquet lake. All code runs from the quay.io/cdis/s3-monitor image; this chart holds only configuration, the CronJob, an optional backfill Job and (with Crossplane) the IAM role.

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.region | string | `"us-east-1"` | AWS region of the buckets, lake, queue and MQ. |
| backfill.enabled | bool | `false` | Create the backfill Job. |
| backfill.prefix | string | `""` | Optional narrower prefix inside the tenant's prefix. |
| backfill.runId | string | `""` | Unique per run (e.g. a date); a new value creates a new Job. |
| backfill.since | string | `""` | Optional: only objects modified on or after this date (YYYY-MM-DD). |
| backfill.tenant | string | `""` | Tenant id to backfill. |
| backoffLimit | int | `2` | Retries of a failed run. |
| concurrencyPolicy | string | `"Forbid"` | CronJob concurrency policy. Keep Forbid: runs must not overlap. |
| config.apply | bool | `false` | false = dry run: peek one batch without consuming it, classify it against the lake, check the MQ secret; change nothing. |
| config.assumeRoleArn | string | `""` | Optional role the CronJob assumes for S3 access (e.g. tenant buckets in another account). |
| config.lake.bucket | string | `""` | Bucket of the Parquet lake. |
| config.lake.kmsKeyArn | string | `""` | KMS key of the lake bucket, if it uses one. |
| config.lake.prefix | string | `"vectis"` | Key prefix of the lake inside the bucket. |
| config.mq.destinationPrefix | string | `"/queue/s3monitor.ingest"` | Queue prefix; tenant queues are <prefix>.<tenant id> and <prefix>.<tenant id>.failures |
| config.mq.resolveIpv4 | bool | `false` | Resolve broker hostnames to IPv4 before connecting. |
| config.mq.secretArn | string | `""` | Secrets Manager ARN of the MQ credentials (username/password). |
| config.mq.secretKmsKeyArn | string | `""` | KMS key of that secret, if it is a customer-managed key. |
| config.mq.stompEndpoints | list | `[]` | Amazon MQ STOMP endpoints, e.g. stomp+ssl://b-xxxx-1.mq.us-east-1.amazonaws.com:61614 |
| config.sqs.batchSize | int | `10` | Messages per batch (1-10). |
| config.sqs.flushRows | int | `1000` | Write the buffered rows to the lake (one Parquet file per bucket) after this many rows... |
| config.sqs.flushSeconds | int | `120` | ...or after this many seconds, whichever comes first, and always at the end of the run. |
| config.sqs.maxReceiveCount | int | `5` | Must equal the queue's redrive maxReceiveCount; on that try a failure is also sent to the tenant's .failures queue. |
| config.sqs.maxRunSeconds | int | `240` | A run stops after this many seconds. Keep it below the schedule interval and below the queue's visibility timeout: buffered messages are deleted at the latest when the run ends. |
| config.sqs.queueUrl | string | `""` | SQS queue the tenant buckets' ObjectCreated notifications go to (created outside the chart, e.g. CDK). |
| config.sqs.waitTimeSeconds | int | `10` | Long-poll wait per receive (0-20 s). |
| config.tenants | list | `[]` | Watched buckets: id, existing_bucket_name, optional prefix / suffix (the same filter as the bucket notification), kms_key_arn, lifecycle (active | draining | retired), destination, failure_destination. |
| config.useFipsAwsEndpoints | bool | `true` | Use FIPS S3/STS endpoints. |
| eksClusterName | string | `""` | EKS cluster name (required; shown in the job's startup log and checked by the config schema). |
| enabled | bool | `false` | Deploy s3-monitor. In the gen3 umbrella chart this is the `s3-monitor.enabled` condition. |
| failedJobsHistoryLimit | int | `1` | Failed Jobs to keep. |
| fullnameOverride | string | `""` | Prefix of the Kubernetes object names. Defaults to s3-monitor-activemq, so it never collides with the legacy s3-monitor in vectis-overlays. |
| global.crossplane.accountId | string | `""` | AWS account id. Quote it. |
| global.crossplane.enabled | bool | `false` | Create the IAM role with Crossplane. Off: annotate the ServiceAccount with an existing role (serviceAccount.annotations). |
| global.crossplane.oidcProviderUrl | string | `""` | EKS cluster OIDC provider, without https:// |
| global.crossplane.providerConfigName | string | `"provider-aws"` | Crossplane ProviderConfig (crossplane-contrib/provider-aws). |
| global.environment | string | `""` | Environment name; prefix of every AWS resource name (<environment>-<namespace>-...). |
| iam.tenantsPerPolicy | int | `8` | Tenants per CronJob IAM policy (IAM limits: 6,144 characters per policy, 10 policies per role). |
| image.digest | string | `""` | Optional sha256 digest. When set, the CronJob and the backfill Job run exactly this build. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"quay.io/cdis/s3-monitor"` | s3-monitor image (all Python and shell code). Built and pushed by the uc-cdis/s3-monitor repo. |
| image.tag | string | `"ActiveMQDuckDB"` | Image tag. |
| imagePullSecrets | list | `[]` | Image pull secrets, if the quay.io repository is private. |
| resources | map | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | CronJob resources. DuckDB works in memory, so leave headroom. |
| schedule | string | `"*/5 * * * *"` | CronJob schedule. Each run drains the SQS queue (up to config.sqs.maxRunSeconds) and exits. |
| serviceAccount.annotations | map | `{}` | Annotations when Crossplane is off (e.g. an existing eks.amazonaws.com/role-arn). |
| serviceAccount.create | bool | `true` | Create the CronJob's ServiceAccount. |
| serviceAccount.name | string | `"s3-monitor-activemq-sa"` | ServiceAccount of the CronJob and the backfill Job. With Crossplane its IRSA role is <environment>-<namespace>-<name>. |
| successfulJobsHistoryLimit | int | `3` | Successful Jobs to keep. |
| ttlSecondsAfterFinished | int | `600` | Seconds before a finished Job is deleted. |
