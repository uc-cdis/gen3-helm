# ssjdispatcher

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 ssjdispatcher

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.7 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["ssjdispatcher"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity to use for the deployment. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["ssjdispatcher"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["ssjdispatcher"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["ssjdispatcher"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["ssjdispatcher"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
| automountServiceAccountToken | bool | `true` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| awsRegion | string | `"us-east-1"` | AWS region to be used. |
| awsStsRegionalEndpoints | string | `"regional"` | AWS STS to issue temporary credentials to users and roles that make an AWS STS request. Values regional or global. |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| datadogLogsInjection | bool | `true` | If enabled, the Datadog Agent will automatically inject Datadog-specific metadata into your application logs. |
| datadogProfilingEnabled | bool | `true` | If enabled, the Datadog Agent will collect profiling data for your application using the Continuous Profiler. This data can be used to identify performance bottlenecks and optimize your application. |
| datadogTraceSampleRate | int | `1` | A value between 0 and 1, that represents the percentage of requests that will be traced. For example, a value of 0.5 means that 50% of requests will be traced. |
| dispatcherJobNum | string | `"10"` | Ssjdispater job number. |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
| gen3Namespace | string | `"default"` | Namespace to deploy the job. |
| global | map | `{"aws":{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","minAvialable":1,"netPolicy":true,"pdb":false,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","tierAccessLevel":"libre"}` | Global configuration options. |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy | bool | `true` | Whether network policies are enabled. |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres | map | `{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}}` | Postgres database configuration. |
| global.postgres.dbCreate | bool | `true` | Whether the database should be created. |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/ssjdispatcher","tag":"2022.08"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/ssjdispatcher"` | Docker repository. |
| image.tag | string | `"2022.08"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| indexing | string | `"707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/indexs3client:2022.08"` | Image to use for the "indexing" job. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | map | `{}` | Node Selector for the pods |
| partOf | string | `"Workspace-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podSecurityContext | map | `{"fsGroup":1000,"runAsUser":1000}` | Security context to apply to the pod |
| podSecurityContext.fsGroup | int | `1000` | Group that Kubernetes will change the permissions of all files in volumes to when volumes are mounted by a pod. |
| podSecurityContext.runAsUser | int | `1000` | User that all the processes will run under in the container. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"cpu":1,"memory":"2400Mi"},"requests":{"cpu":0.1,"memory":"128Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"cpu":1,"memory":"2400Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.cpu | string | `1` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"2400Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":0.1,"memory":"128Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `0.1` | The amount of CPU requested |
| resources.requests.memory | string | `"128Mi"` | The amount of memory requested |
| securityContext | map | `{}` | Security context for the containers in the pod |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":"ssjdispatcher-service-account"}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `"ssjdispatcher-service-account"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| ssjcreds | map | `{"jobName":"indexing","jobPassword":"replace_with_password","jobPattern":"s3://test-12345678901234-upload/*","jobRequestCpu":"500m","jobRequestMem":"0.5Gi","jobUrl":"http://indexd-service/index","jobUser":"ssj","metadataservicePassword":"replace_with_password","metadataserviceUrl":"http://revproxy-service/mds","metadataserviceUsername":"gateway","sqsUrl":"https://sqs.us-east-1.amazonaws.com/12345678901234/test-upload_data_upload"}` | Values for ssjdispatcher secret. |
| ssjcreds.jobName | string | `"indexing"` | Name of the ssj job. |
| ssjcreds.jobPassword | string | `"replace_with_password"` | Password for the job. |
| ssjcreds.jobPattern | string | `"s3://test-12345678901234-upload/*"` | URL upload pattern that will trigger an event in S3 to send a message to SQS. |
| ssjcreds.jobRequestCpu | string | `"500m"` | The amount of CPU the job requests. |
| ssjcreds.jobRequestMem | string | `"0.5Gi"` | The amount of memory the job requests. |
| ssjcreds.jobUrl | string | `"http://indexd-service/index"` | Indexd service URL. |
| ssjcreds.jobUser | string | `"ssj"` | Name of the user the job will run with. |
| ssjcreds.metadataservicePassword | string | `"replace_with_password"` | Password for the metadata service. |
| ssjcreds.metadataserviceUrl | string | `"http://revproxy-service/mds"` | URL to reach metadata service endpoint. |
| ssjcreds.metadataserviceUsername | string | `"gateway"` | Username for the metadata service. |
| ssjcreds.sqsUrl | string | `"https://sqs.us-east-1.amazonaws.com/12345678901234/test-upload_data_upload"` | Sqs queue to monitor. |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[{"mountPath":"/credentials.json","name":"ssjdispatcher-creds-volume","readOnly":true,"subPath":"credentials.json"}]` | Volumes to mount to the container. |
| volumes | list | `[{"name":"ssjdispatcher-creds-volume","secret":{"secretName":"ssjdispatcher-creds"}}]` | Volumes to attach to the container. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
