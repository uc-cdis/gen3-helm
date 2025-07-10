# gen3-workflow

![Version: 0.1.10](https://img.shields.io/badge/Version-0.1.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.20 |
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.47 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100},{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}]},"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}]}}` | Affinity to use for the deployment. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100},{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}]` | Option for scheduling to be required or preferred. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100}` | Weight value for preferred scheduling. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions | list | `[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]` | Label key for match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].values | list | `["spot"]` | Value for the match expression key. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1] | int | `{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}` | Weight value for preferred scheduling. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions | list | `[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]` | Label key for match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].values | list | `["SPOT"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["gen3-workflow"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["gen3-workflow"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
| automountServiceAccountToken | bool | `false` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":4,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled or not |
| autoscaling.maxReplicas | int | `4` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `[{"name":"DEBUG","value":"false"},{"name":"ARBORIST_URL","valueFrom":{"configMapKeyRef":{"key":"arborist_url","name":"manifest-global","optional":true}}}]` | Environment variables to pass to the container |
| externalSecrets | map | `{"createK8sGen3WorkflowSecret":false,"dbcreds":"","gen3workflowG3auto":""}` | External Secrets settings. |
| extraLabels | map | `{"dbgen3workflow":"yes","netnolimit":"yes","public":"yes"}` | Will completely override the extraLabels defined in the common chart's _label_setup.tpl |
| fullnameOverride | string | `""` | Override the full name of the chart, which is used as the name of resources created by the chart |
| funnel.Kubernetes | map | `{"JobsNamespace":"","Namespace":""}` | Kubernetes configuration for Funnel. |
| funnel.Kubernetes.JobsNamespace | string | `""` | Namespace where Funnel jobs will be created. |
| funnel.Kubernetes.Namespace | string | `""` | Namespace where Funnel server will be created. |
| funnel.Logger.level | string | `"info"` |  |
| funnel.Plugins | map | `{"Disabled":false,"Params":{"OidcClientId":"","OidcClientSecret":"","OidcTokenUrl":"","S3Url":""},"Path":"plugin-binaries/auth-plugin"}` | Configuration for the Funnel plugin. |
| funnel.Plugins.Params | map | `{"OidcClientId":"","OidcClientSecret":"","OidcTokenUrl":"","S3Url":""}` | Parameters to send to the Funnel plugin. |
| funnel.Plugins.Params.OidcClientId | string | `""` | OIDC client ID for Funnel plugin. |
| funnel.Plugins.Params.OidcClientSecret | string | `""` | OIDC client secret for Funnel plugin. |
| funnel.Plugins.Params.OidcTokenUrl | string | `""` | OIDC token URL for Funnel plugin. |
| funnel.Plugins.Params.S3Url | string | `""` | S3 URL for Funnel plugin. |
| funnel.Plugins.Path | string | `"plugin-binaries/auth-plugin"` | Path to the directory where Funnel plugins are stored. |
| funnel.image | map | `{"initContainer":{"command":["cp","/app/build/plugins-go/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","pullPolicy":"Always","tag":"gen3-plugin"},"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel","tag":"feature-plugins"}` | Configuration for the Funnel container image. |
| funnel.image.initContainer | map | `{"command":["cp","/app/build/plugins-go/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","pullPolicy":"Always","tag":"gen3-plugin"}` | Configuration for the Funnel init container. |
| funnel.image.initContainer.command | list | `["cp","/app/build/plugins-go/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| funnel.image.initContainer.image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| funnel.image.initContainer.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.initContainer.tag | string | `"gen3-plugin"` | The Docker image tag for the Funnel init/plugin container. |
| funnel.image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.repository | string | `"quay.io/ohsu-comp-bio/funnel"` | The Docker image repository for the Funnel service. |
| funnel.image.tag | string | `"feature-plugins"` | The Docker image tag for the Funnel service. |
| funnel.mongodb.readinessProbe.enabled | bool | `true` |  |
| funnel.mongodb.readinessProbe.failureThreshold | int | `10` |  |
| funnel.mongodb.readinessProbe.initialDelaySeconds | int | `20` |  |
| funnel.mongodb.readinessProbe.periodSeconds | int | `10` |  |
| funnel.mongodb.readinessProbe.timeoutSeconds | int | `10` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any gen3-workflow secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.netPolicy | map | `{"enabled":false}` | Network policy settings. |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.postgres.dbCreate | bool | `false` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/gen3-workflow","tag":"feat_plugin-support"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.repository | string | `"quay.io/cdis/gen3-workflow"` | The Docker image repository for the gen3workflow service |
| image.tag | string | `"feat_plugin-support"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| initEnv | list | `{}` | Volumes to attach to the init container. |
| initVolumeMounts | list | `[]` | Volumes to mount to the init container. |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. This can be used to provide a unique name for a chart |
| nodeSelector | map | `{}` | Node Selector for the pods |
| partOf | string | `"Workflow_Execution"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `{}` | Annotations to add to the pod |
| podSecurityContext | map | `{}` | Security context for the pod |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of desired replicas |
| resources | map | `{}` | Resource requests and limits for the containers in the pod |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| securityContext | map | `{}` | Security context for the containers in the pod |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Configuration for the service |
| service.port | int | `80` | Port on which the service is exposed |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{"eks.amazonaws.com/role-arn":null},"create":true,"name":"gen3-workflow-sa"}` | Service account to use or create. |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `nil` | The Amazon Resource Name (ARN) of the role to associate with the service account |
| serviceAccount.create | bool | `true` | Whether to create a service account |
| serviceAccount.name | string | `"gen3-workflow-sa"` | The name of the service account |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[]` | Volumes to mount to the container. |
| volumes | list | `[]` | Volumes to attach to the container. |
| workflowConfig.debug | bool | `true` | Whether to enable debug mode for the workflow service. |
| workflowConfig.enablePrometheusMetrics | bool | `true` | Whether to enable Prometheus metrics for the workflow service. |
| workflowConfig.kmsEncryptionEnabled | bool | `false` | Whether to enable KMS encryption for the workflow service. |
| workflowConfig.taskImageWhitelist | list | `["*"]` | Whitelist of task images that can be used in the workflow service. |
| workflowConfig.tesServerUrl | string | `"http://funnel:8000"` | The URL of the TES server. |
