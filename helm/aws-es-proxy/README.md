# aws-es-proxy

![Version: 0.1.37](https://img.shields.io/badge/Version-0.1.37-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for AWS ES Proxy Service for gen3

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.30 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `false` | Automount the default service account token |
| autoscaling | object | `{}` |  |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| esEndpoint | str | `"test.us-east-1.es.amazonaws.com"` | Elasticsearch endpoint in AWS |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `10` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.crossplane | map | `{"accountId":123456789012,"enabled":false,"oidcProviderUrl":"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890","providerConfigName":"provider-aws","s3":{"kmsKeyId":null,"versioningEnabled":false}}` | Kubernetes configuration |
| global.crossplane.accountId | string | `123456789012` | The account ID of the AWS account. |
| global.crossplane.enabled | bool | `false` | Set to true if deploying to AWS and want to use crossplane for AWS resources. |
| global.crossplane.oidcProviderUrl | string | `"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890"` | OIDC provider URL. This is used for authentication of roles/service accounts. |
| global.crossplane.providerConfigName | string | `"provider-aws"` | The name of the crossplane provider config. |
| global.crossplane.s3.kmsKeyId | string | `nil` | The kms key id for the s3 bucket. |
| global.crossplane.s3.versioningEnabled | bool | `false` | Whether to use s3 bucket versioning. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any audit secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.minAvailable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy.enabled | bool | `false` |  |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/aws-es-proxy","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/aws-es-proxy"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| netPolicy | map | `{"egressApps":["arranger","arranger-server","arranger-dashboard","guppy","metadata","spark","tube"],"ingressApps":["arranger","arranger-server","arranger-dashboard","guppy","metadata","spark","tube"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["arranger","arranger-server","arranger-dashboard","guppy","metadata","spark","tube"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["arranger","arranger-server","arranger-dashboard","guppy","metadata","spark","tube"]` | List of app labels that require ingress to this service |
| partOf | string | `"Explorer-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `nil` | Annotations to add to the pod |
| ports | list | `[{"containerPort":9200}]` | List of container ports |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"memory":"250Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"250Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"250Mi"` | The amount of memory requested |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information to access AWS ES cluster. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":9200,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `9200` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":"aws-es-proxy-sa"}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `"aws-es-proxy-sa"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| volumeMounts | list | `[{"mountPath":"/root/.aws","name":"credentials","readOnly":true}]` | Volumes to mount to the pod. |
| volumes | list | `nil` | Volumes to attach to the pod |
