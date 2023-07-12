# aws-es-proxy

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for AWS ES Proxy Service for gen3

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.7 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `false` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled or not |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| datadogLogsInjection | bool | `true` | If enabled, the Datadog Agent will automatically inject Datadog-specific metadata into your application logs. |
| datadogProfilingEnabled | bool | `true` | If enabled, the Datadog Agent will collect profiling data for your application using the Continuous Profiler. This data can be used to identify performance bottlenecks and optimize your application. |
| datadogTraceSampleRate | int | `1` | A value between 0 and 1, that represents the percentage of requests that will be traced. For example, a value of 0.5 means that 50% of requests will be traced. |
| esEndpoint | str | `"test.us-east-1.es.amazonaws.com"` | Elasticsearch endpoint in AWS |
| global | map | `{"ddEnabled":false,"environment":"default","minAvialable":1,"pdb":false}` | Global configuration options. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/aws-es-proxy","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/aws-es-proxy"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| partOf | string | `"Explorer-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `nil` | Annotations to add to the pod |
| ports | list | `[{"containerPort":9200}]` | List of container ports |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":0.1,"memory":"250Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":0.1,"memory":"250Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `0.1` | The amount of CPU requested |
| resources.requests.memory | string | `"250Mi"` | The amount of memory requested |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| secrets | map | `{"awsAccessKeyId":"","awsSecretAccessKey":""}` | Secret information |
| secrets.awsAccessKeyId | str | `""` | AWS access key ID |
| secrets.awsSecretAccessKey | str | `""` | AWS secret access key |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":9200,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `9200` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| volumeMounts | list | `[{"mountPath":"/root/.aws","name":"credentials","readOnly":true}]` | Volumes to mount to the pod. |
| volumes | list | `[{"name":"credentials","secret":{"secretName":"aws-es-proxy"}}]` | Volumes to attach to the pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
