# datareplicate

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
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
=======
![Version: 0.0.34](https://img.shields.io/badge/Version-0.0.34-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 1d9d5b3b (Adding Kubeconform Github Action. (#428))
=======
![Version: 0.0.35](https://img.shields.io/badge/Version-0.0.35-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 8bac4f48 (Version bump to fix linting errors)
=======
![Version: 0.0.36](https://img.shields.io/badge/Version-0.0.36-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 14bf12cf ( Setup PushSecret for DB init (#433))
=======
![Version: 0.0.37](https://img.shields.io/badge/Version-0.0.37-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 761bd6c5 (update chart version)

A Helm chart for gen3 datareplicate

## Requirements

| Repository | Name | Version |
|------------|------|---------|
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
| file://../common | common | 0.1.33 |
=======
| file://../common | common | 0.1.24 |
>>>>>>> 5db5f7c4 (Updating HPAs for all of our services. (#414))
=======
| file://../common | common | 0.1.25 |
>>>>>>> 950b51ce (Update version of common and gen3 charts)
=======
| file://../common | common | 0.1.24 |
>>>>>>> dabe938c (Revert "Update version of common and gen3 charts")
=======
| file://../common | common | 0.1.25 |
>>>>>>> d0be3cc5 (Update versions to meet with Lint changes)
=======
| file://../common | common | 0.1.26 |
>>>>>>> 14bf12cf ( Setup PushSecret for DB init (#433))
=======
| file://../common | common | 0.1.30 |
>>>>>>> df289989 (MIDRC-1193 Postgres DB for Funnel (#503))
=======
| file://../common | common | 0.1.31 |
>>>>>>> 60329e41 (Allow overriding bucket name for manifestservice (#522))

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
<<<<<<< HEAD
<<<<<<< HEAD
| batchServiceAccount.annotations | object | `{}` |  |
=======
>>>>>>> 273f853c (Update ETL job to call out to slack (#399))
=======
| batchServiceAccount.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::test"` |  |
>>>>>>> 511a72d0 (adding annotations to aws-batch-replicate job sa.)
=======
| batchServiceAccount.annotations | object | `{}` |  |
>>>>>>> 5600907a (fixing annotations in values.yaml)
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
<<<<<<< HEAD
| removeObjectsFromCloudsJob.ONLY_REDACT | string | `nil` |  |
=======
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
=======
| removeObjectsFromCloudsJob.ONLY_REDACT | string | `"all"` |  |
>>>>>>> 92f7a427 (Add New Param for Redaction Job)
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
<<<<<<< HEAD
=======
>>>>>>> 0b04f82d (add default)
| replicateValidationJob.VALIDATE_PLATFORM | string | `"AWS"` |  |
| replicateValidationJob.enabled | bool | `true` |  |
| replicateValidationJob.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJob.suspendCronjob | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"2","memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
=======
| replicateValidationJob.enabled | bool | `true` |  |
| replicateValidationJob.schedule | string | `"*/30 * * * *"` |  |
| replicateValidationJob.suspendCronjob | bool | `true` |  |
<<<<<<< HEAD
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
>>>>>>> 2537941b (Migrate DCF redaction and validation jobs (#385))
=======
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"2","memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
>>>>>>> 6684a2f1 (readme)
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"2","memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| suspendCronjob | bool | `true` |  |
