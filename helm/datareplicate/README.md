# datareplicate

![Version: 0.0.30](https://img.shields.io/badge/Version-0.0.30-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 datareplicate

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.23 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalSecrets | map | `{"dcfDataserviceJSONSecret":null,"dcfDataserviceSettingsSecret":null,"deploy":true,"googleCredsSecret":null}` | external secrets for datareplicate jobs |
| global.externalSecrets | map | `{"deploy":true}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `true` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| googleBucketReplicateJob.IGNORED_FILE | string | `"gs://replication-input/ignored_files_manifest.csv"` |  |
| googleBucketReplicateJob.LOG_BUCKET | string | `"datarefresh-log"` |  |
| googleBucketReplicateJob.MANIFEST_FILE | string | `"gs://replication-input/GDC_full_sync_active_manifest_20190326_post_DR43.0.tsv"` |  |
| googleBucketReplicateJob.MAX_WORKERS | int | `80` |  |
| googleBucketReplicateJob.PROJECT | string | `"dcf-prod-buckets"` |  |
| googleBucketReplicateJob.RELEASE | string | `"DR43"` |  |
| googleBucketReplicateJob.enabled | bool | `true` |  |
| googleBucketReplicateJob.resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| googleBucketReplicateJob.resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| googleBucketReplicateJob.resources.requests | map | `{"cpu":"2","memory":"128Mi"}` | The amount of resources that the container requests |
| googleBucketReplicateJob.resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| googleBucketReplicateJob.resources.requests.memory | string | `"128Mi"` | The amount of memory requested |
| googleBucketReplicateJob.schedule | bool | `"*/30 * * * *"` | Whether to enable the Google bucket replicate job |
| image.repository | string | `"quay.io/cdis/dcf-dataservice"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| removeObjectsFromClouds.DRY_RUN | bool | `true` |  |
| removeObjectsFromClouds.IGNORED_FILE | string | `"s3://test-data-replication-manifest/ignored_files_manifest.csv"` |  |
| removeObjectsFromClouds.LOG_BUCKET | string | `"test-data-replication-manifest"` |  |
| removeObjectsFromClouds.MANIFEST_FILE | string | `"s3://test-data-replication-manifest/helm_test_manifest.tsv"` |  |
| removeObjectsFromClouds.RELEASE | string | `"DR43"` |  |
| removeObjectsFromClouds.schedule | string | `"*/30 * * * *"` |  |
| removeObjectsFromClouds.suspendCronjob | bool | `true` |  |
| replicateValidationJobs.FORCE_CREATE_MANIFEST | bool | `true` |  |
| replicateValidationJobs.IGNORED_FILE | string | `"s3://test-data-replication-manifest/ignored_files_manifest.csv"` |  |
| replicateValidationJobs.LOG_BUCKET | string | `"test-data-replication-manifest"` |  |
| replicateValidationJobs.MANIFEST_FILE | string | `"s3://test-data-replication-manifest/helm_test_manifest.tsv"` |  |
| replicateValidationJobs.MAP_FILE | string | `""` |  |
| replicateValidationJobs.OUT_FILES | string | `"replication_validation_output_manifest.tsv"` |  |
| replicateValidationJobs.RELEASE | string | `"DR43"` |  |
| replicateValidationJobs.SAVE_COPIED_OBJECTS | int | `1` |  |
| replicateValidationJobs.enabled | bool | `true` |  |
| replicateValidationJobs.resources.limits | map | `{"memory":"32Gi"}` | The maximum amount of resources that the container is allowed to use |
| replicateValidationJobs.resources.requests | map | `{"cpu":"8","memory":"16Gi"}` | The amount of resources that the container requests |
| replicateValidationJobs.resources.requests.cpu | string | `"8"` | The amount of CPU requested |
| replicateValidationJobs.resources.requests.memory | string | `"16Gi"` | The amount of memory requested |
| replicateValidationJobs.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJobs.suspendCronjob | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| suspendCronjob | bool | `true` |  |
