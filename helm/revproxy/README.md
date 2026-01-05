# revproxy

![Version: 0.1.49](https://img.shields.io/badge/Version-0.1.49-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 revproxy

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.28 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{}` | Affinity to use for the deployment. |
| autoscaling | object | `{}` |  |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| enableRobotsTxt | bool | `false` | Whether to enable robots.txt generation and serving. |
| extraServices | map | `nil` | Configuration to add any extra service endpoints outside of gen3 to be served by revproxy |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `10` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"scheme":"internet-facing","wafv2":{"enabled":false,"wafAclArn":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.scheme | string | `"internet-facing"` | internal or internet-facing |
| global.aws.wafv2 | map | `{"enabled":false,"wafAclArn":null}` | WAF configuration |
| global.aws.wafv2.enabled | bool | `false` | Set to true if using AWS WAFv2 |
| global.aws.wafv2.wafAclArn | string | `nil` | ARN for the WAFv2 ACL. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
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
| global.tierAccessLimit | int | `"1000"` | Only relevant if tireAccessLevel is set to "regular". Summary charts below this limit will not appear for aggregated data. |
| global.tls.cert | string | `nil` |  |
| global.tls.key | string | `nil` |  |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/nginx","tag":"master"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/nginx"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| ingress | map | `{"annotations":{},"aws":{"group":"","sslPolicy":"ELBSecurityPolicy-TLS13-1-2-Res-FIPS-2023-04"},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | Configuration for revproxy ingress. |
| ingress.annotations | map | `{}` | Annotations to add to the ingress. |
| ingress.className | string | `""` | The ingress class name. |
| ingress.enabled | bool | `false` | Whether to create the ingress |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Where to route the traffic. |
| ingress.tls | list | `[]` | To secure an Ingress by specifying a secret that contains a TLS private key and certificate. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| netPolicy | map | `{"egressApps":["portal","sowerjob"],"ingressApps":["portal","sowerjob"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["portal","sowerjob"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["portal","sowerjob"]` | List of app labels that require ingress to this service |
| nodeSelector | map | `{}` | Node selector labels. |
| partOf | string | `"Front-End"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `{}` | Annotations to add to the pod. |
| podSecurityContext | map | `{}` | Pod-level security context. |
| postgres | map | `{"database":null,"dbCreate":null,"dbRestore":false,"host":null,"password":null,"port":"5432","username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `nil` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"512Mi"},"requests":{"memory":"12Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"512Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"12Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"12Mi"` | The amount of memory requested |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| revproxyElb | map | `{"gen3SecretsFolder":"Gen3Secrets","sslCert":"","targetPortHTTP":80,"targetPortHTTPS":443}` | Configuration for depricated revproxy service ELB. |
| securityContext | map | `{}` | Container-level security context. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"NodePort"}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.type | string | `"NodePort"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":""}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations to use for the deployment. |
| userhelperEnabled | bool | `false` |  |
