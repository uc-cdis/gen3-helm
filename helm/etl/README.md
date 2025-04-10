# etl

![Version: 0.1.11](https://img.shields.io/badge/Version-0.1.11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 etl

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| esEndpoint | string | `"gen3-elasticsearch-master"` |  |
| esGarbageCollect | map | `{"custom_image":null,"enabled":false,"schedule":"0 0 * * *","slack_webhook":"None"}` | Configuration options for es garbage cronjob. |
| esGarbageCollect.custom_image | string | `nil` | To set a custom image for the es garbage collect cronjob. Default is the Gen3 Awshelper image. |
| esGarbageCollect.enabled | bool | `false` | Whether to create es garbage collect cronjob. |
| esGarbageCollect.schedule | string | `"0 0 * * *"` | The cron schedule expression to use in the es garbage collect cronjob. Runs once a day by default. |
| esGarbageCollect.slack_webhook | string | `"None"` | Slack webhook endpoint to use for cronjob. |
| etlForced | string | `"TRUE"` |  |
| etlMapping.mappings[0].aggregated_props[0].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[0].name | string | `"_samples_count"` |  |
| etlMapping.mappings[0].aggregated_props[0].path | string | `"samples"` |  |
| etlMapping.mappings[0].aggregated_props[1].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[1].name | string | `"_aliquots_count"` |  |
| etlMapping.mappings[0].aggregated_props[1].path | string | `"samples.aliquots"` |  |
| etlMapping.mappings[0].aggregated_props[2].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[2].name | string | `"_submitted_methylations_count"` |  |
| etlMapping.mappings[0].aggregated_props[2].path | string | `"samples.aliquots.submitted_methylation_files"` |  |
| etlMapping.mappings[0].aggregated_props[3].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[3].name | string | `"_submitted_copy_number_files_on_aliquots_count"` |  |
| etlMapping.mappings[0].aggregated_props[3].path | string | `"samples.aliquots.submitted_copy_number_files"` |  |
| etlMapping.mappings[0].aggregated_props[4].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[4].name | string | `"_read_groups_count"` |  |
| etlMapping.mappings[0].aggregated_props[4].path | string | `"samples.aliquots.read_groups"` |  |
| etlMapping.mappings[0].aggregated_props[5].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[5].name | string | `"_submitted_aligned_reads_count"` |  |
| etlMapping.mappings[0].aggregated_props[5].path | string | `"samples.aliquots.read_groups.submitted_aligned_reads_files"` |  |
| etlMapping.mappings[0].aggregated_props[6].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[6].name | string | `"_submitted_unaligned_reads_count"` |  |
| etlMapping.mappings[0].aggregated_props[6].path | string | `"samples.aliquots.read_groups.submitted_unaligned_reads_files"` |  |
| etlMapping.mappings[0].aggregated_props[7].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[7].name | string | `"_submitted_copy_number_files_on_read_groups_count"` |  |
| etlMapping.mappings[0].aggregated_props[7].path | string | `"samples.aliquots.read_groups.submitted_copy_number_files"` |  |
| etlMapping.mappings[0].aggregated_props[8].fn | string | `"count"` |  |
| etlMapping.mappings[0].aggregated_props[8].name | string | `"_submitted_somatic_mutations_count"` |  |
| etlMapping.mappings[0].aggregated_props[8].path | string | `"samples.aliquots.read_groups.submitted_somatic_mutations"` |  |
| etlMapping.mappings[0].doc_type | string | `"case"` |  |
| etlMapping.mappings[0].flatten_props[0].path | string | `"demographics"` |  |
| etlMapping.mappings[0].flatten_props[0].props[0].name | string | `"gender"` |  |
| etlMapping.mappings[0].flatten_props[0].props[0].value_mappings[0].female | string | `"F"` |  |
| etlMapping.mappings[0].flatten_props[0].props[0].value_mappings[1].male | string | `"M"` |  |
| etlMapping.mappings[0].flatten_props[0].props[1].name | string | `"race"` |  |
| etlMapping.mappings[0].flatten_props[0].props[1].value_mappings[0]."american indian or alaskan native" | string | `"Indian"` |  |
| etlMapping.mappings[0].flatten_props[0].props[2].name | string | `"ethnicity"` |  |
| etlMapping.mappings[0].flatten_props[0].props[3].name | string | `"year_of_birth"` |  |
| etlMapping.mappings[0].joining_props[0].index | string | `"file"` |  |
| etlMapping.mappings[0].joining_props[0].join_on | string | `"_case_id"` |  |
| etlMapping.mappings[0].joining_props[0].props[0].fn | string | `"set"` |  |
| etlMapping.mappings[0].joining_props[0].props[0].name | string | `"data_format"` |  |
| etlMapping.mappings[0].joining_props[0].props[0].src | string | `"data_format"` |  |
| etlMapping.mappings[0].joining_props[0].props[1].fn | string | `"set"` |  |
| etlMapping.mappings[0].joining_props[0].props[1].name | string | `"data_type"` |  |
| etlMapping.mappings[0].joining_props[0].props[1].src | string | `"data_type"` |  |
| etlMapping.mappings[0].joining_props[0].props[2].fn | string | `"set"` |  |
| etlMapping.mappings[0].joining_props[0].props[2].name | string | `"_file_id"` |  |
| etlMapping.mappings[0].joining_props[0].props[2].src | string | `"_file_id"` |  |
| etlMapping.mappings[0].joining_props[0].props[3].fn | string | `"set"` |  |
| etlMapping.mappings[0].joining_props[0].props[3].name | string | `"object_id"` |  |
| etlMapping.mappings[0].joining_props[0].props[3].src | string | `"object_id"` |  |
| etlMapping.mappings[0].name | string | `"dev_case"` |  |
| etlMapping.mappings[0].props[0].name | string | `"submitter_id"` |  |
| etlMapping.mappings[0].props[1].name | string | `"project_id"` |  |
| etlMapping.mappings[0].props[2].name | string | `"disease_type"` |  |
| etlMapping.mappings[0].props[3].name | string | `"primary_site"` |  |
| etlMapping.mappings[0].root | string | `"case"` |  |
| etlMapping.mappings[0].type | string | `"aggregator"` |  |
| etlMapping.mappings[1].category | string | `"data_file"` |  |
| etlMapping.mappings[1].doc_type | string | `"file"` |  |
| etlMapping.mappings[1].injecting_props.case.props[0].fn | string | `"set"` |  |
| etlMapping.mappings[1].injecting_props.case.props[0].name | string | `"_case_id"` |  |
| etlMapping.mappings[1].injecting_props.case.props[0].src | string | `"id"` |  |
| etlMapping.mappings[1].injecting_props.case.props[1].name | string | `"project_id"` |  |
| etlMapping.mappings[1].name | string | `"dev_file"` |  |
| etlMapping.mappings[1].props[0].name | string | `"object_id"` |  |
| etlMapping.mappings[1].props[1].name | string | `"md5sum"` |  |
| etlMapping.mappings[1].props[2].name | string | `"file_name"` |  |
| etlMapping.mappings[1].props[3].name | string | `"file_size"` |  |
| etlMapping.mappings[1].props[4].name | string | `"data_format"` |  |
| etlMapping.mappings[1].props[5].name | string | `"data_type"` |  |
| etlMapping.mappings[1].props[6].name | string | `"state"` |  |
| etlMapping.mappings[1].root | string | `"None"` |  |
| etlMapping.mappings[1].target_nodes[0].name | string | `"slide_image"` |  |
| etlMapping.mappings[1].target_nodes[0].path | string | `"slides.samples.cases"` |  |
| etlMapping.mappings[1].type | string | `"collector"` |  |
| image.spark.pullPolicy | string | `"IfNotPresent"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.spark.repository | string | `"quay.io/cdis/gen3-spark"` | The Docker image repository for the spark service |
| image.spark.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| image.tube.pullPolicy | string | `"IfNotPresent"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.tube.repository | string | `"quay.io/cdis/tube"` | The Docker image repository for the fence service |
| image.tube.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| legacySupport | bool | `false` |  |
| podAnnotations | map | `{}` | Annotations to add to the pod |
| resources | map | `{"spark":{"requests":{"cpu":0.3,"memory":"128Mi"}},"tube":{"requests":{"cpu":0.3,"memory":"128Mi"}}}` | Resource requests and limits for the containers in the pod |
| resources.spark.requests | map | `{"cpu":0.3,"memory":"128Mi"}` | The amount of resources that the container requests |
| resources.spark.requests.cpu | string | `0.3` | The amount of CPU requested |
| resources.spark.requests.memory | string | `"128Mi"` | The amount of memory requested |
| resources.tube.requests | map | `{"cpu":0.3,"memory":"128Mi"}` | The amount of resources that the container requests |
| resources.tube.requests.cpu | string | `0.3` | The amount of CPU requested |
| resources.tube.requests.memory | string | `"128Mi"` | The amount of memory requested |
| schedule | string | `"*/30 * * * *"` |  |
| suspendCronjob | bool | `true` |  |
