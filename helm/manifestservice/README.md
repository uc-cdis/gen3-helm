# manifestservice

![Version: 0.1.19](https://img.shields.io/badge/Version-0.1.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.16 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["manifestservice"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity to use for the deployment. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["manifestservice"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["manifestservice"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["manifestservice"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["manifestservice"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
| automountServiceAccountToken | bool | `false` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `[{"name":"REQUESTS_CA_BUNDLE","value":"/etc/ssl/certs/ca-certificates.crt"},{"name":"MANIFEST_SERVICE_CONFIG_PATH","value":"/var/gen3/config/config.json"},{"name":"GEN3_DEBUG","value":"False"}]` | Environment variables to pass to the container |
| externalSecrets | map | `{"createK8sManifestServiceSecret":false,"manifestserviceG3auto":null}` | External Secrets settings. |
| externalSecrets.createK8sManifestServiceSecret | string | `false` | Will create the Helm "manifestservice-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.manifestserviceG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "manifestservice-g3auto" |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any manifestservice secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/manifestservice","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/manifestservice"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| manifestserviceG3auto | map | `{"awsaccesskey":"","awssecretkey":"","bucketName":"testbucket","hostname":"testinstall","prefix":"test"}` | Values for manifestservice secret. |
| manifestserviceG3auto.awsaccesskey | string | `""` | AWS access key. |
| manifestserviceG3auto.awssecretkey | string | `""` | AWS secret access key. |
| manifestserviceG3auto.bucketName | string | `"testbucket"` | Bucket for the manifestservice to read and write to. |
| manifestserviceG3auto.prefix | string | `"test"` | Directory name to use within the s3 bucket. |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| partOf | string | `"Workspace-tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":0.1,"memory":"12Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"cpu":1,"memory":"512Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.cpu | string | `1` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":0.1,"memory":"12Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `0.1` | The amount of CPU requested |
| resources.requests.memory | string | `"12Mi"` | The amount of memory requested |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":""}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| terminationGracePeriodSeconds | int | `50` | Grace period that applies to the total time it takes for both the PreStop hook to execute and for the Container to stop normally. |
| volumeMounts | list | `[{"mountPath":"/var/gen3/config/","name":"config-volume","readOnly":true}]` | Volumes to mount to the container. |
| volumes | list | `[{"name":"config-volume","secret":{"secretName":"manifestservice-g3auto"}}]` | Volumes to attach to the container. |
