# s3-monitor

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: feature_sqs-consumer](https://img.shields.io/badge/AppVersion-feature_sqs--consumer-informational?style=flat-square)

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
| config.apply | bool | `false` | false = dry run: checks MQ secret, queue, buckets and lake; receives nothing. |
| config.assumeRoleArn | string | `""` | Optional role the CronJob assumes for S3 access (e.g. tenant buckets in another account). |
| config.lake.bucket | string | `""` | Bucket of the Parquet lake. |
| config.lake.kmsKeyArn | string | `""` | SSE-KMS key for all lake writes. |
| config.lake.prefix | string | `"vectis"` | Key prefix of the lake inside the bucket. |
| config.lake.stateCompactHours | int | `24` | Hours between lake state snapshot rebuilds (done by recon). |
| config.md5MaxBytes | int | `1073741824` | Max object size streamed to compute md5_checksum when the ETag is not the MD5 (0 = never). |
| config.mq.destinationPrefix | string | `"/queue/s3monitor.ingest"` | Queue prefix; tenant queues are <prefix>.<tenant id> and <prefix>.<tenant id>.failures |
| config.mq.secretArn | string | `""` | Secrets Manager ARN of the MQ credentials (username/password). |
| config.mq.secretKmsKeyArn | string | `""` | KMS key of that secret, if it is a customer-managed key. |
| config.mq.stompEndpoints | list | `[]` | Amazon MQ STOMP endpoints, e.g. stomp+ssl://b-xxxx-1.mq.us-east-1.amazonaws.com:61614 |
| config.recon.epochSlackMinutes | int | `60` | Epoch-named folders are listed only this many minutes around the window. |
| config.recon.lagHours | int | `1` | Check the hour that ended this many hours ago (lag 1 at 10:15 -> 08:00-09:00 UTC). |
| config.recon.maxRequeue | int | `10000` | Above this many missing objects, alarm instead of re-queueing. |
| config.recon.mqCloudwatchBrokers | list | `[]` | Amazon MQ broker names as CloudWatch shows them (e.g. ["gen3-mq-1", "gen3-mq-2"]); empty = skip the MQ check. |
| config.recon.mqGraceSeconds | int | `300` | ActiveMQ enqueues are counted this many seconds past the window end (publish delay). |
| config.recon.requeueMissing | bool | `false` | Re-queue objects missing two hours in a row (apply: true only). |
| config.recon.sqsGraceSeconds | int | `120` | SQS messages sent are counted this many seconds past the window end (notification delay). |
| config.sqs.batchSize | int | `10` | Messages per batch (1-10). |
| config.sqs.flushRows | int | `1000` | Write buffered rows to the lake after this many rows... |
| config.sqs.flushSeconds | int | `120` | ...or seconds, and at the end of the run. |
| config.sqs.maxRunSeconds | int | `240` | A run stops taking work after this. Queue VisibilityTimeout must be >= this + 120 (checked at start). |
| config.sqs.queueUrl | string | `""` | SQS queue the tenant buckets' ObjectCreated notifications go to (created outside the chart, e.g. CDK). |
| config.sqs.waitTimeSeconds | int | `10` | Long-poll wait per receive (0-20 s). |
| config.tenants | list | `[]` | Watched buckets: id, existing_bucket_name, prefix, suffix, lifecycle (active | draining | retired), destination, failure_destination; kms_key_arn is used for IAM only. |
| config.useFipsAwsEndpoints | bool | `true` | Use FIPS S3/STS endpoints. |
| enabled | bool | `false` | Deploy s3-monitor. In the gen3 umbrella chart this is the `s3-monitor.enabled` condition. |
| failedJobsHistoryLimit | int | `1` | Failed Jobs to keep. |
| fullnameOverride | string | `""` | Prefix of the Kubernetes object names (default s3-monitor-activemq). |
| global.crossplane.accountId | string | `""` | AWS account id. Quote it. |
| global.crossplane.enabled | bool | `false` | Create the IAM role with Crossplane. Off: annotate the ServiceAccount with an existing role (serviceAccount.annotations). |
| global.crossplane.oidcProviderUrl | string | `""` | EKS cluster OIDC provider, without https:// |
| global.crossplane.providerConfigName | string | `"provider-aws"` | Crossplane ProviderConfig (crossplane-contrib/provider-aws). |
| global.environment | string | `""` | Environment name; prefix of every AWS resource name (<environment>-<namespace>-...). |
| iam.tenantsPerPolicy | int | `8` | Tenants per CronJob IAM policy (IAM limits: 6,144 characters per policy, 10 policies per role). |
| image.digest | string | `""` | Optional sha256 digest. When set, the CronJob and the backfill Job run exactly this build. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"quay.io/cdis/s3-monitor"` | s3-monitor image (all Python and shell code). Built and pushed by the uc-cdis/s3-monitor repo. |
| image.tag | string | `"feature_sqs-consumer"` | Image tag. |
| imagePullSecrets | list | `[]` | Image pull secrets, if the quay.io repository is private. |
| recon.enabled | bool | `false` | Create the recon CronJob. |
| recon.schedule | string | `"15 * * * *"` | Recon schedule (default: 15 minutes past every hour). |
| resources | map | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | CronJob resources. DuckDB works in memory, so leave headroom. |
| schedule | string | `"*/5 * * * *"` | CronJob schedule. Each run drains the SQS queue (up to config.sqs.maxRunSeconds) and exits. |
| serviceAccount.annotations | map | `{}` | Annotations when Crossplane is off (e.g. an existing eks.amazonaws.com/role-arn). |
| serviceAccount.create | bool | `true` | Create the CronJob's ServiceAccount. |
| serviceAccount.name | string | `"s3-monitor-activemq-sa"` | ServiceAccount of the CronJob and the backfill Job. With Crossplane its IRSA role is <environment>-<namespace>-<name>. |
| successfulJobsHistoryLimit | int | `3` | Successful Jobs to keep. |
| terminationGracePeriodSeconds | int | `150` | Time to finish after SIGTERM: current event, final lake write, SQS deletes. |
| ttlSecondsAfterFinished | int | `600` | Seconds before a finished Job is deleted. |
