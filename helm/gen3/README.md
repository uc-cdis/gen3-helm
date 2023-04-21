# gen3

![Version: 0.1.11](https://img.shields.io/badge/Version-0.1.11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

Helm chart to deploy Gen3 Data Commons

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ahilt | <ahilt@uchicago.edu> |  |
| ajoaugustine | <ajoa@uchicago.edu> |  |
| emalinowski | <emalinowski@uchicago.edu> |  |
| EliseCastle23 | <elisemcastle@uchicago.edu> |  |
| jawadqur | <qureshi@uchicago.edu> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../ambassador | ambassador | 0.1.6 |
| file://../arborist | arborist | 0.1.6 |
| file://../argo-wrapper | argo-wrapper | 0.1.2 |
| file://../audit | audit | 0.1.6 |
| file://../aws-es-proxy | aws-es-proxy | 0.1.4 |
| file://../common | common | 0.1.6 |
| file://../elasticsearch | elasticsearch | 0.1.3 |
| file://../fence | fence | 0.1.7 |
| file://../guppy | guppy | 0.1.6 |
| file://../hatchery | hatchery | 0.1.4 |
| file://../indexd | indexd | 0.1.8 |
| file://../manifestservice | manifestservice | 0.1.7 |
| file://../metadata | metadata | 0.1.6 |
| file://../peregrine | peregrine | 0.1.7 |
| file://../pidgin | pidgin | 0.1.5 |
| file://../portal | portal | 0.1.5 |
| file://../requestor | requestor | 0.1.6 |
| file://../revproxy | revproxy | 0.1.8 |
| file://../sheepdog | sheepdog | 0.1.8 |
| file://../ssjdispatcher | ssjdispatcher | 0.1.3 |
| file://../wts | wts | 0.1.8 |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ambassador | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for ambassador chart. |
| ambassador.enabled | bool | `true` | Whether to deploy the ambassador subchart. |
| ambassador.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| ambassador.image.repository | string | `nil` | The Docker image repository for the ambassador service. |
| ambassador.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| arborist | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for arborist chart. |
| arborist.enabled | bool | `true` | Whether to deploy the arborist subchart. |
| arborist.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| arborist.image.repository | string | `nil` | The Docker image repository for the arborist service. |
| arborist.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| argo-wrapper | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for argo-wrapper chart. |
| argo-wrapper.enabled | bool | `true` | Whether to deploy the argo-wrapper subchart. |
| argo-wrapper.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| argo-wrapper.image.repository | string | `nil` | The Docker image repository for the argo-wrapper service. |
| argo-wrapper.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| audit | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for audit chart. |
| audit.enabled | bool | `true` | Whether to deploy the audit subchart. |
| audit.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| audit.image.repository | string | `nil` | The Docker image repository for the audit service. |
| audit.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| aws-es-proxy | map | `{"enabled":false}` | Configurations for aws-es-proxy chart. |
| aws-es-proxy.enabled | bool | `false` | Whether to deploy the aws-es-proxy subchart. |
| fence | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for fence chart. |
| fence.enabled | bool | `true` | Whether to deploy the fence subchart. |
| fence.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| fence.image.repository | string | `nil` | The Docker image repository for the fence service. |
| fence.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| global | map | `{"aws":{"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","tierAccessLimit":1000,"userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.aws | map | `{"enabled":false}` | AWS configuration |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. Deploys postgres/es charts alongside gen3. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
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
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| global.tierAccessLimit | int | `1000` | Only relevant if tireAccessLevel is set to "regular". Summary charts below this limit will not appear for aggregated data. |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` | Path to the user.yaml file in S3. |
| guppy | map | `{"enabled":false,"image":{"repository":null,"tag":null}}` | Configurations for guppy chart. |
| guppy.enabled | bool | `false` | Whether to deploy the guppy subchart. |
| guppy.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| guppy.image.repository | string | `nil` | The Docker image repository for the guppy service. |
| guppy.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| hatchery | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for hatchery chart. |
| hatchery.enabled | bool | `true` | Whether to deploy the hatchery subchart. |
| hatchery.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| hatchery.image.repository | string | `nil` | The Docker image repository for the hatchery service. |
| hatchery.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| indexd | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for indexd chart. |
| indexd.enabled | bool | `true` | Whether to deploy the indexd subchart. |
| indexd.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| indexd.image.repository | string | `nil` | The Docker image repository for the indexd service. |
| indexd.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| manifestservice | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for manifest service chart. |
| manifestservice.enabled | bool | `true` | Whether to deploy the manifest service subchart. |
| manifestservice.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| manifestservice.image.repository | string | `nil` | The Docker image repository for the manifest service service. |
| manifestservice.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| metadata | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for metadata chart. |
| metadata.enabled | bool | `true` | Whether to deploy the metadata subchart. |
| metadata.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| metadata.image.repository | string | `nil` | The Docker image repository for the metadata service. |
| metadata.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| peregrine | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for peregrine chart. |
| peregrine.enabled | bool | `true` | Whether to deploy the peregrine subchart. |
| peregrine.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| peregrine.image.repository | string | `nil` | The Docker image repository for the peregrine service. |
| peregrine.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| pidgin | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for pidgin chart. |
| pidgin.enabled | bool | `true` | Whether to deploy the pidgin subchart. |
| pidgin.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| pidgin.image.repository | string | `nil` | The Docker image repository for the pidgin service. |
| pidgin.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| portal | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for portal chart. |
| portal.enabled | bool | `true` | Whether to deploy the portal subchart. |
| portal.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| portal.image.repository | string | `nil` | The Docker image repository for the portal service. |
| portal.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| postgresql | map | `{"primary":{"persistence":{"enabled":true}}}` | To configure postgresql subchart Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `true` | Option to persist the dbs data. |
| requestor | map | `{"enabled":false,"image":{"repository":null,"tag":null}}` | Configurations for requestor chart. |
| requestor.enabled | bool | `false` | Whether to deploy the requestor subchart. |
| requestor.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| requestor.image.repository | string | `nil` | The Docker image repository for the requestor service. |
| requestor.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| revproxy | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for revproxy chart. |
| revproxy.enabled | bool | `true` | Whether to deploy the revproxy subchart. |
| revproxy.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| revproxy.image.repository | string | `nil` | The Docker image repository for the revproxy service. |
| revproxy.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| secrets | map | `{"awsAccessKeyId":"test","awsSecretAccessKey":"test"}` | AWS credentials to access the db restore job S3 bucket |
| secrets.awsAccessKeyId | string | `"test"` | AWS access key. |
| secrets.awsSecretAccessKey | string | `"test"` | AWS secret access key. |
| sheepdog | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for sheepdog chart. |
| sheepdog.enabled | bool | `true` | Whether to deploy the sheepdog subchart. |
| sheepdog.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| sheepdog.image.repository | string | `nil` | The Docker image repository for the sheepdog service. |
| sheepdog.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| ssjdispatcher | map | `{"enabled":false,"image":{"repository":null,"tag":null}}` | Configurations for ssjdispatcher chart. |
| ssjdispatcher.enabled | bool | `false` | Whether to deploy the ssjdispatcher subchart. |
| ssjdispatcher.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| ssjdispatcher.image.repository | string | `nil` | The Docker image repository for the ssjdispatcher service. |
| ssjdispatcher.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| tags.dev | bool | `false` |  |
| wts | map | `{"enabled":true,"image":{"repository":null,"tag":null}}` | Configurations for wts chart. |
| wts.enabled | bool | `true` | Whether to deploy the wts subchart. |
| wts.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| wts.image.repository | string | `nil` | The Docker image repository for the wts service. |
| wts.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
