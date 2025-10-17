# datareplicate

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
![Version: 0.1.19](https://img.shields.io/badge/Version-0.1.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
=======
![Version: 0.0.30](https://img.shields.io/badge/Version-0.0.30-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 135d55b2 (bump chart ver)
=======
![Version: 0.0.31](https://img.shields.io/badge/Version-0.0.31-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 273f853c (Update ETL job to call out to slack (#399))
=======
![Version: 0.0.32](https://img.shields.io/badge/Version-0.0.32-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
=======
![Version: 0.0.33](https://img.shields.io/badge/Version-0.0.33-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 5db5f7c4 (Updating HPAs for all of our services. (#414))

A Helm chart for gen3 datareplicate

## Requirements

| Repository | Name | Version |
|------------|------|---------|
<<<<<<< HEAD
| file://../common | common | 0.1.33 |
=======
| file://../common | common | 0.1.24 |
>>>>>>> 5db5f7c4 (Updating HPAs for all of our services. (#414))

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
<<<<<<< HEAD
<<<<<<< HEAD
| awsBatchReplicateJob.JOB_DEFINITION | string | `nil` |  |
| awsBatchReplicateJob.JOB_QUEUE | string | `nil` |  |
| awsBatchReplicateJob.MANIFEST_PATH | string | `nil` |  |
| awsBatchReplicateJob.MAX_RETRIES | string | `nil` |  |
| awsBatchReplicateJob.OUTPUT_MANIFEST_BUCKET | string | `nil` |  |
| awsBatchReplicateJob.REGION | string | `nil` |  |
| awsBatchReplicateJob.THREAD_COUNT | string | `nil` |  |
| awsBatchReplicateJob.enabled | bool | `true` |  |
| awsBatchReplicateJob.namespace | string | `nil` |  |
| awsBatchReplicateJob.schedule | string | `"*/30 * * * *"` |  |
=======
>>>>>>> 273f853c (Update ETL job to call out to slack (#399))
| awsBucketReplicateJob.CHUNK_SIZE | string | `nil` |  |
| awsBucketReplicateJob.GDC_BUCKET_NAME | string | `nil` |  |
| awsBucketReplicateJob.LOG_BUCKET | string | `nil` |  |
| awsBucketReplicateJob.MANIFEST_FILE | string | `nil` |  |
| awsBucketReplicateJob.QUICK_TEST | string | `nil` |  |
| awsBucketReplicateJob.RELEASE | string | `nil` |  |
| awsBucketReplicateJob.THREAD_NUM | string | `nil` |  |
<<<<<<< HEAD
=======
| awsBucketReplicateJob.CHUNK_SIZE | int | `1` |  |
| awsBucketReplicateJob.GDC_BUCKET_NAME | string | `"test-gdc-bucket"` |  |
| awsBucketReplicateJob.LOG_BUCKET | string | `"test-data-replication-manifest"` |  |
| awsBucketReplicateJob.MANIFEST_FILE | string | `"s3://test-data-replication-manifest/GDC_only_3plusgig_open_active_manifest.tsv"` |  |
| awsBucketReplicateJob.QUICK_TEST | bool | `true` |  |
| awsBucketReplicateJob.RELEASE | string | `"DR43"` |  |
| awsBucketReplicateJob.THREAD_NUM | int | `20` |  |
>>>>>>> dba2283c (final changes)
=======
>>>>>>> 273f853c (Update ETL job to call out to slack (#399))
| awsBucketReplicateJob.enabled | bool | `true` |  |
| awsBucketReplicateJob.schedule | string | `"*/30 * * * *"` |  |
<<<<<<< HEAD
| batchServiceAccount.annotations | object | `{}` |  |
=======
>>>>>>> 273f853c (Update ETL job to call out to slack (#399))
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
| googleBucketReplicateJob.schedule | bool | `"*/30 * * * *"` | Whether to enable the Google bucket replicate job |
| image.repository | string | `"quay.io/cdis/dcf-dataservice"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| removeObjectsFromCloudsJob.DRY_RUN | string | `nil` |  |
| removeObjectsFromCloudsJob.IGNORED_FILE | string | `nil` |  |
| removeObjectsFromCloudsJob.LOG_BUCKET | string | `nil` |  |
| removeObjectsFromCloudsJob.MANIFEST_FILE | string | `nil` |  |
<<<<<<< HEAD
| removeObjectsFromCloudsJob.ONLY_REDACT | string | `nil` |  |
=======
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
| removeObjectsFromCloudsJob.RELEASE | string | `nil` |  |
| removeObjectsFromCloudsJob.enabled | bool | `true` |  |
| removeObjectsFromCloudsJob.schedule | string | `"*/30 * * * *"` |  |
| removeObjectsFromCloudsJob.suspendCronjob | bool | `true` |  |
<<<<<<< HEAD
| replicateServiceAccount.annotations | object | `{}` |  |
=======
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
| replicateValidationJob.FORCE_CREATE_MANIFEST | string | `nil` |  |
| replicateValidationJob.IGNORED_FILE | string | `nil` |  |
| replicateValidationJob.LOG_BUCKET | string | `nil` |  |
| replicateValidationJob.MANIFEST_FILE | string | `nil` |  |
| replicateValidationJob.MAP_FILE | string | `nil` |  |
| replicateValidationJob.OUT_FILES | string | `nil` |  |
| replicateValidationJob.RELEASE | string | `nil` |  |
| replicateValidationJob.SAVE_COPIED_OBJECTS | string | `nil` |  |
<<<<<<< HEAD
| replicateValidationJob.VALIDATE_PLATFORM | string | `"AWS"` |  |
| replicateValidationJob.enabled | bool | `true` |  |
| replicateValidationJob.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJob.suspendCronjob | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"2","memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
=======
| replicateValidationJob.enabled | bool | `true` |  |
| replicateValidationJob.resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| replicateValidationJob.resources.requests | map | `{"cpu":"2","memory":"128Mi"}` | The amount of resources that the container requests |
| replicateValidationJob.resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| replicateValidationJob.resources.requests.memory | string | `"128Mi"` | The amount of memory requested |
| replicateValidationJob.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJob.suspendCronjob | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"2","memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| suspendCronjob | bool | `true` |  |
