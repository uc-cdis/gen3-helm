# data-upload-cron

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for the data upload cronjob

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.30 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| awsCredsSecret.accessKey | string | `"aws_access_key_id"` | The key in the Kubernetes secret that contains the AWS access key ID. This is used by the data-upload-cron container to authenticate with AWS when connecting to S3. |
| awsCredsSecret.secretKey | string | `"aws_secret_access_key"` | The key in the Kubernetes secret that contains the AWS secret access key. This is used by the data-upload-cron container to authenticate with AWS when connecting to S3. |
| awsCredsSecret.secretName | string | `""` | The name of the Kubernetes secret that contains AWS credentials. This is used by the data-upload-cron container to authenticate with AWS when connecting to S3. |
| backoffLimit | int | `1` | The number of retries before marking a job as failed. This is used by Kubernetes to determine how many times to retry a job if it fails before giving up and marking it as failed. |
| concurrencyPolicy | string | `"Forbid"` | Concurrency policy for the cronjob. This determines how to handle concurrent executions of the job. Valid values are "Allow", "Forbid", and "Replace". "Allow" allows concurrent runs, "Forbid" prevents new runs if the previous run is still active, and "Replace" cancels the currently running job and replaces it with a new one. |
| configmaps | map | `{"pending":{"initialPending":"{}","name":"pending-state","pendingKey":"pending"},"state":{"initialLastRun":"1970-01-01T00:00:00Z","lastRunKey":"last_run","name":"current-state"}}` | ConfigMap keys for tracking the state of the cronjob. These are used by the data-upload-cron container to store and retrieve information about the last run of the cronjob and any pending jobs. |
| configmaps.pending | map | `{"initialPending":"{}","name":"pending-state","pendingKey":"pending"}` | Keys for tracking pending jobs. This is used by the data-upload-cron container to store and retrieve information about any pending jobs that have not yet been completed. |
| configmaps.pending.initialPending | string | `"{}"` | The initial value for the pending jobs key. This is used by the data-upload-cron container to initialize the pending jobs state. |
| configmaps.pending.pendingKey | string | `"pending"` | The name of the ConfigMap to use for tracking pending jobs. This is used by the data-upload-cron container to determine where to store information about pending jobs. |
| configmaps.state | map | `{"initialLastRun":"1970-01-01T00:00:00Z","lastRunKey":"last_run","name":"current-state"}` | Keys for tracking the state of the cronjob. This is used by the data-upload-cron container to store and retrieve information about the last run of the cronjob. |
| configmaps.state.initialLastRun | string | `"1970-01-01T00:00:00Z"` | The initial value for the last run key. This is used by the data-upload-cron container to initialize the last run state. |
| configmaps.state.lastRunKey | string | `"last_run"` | The key to use for storing the timestamp of the last run of the cronjob. This is used by the data-upload-cron container to determine when the cronjob was last run. |
| configmaps.state.name | string | `"current-state"` | The name of the ConfigMap to use for tracking the state of the cronjob. This is used by the data-upload-cron container to determine where to store information about the last run of the cronjob. |
| enabled | bool | `true` | Whether to deploy the data-upload-cron chart. |
| env | map | `{"bucket":"","dispatcherTimeout":"30","dispatcherUrl":"http://ssjdispatcher-service/dispatchJob","indexdTimeout":"30","indexdUrl":"http://indexd-service","maxAttemptsBeforeAlert":"10","prefix":"","s3EndpointUrl":"","s3ForcePathStyle":false,"s3Region":""}` | Environment variables for the data-upload-cron container. These are used to pass configuration settings and secrets to the container at runtime. |
| env.bucket | string | `""` | The name of the S3 bucket to use for storing files. This is used by the data-upload-cron container to determine where to upload files. |
| env.dispatcherTimeout | string | `"30"` | The timeout for requests to the ssjdispatcher service, in seconds. This is used by the data-upload-cron container to determine how long to wait for a response from the ssjdispatcher service before timing out. |
| env.dispatcherUrl | string | `"http://ssjdispatcher-service/dispatchJob"` | The URL for the ssjdispatcher service. This is used by the data-upload-cron container to send requests to the ssjdispatcher service. |
| env.indexdTimeout | string | `"30"` | The timeout for requests to the indexd service, in seconds. This is used by the data-upload-cron container to determine how long to wait for a response from the indexd service before timing out. |
| env.indexdUrl | string | `"http://indexd-service"` | The URL for the indexd service. This is used by the data-upload-cron container to send requests to the indexd service. |
| env.maxAttemptsBeforeAlert | string | `"10"` | Whether to send an alert on every resubmit. This is used by the data-upload-cron container to determine whether to send an alert every time a job is resubmitted. |
| env.prefix | string | `""` | The prefix to use for files uploaded to S3. This is used by the data-upload-cron container to determine how to organize files in the S3 bucket. |
| env.s3EndpointUrl | string | `""` | The S3 endpoint URL to use for S3-compatible storage. This is used by the data-upload-cron container to determine the endpoint to use when connecting to S3. If left empty, it will use the default AWS S3 endpoint. |
| env.s3ForcePathStyle | bool | `false` | Whether to use path-style URLs for S3. This is used by the data-upload-cron container to determine whether to use path-style URLs (e.g., http://s3.amazonaws.com/bucket/key) or virtual-hosted-style URLs (e.g., http://bucket.s3.amazonaws.com/key) when connecting to S3. This is typically set to true for S3-compatible storage that does not support virtual-hosted-style URLs. |
| env.s3Region | string | `""` | The S3 region to use for S3-compatible storage. This is used by the data-upload-cron container to determine the region to use when connecting to S3. If left empty, it will use the default AWS S3 region. |
| failedJobsHistoryLimit | int | `1` | The number of failed job runs to keep in history. This is used by Kubernetes to determine how many old job objects to retain after they have completed with a failure. |
| global.externalSecrets | map | `{"deploy":true}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `true` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| image.pullPolicy | string | `"Always"` | Image pull policy. |
| image.repository | string | `"quay.io/cdis/data-upload-cron"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| podSecurityContext | map | `{}` | Security context for the pod and containers. This is used to specify security settings such as user ID, group ID, and capabilities for the pod and its containers. |
| rbac.create | bool | `true` | Whether to create RBAC resources. |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"2","memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"2","memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| schedule | string | `"*/15 * * * *"` | Cron schedule for the cronjob. This follows standard cron syntax. For example, "0 0 * * *" would run the job every day at midnight. |
| securityContext | map | `{}` | Security context for the containers in the pod. This is used to specify security settings such as user ID, group ID, and capabilities for the containers. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| slack | map | `{"enabled":false,"secretKey":"","secretName":"","webhook":""}` | Configuration for setting up alerts to Slack. This is used by the data-upload-cron container to determine whether to send alerts to Slack and how to authenticate with the Slack API. |
| slack.enabled | bool | `false` | Whether to enable Slack alerts. |
| slack.secretKey | string | `""` | The key in the secret that contains the Slack API token. |
| slack.secretName | string | `""` | The name of the secret containing the Slack API token. |
| slack.webhook | string | `""` | The URL of the Slack webhook to send alerts to. |
| successfulJobsHistoryLimit | int | `3` | The number of successful job runs to keep in history. This is used by Kubernetes to determine how many old job objects to retain after they have completed successfully. |
| suspendCronjob | bool | `false` | Whether to suspend the cronjob. Setting this to true will prevent the cronjob from scheduling new jobs, but will not affect already scheduled jobs. |
