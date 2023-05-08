# dicom-server

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 Dicom Server

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| datadogLogsInjection | bool | `true` | If enabled, the Datadog Agent will automatically inject Datadog-specific metadata into your application logs. |
| datadogProfilingEnabled | bool | `true` | If enabled, the Datadog Agent will collect profiling data for your application using the Continuous Profiler. This data can be used to identify performance bottlenecks and optimize your application. |
| datadogTraceSampleRate | int | `1` | A value between 0 and 1, that represents the percentage of requests that will be traced. For example, a value of 0.5 means that 50% of requests will be traced. |
| global | map | `{"ddEnabled":false,"environment":"default"}` | Global configuration options. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/gen3-orthanc","tag":"master"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/gen3-orthanc"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| partOf | string | `"Imaging"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| secrets | map | `{"authenticationEnabled":false,"dataBase":"postgres","enableIndex":true,"enableStorage":true,"host":"postgres-postgresql.postgres.svc.cluster.local","indexConnectionsCount":5,"lock":false,"password":"postgres","port":"5432","userName":"postgres"}` | Secret information |
| secrets.authenticationEnabled | bool | `false` | Whether or not the password protection is enabled. |
| secrets.dataBase | string | `"postgres"` | Database name for postgres. |
| secrets.enableIndex | bool | `true` | Whether to enable index. If set to "false", Orthanc will continue to use its default SQLite back-end. |
| secrets.enableStorage | bool | `true` | Whether to enable storage. If set to "false", Orthanc will continue to use its default filesystem storage area. |
| secrets.host | string | `"postgres-postgresql.postgres.svc.cluster.local"` | Hostname for postgres server. |
| secrets.indexConnectionsCount | int | `5` | The number of connections from the index plugin to the PostgreSQL database. |
| secrets.lock | bool | `false` | Whether to lock the database. |
| secrets.password | string | `"postgres"` | Password for Postgres. |
| secrets.port | string | `"5432"` | Port for Postgres. |
| secrets.userName | string | `"postgres"` | Username for postgres. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"targetport":8042}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.targetport | int | `8042` | The port on the host machine that traffic is directed to. |
| volumeMounts | list | `[{"mountPath":"/etc/orthanc/orthanc_config_overwrites.json","name":"config-volume-g3auto","readOnly":true,"subPath":"orthanc_config_overwrites.json"}]` | Volumes to mount to the pod. |
| volumes | list | `[{"name":"config-volume-g3auto","secret":{"secretName":"orthanc-g3auto"}}]` | Volumes to attach to the pod. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
