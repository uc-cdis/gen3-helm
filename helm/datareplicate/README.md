# datareplicate

![Version: 0.0.37](https://img.shields.io/badge/Version-0.0.37-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 datareplicate

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.26 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| awsBucketReplicateJob.CHUNK_SIZE | string | `nil` |  |
| awsBucketReplicateJob.GDC_BUCKET_NAME | string | `nil` |  |
| awsBucketReplicateJob.LOG_BUCKET | string | `nil` |  |
| awsBucketReplicateJob.MANIFEST_FILE | string | `nil` |  |
| awsBucketReplicateJob.QUICK_TEST | string | `nil` |  |
| awsBucketReplicateJob.RELEASE | string | `nil` |  |
| awsBucketReplicateJob.THREAD_NUM | string | `nil` |  |
| awsBucketReplicateJob.enabled | bool | `true` |  |
| awsBucketReplicateJob.resources.limits.memory | string | `"2Gi"` |  |
| awsBucketReplicateJob.resources.requests.cpu | string | `"2"` |  |
| awsBucketReplicateJob.resources.requests.memory | string | `"128Mi"` |  |
| awsBucketReplicateJob.schedule | string | `"*/30 * * * *"` |  |
| externalSecrets | map | `{"awsCredsSecret":null,"dcfDataserviceSettingsSecret":null,"deploy":true,"googleCredsSecret":null}` | external secrets for datareplicate jobs |
| global.externalSecrets | map | `{"deploy":true}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `true` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| googleBucketReplicateJob.IGNORED_FILE | string | `nil` |  |
| googleBucketReplicateJob.LOG_BUCKET | string | `nil` |  |
| googleBucketReplicateJob.MANIFEST_FILE | string | `nil` |  |
| googleBucketReplicateJob.MAX_WORKERS | string | `nil` |  |
| googleBucketReplicateJob.PROJECT | string | `nil` |  |
| googleBucketReplicateJob.RELEASE | string | `nil` |  |
| googleBucketReplicateJob.enabled | bool | `true` |  |
| googleBucketReplicateJob.resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| googleBucketReplicateJob.resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| googleBucketReplicateJob.resources.requests | map | `{"cpu":"2","memory":"128Mi"}` | The amount of resources that the container requests |
| googleBucketReplicateJob.resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| googleBucketReplicateJob.resources.requests.memory | string | `"128Mi"` | The amount of memory requested |
| googleBucketReplicateJob.schedule | bool | `"*/30 * * * *"` | Whether to enable the Google bucket replicate job |
| image.repository | string | `"quay.io/cdis/dcf-dataservice"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| removeObjectsFromCloudsJob.DRY_RUN | string | `nil` |  |
| removeObjectsFromCloudsJob.IGNORED_FILE | string | `nil` |  |
| removeObjectsFromCloudsJob.LOG_BUCKET | string | `nil` |  |
| removeObjectsFromCloudsJob.MANIFEST_FILE | string | `nil` |  |
| removeObjectsFromCloudsJob.ONLY_REDACT | string | `nil` |  |
| removeObjectsFromCloudsJob.RELEASE | string | `nil` |  |
| removeObjectsFromCloudsJob.enabled | bool | `true` |  |
| removeObjectsFromCloudsJob.schedule | string | `"*/30 * * * *"` |  |
| removeObjectsFromCloudsJob.suspendCronjob | bool | `true` |  |
| replicateValidationJob.FORCE_CREATE_MANIFEST | string | `nil` |  |
| replicateValidationJob.IGNORED_FILE | string | `nil` |  |
| replicateValidationJob.LOG_BUCKET | string | `nil` |  |
| replicateValidationJob.MANIFEST_FILE | string | `nil` |  |
| replicateValidationJob.MAP_FILE | string | `nil` |  |
| replicateValidationJob.OUT_FILES | string | `nil` |  |
| replicateValidationJob.RELEASE | string | `nil` |  |
| replicateValidationJob.SAVE_COPIED_OBJECTS | string | `nil` |  |
| replicateValidationJob.enabled | bool | `true` |  |
| replicateValidationJob.resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| replicateValidationJob.resources.requests | map | `{"cpu":"2","memory":"128Mi"}` | The amount of resources that the container requests |
| replicateValidationJob.resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| replicateValidationJob.resources.requests.memory | string | `"128Mi"` | The amount of memory requested |
| replicateValidationJob.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJob.suspendCronjob | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| suspendCronjob | bool | `true` |  |
