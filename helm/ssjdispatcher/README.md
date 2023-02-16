# ssjdispatcher

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 ssjdispatcher

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"ssjdispatcher"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| automountServiceAccountToken | bool | `true` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| awsRegion | string | `"us-east-1"` |  |
| awsStsRegionalEndpoints | string | `"regional"` |  |
| dispatcherJobNum | string | `"10"` |  |
| fullnameOverride | string | `""` |  |
| gen3Namespace | string | `"default"` |  |
| global | map | `{"aws":{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff.  |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.hostname | string | `"localhost"` | Hostname for the deployment.  |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.netPolicy | bool | `true` | Whether network policies are enabled. |
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
| global.syncFromDbgap | bool | `false` | Whether to sync data from dbGaP. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` | Path to the user.yaml file in S3. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"nginx"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| indexing | string | `"707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/indexs3client:2022.08"` |  |
| labels.netnolimit | string | `"yes"` |  |
| labels.public | string | `"yes"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | float | `1` |  |
| resources.limits.memory | string | `"2400Mi"` |  |
| resources.requests.cpu | float | `0.1` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext | object | `{}` |  |
| selectorLabels.app | string | `"ssjdispatcher"` |  |
| selectorLabels.release | string | `"production"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"ssjdispatcher-service-account"` |  |
| ssjcreds.jobName | string | `"indexing"` |  |
| ssjcreds.jobPassword | string | `"replace_with_password"` |  |
| ssjcreds.jobPattern | string | `"s3://test-12345678901234-upload/*"` |  |
| ssjcreds.jobRequestCpu | string | `"500m"` |  |
| ssjcreds.jobRequestMem | string | `"0.5Gi"` |  |
| ssjcreds.jobUrl | string | `"http://indexd-service/index"` |  |
| ssjcreds.jobUser | string | `"ssj"` |  |
| ssjcreds.metadataservicePassword | string | `"replace_with_password"` |  |
| ssjcreds.metadataserviceUrl | string | `"http://revproxy-service/mds"` |  |
| ssjcreds.metadataserviceUsername | string | `"gateway"` |  |
| ssjcreds.sqsUrl | string | `"https://sqs.us-east-1.amazonaws.com/12345678901234/test-upload_data_upload"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/credentials.json"` |  |
| volumeMounts[0].name | string | `"ssjdispatcher-creds-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"credentials.json"` |  |
| volumes[0].name | string | `"ssjdispatcher-creds-volume"` |  |
| volumes[0].secret.secretName | string | `"ssjdispatcher-creds"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
