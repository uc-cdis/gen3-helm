# datareplicate

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 datareplicate

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.21 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global | string | `nil` |  |
| googleBucketReplicateJob.IGNORED_FILE | string | `"gs://replication-input/ignored_files_manifest.csv"` |  |
| googleBucketReplicateJob.LOG_BUCKET | string | `"datarefresh-log"` |  |
| googleBucketReplicateJob.MANIFEST_FILE | string | `"gs://replication-input/GDC_full_sync_active_manifest_20190326_post_DR43.0.tsv"` |  |
| googleBucketReplicateJob.MAX_WORKERS | int | `80` |  |
| googleBucketReplicateJob.PROJECT | bool | `"dcf-prod-buckets"` | Whether to enable the Google bucket replicate job |
| googleBucketReplicateJob.RELEASE | string | `"DR43"` |  |
| image.repository | string | `"quay.io/cdis/datareplicate"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
