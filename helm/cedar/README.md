# cedar

![Version: 0.1.14](https://img.shields.io/badge/Version-0.1.14-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 cedar wrapper

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.25 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{}` | Affinity to use for the deployment. |
| autoscaling | object | `{}` |  |
| cedarIngestion | map | `{"enabled":true}` | Whether or not to deploy the cedar ingestion job. |
| cedar_client_job_enabled | bool | `true` | Whether to enable OIDC job. You can disable after inital run to ensure oidc clients are created. |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| externalSecrets | map | `{"cedarAPIKey":null,"cedarDirectoryId":null,"cedarG3auto":null,"createCedarClientSecret":true}` | External Secrets settings. |
| externalSecrets.cedarAPIKey | string | `nil` | Will override the name of the aws secrets manager secret. Default is "cedar-api-key". |
| externalSecrets.cedarDirectoryId | string | `nil` | Will override the name of the aws secrets manager secret. Default is "cedar-directory-id". |
| externalSecrets.cedarG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "cedar-g3auto". |
| externalSecrets.createCedarClientSecret | bool | `true` | Will create the cedar secret or pull it from AWS Secrets Manager. Default is true. |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
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
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any cedar secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.minAvailable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy | map | `{"enabled":false}` | Controls network policy settings |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres.dbCreate | bool | `true` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/cedar","tag":"master"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/cedar"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| ingestion | map | `{"image":"quay.io/cdis/awshelper:master"}` | Cedar configuration for ingestion job. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | map | `{}` | Node Selector for the pods |
| partOf | string | `"Explorer-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `{}` | Annotations to add to the pod. |
| podSecurityContext | map | `{}` | Security context for the pod |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"autoscaling":{"averageCPUValue":"500m","averageMemoryValue":"500Mi","enabled":false,"maxReplicas":10,"minReplicas":1},"limits":{"memory":"512Mi"},"requests":{"memory":"120Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"512Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"120Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"120Mi"` | The amount of memory requested |
| roleName | string | `"cedar"` | Name of the role to be used for the role binding. |
| secrets | map | `{"apiKey":"","cedarDirectoryId":""}` | Values for cedar secret. |
| secrets.apiKey | str | `""` | API key for Cedar. |
| secrets.cedarDirectoryId | string | `""` | Values for Cedar directory ID. |
| securityContext | map | `{}` | Security context for the containers in the pod |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"httpPort":80,"httpsPort":443,"targetPort":8000,"type":"ClusterIP"}` | Configuration for the service |
| service.httpPort | int | `80` | Port on which the service is exposed |
| service.httpsPort | int | `443` | Secure port on which the service is exposed |
| service.targetPort | int | `8000` | Port on which the service is exposed for Cedar API |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":""}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for the pods |
