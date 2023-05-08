# argo-wrapper

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 Argo Wrapper Service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["argo-wrapper"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity to use for the deployment. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["argo-wrapper"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["argo-wrapper"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["argo-wrapper"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["argo-wrapper"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
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
| environment | string | `"default"` | Environment name. |
| global | map | `{"ddEnabled":false,"environment":"default"}` | Global configuration options. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/argo-wrapper","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/argo-wrapper"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| indexdAdminUser | string | `"fence"` | Admin user for Indexd. |
| internalS3Bucket | string | `"argo-internal-bucket"` | Name of the internal Argo bucket for Argo artifacts (does not allow pre-signed URLs). |
| partOf | string | `"Apps-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `{"gen3.io/network-ingress":"argo-wrapper"}` | Annotations to add to the pod. |
| pvc | string | `"test-pvc"` | PVC for Argo. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"cpu":"100m","memory":"128Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"cpu":"100m","memory":"128Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.cpu | string | `"100m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"128Mi"` | The maximum amount of memory the container can use |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| s3Bucket | string | `"argo-artifact-downloadable"` | S3 bucket name for Argo artifacts (allows pre-signed URLs). |
| scalingGroups | list | `[{"user1":"workflow1"},{"user2":"workflow2"},{"user3":"workflow3"}]` | The workflow scaling groups to be used by Argo. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":8000,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `8000` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| volumeMounts | list | `[{"mountPath":"/argo.json","name":"argo-config","readOnly":true,"subPath":"argo.json"}]` | Volumes to mount to the pod. |
| volumes | list | `[{"configMap":{"items":[{"key":"argo.json","path":"argo.json"}],"name":"manifest-argo"},"name":"argo-config"}]` | Volumes to attach to the pod. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
