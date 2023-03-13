# gen3

![Version: 0.1.5](https://img.shields.io/badge/Version-0.1.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

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
| file://../ambassador | ambassador | 0.1.3 |
| file://../arborist | arborist | 0.1.4 |
| file://../argo-wrapper | argo-wrapper | 0.1.0 |
| file://../audit | audit | 0.1.4 |
| file://../aws-es-proxy | aws-es-proxy | 0.1.2 |
| file://../common | common | 0.1.3 |
| file://../elasticsearch | elasticsearch | 0.1.1 |
| file://../fence | fence | 0.1.4 |
| file://../guppy | guppy | 0.1.3 |
| file://../hatchery | hatchery | 0.1.2 |
| file://../indexd | indexd | 0.1.4 |
| file://../manifestservice | manifestservice | 0.1.2 |
| file://../metadata | metadata | 0.1.4 |
| file://../peregrine | peregrine | 0.1.5 |
| file://../pidgin | pidgin | 0.1.3 |
| file://../portal | portal | 0.1.2 |
| file://../requestor | requestor | 0.1.4 |
| file://../revproxy | revproxy | 0.1.4 |
| file://../sheepdog | sheepdog | 0.1.4 |
| file://../ssjdispatcher | ssjdispatcher | 0.1.1 |
| file://../wts | wts | 0.1.5 |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ambassador.enabled | bool | `true` |  |
| ambassador.image.repository | string | `nil` |  |
| ambassador.image.tag | string | `nil` |  |
| arborist.enabled | bool | `true` |  |
| arborist.image.repository | string | `nil` |  |
| arborist.image.tag | string | `nil` |  |
| argo-wrapper.enabled | bool | `true` |  |
| argo-wrapper.image.repository | string | `nil` |  |
| argo-wrapper.image.tag | string | `nil` |  |
| audit.enabled | bool | `true` |  |
| audit.image.repository | string | `nil` |  |
| audit.image.tag | string | `nil` |  |
| aws-es-proxy.enabled | bool | `false` |  |
| fence.enabled | bool | `true` |  |
| fence.image.repository | string | `nil` |  |
| fence.image.tag | string | `nil` |  |
| global | map | `{"aws":{"account":{"aws_access_key_id":null,"aws_secret_access_key":null},"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","gcp":true,"hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","tls":{"cert":null,"key":null},"userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.aws.account | map | `{"aws_access_key_id":null,"aws_secret_access_key":null}` | Credentials for AWS |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.gcp | map | `true` | AWS configuration |
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
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` | Path to the user.yaml file in S3. |
| guppy.enabled | bool | `false` |  |
| guppy.image.repository | string | `nil` |  |
| guppy.image.tag | string | `nil` |  |
| hatchery.enabled | bool | `true` |  |
| hatchery.image.repository | string | `nil` |  |
| hatchery.image.tag | string | `nil` |  |
| indexd.enabled | bool | `true` |  |
| indexd.image.repository | string | `nil` |  |
| indexd.image.tag | string | `nil` |  |
| manifestservice.enabled | bool | `true` |  |
| manifestservice.image.repository | string | `nil` |  |
| manifestservice.image.tag | string | `nil` |  |
| metadata.enabled | bool | `true` |  |
| metadata.image.repository | string | `nil` |  |
| metadata.image.tag | string | `nil` |  |
| peregrine.enabled | bool | `true` |  |
| peregrine.image.repository | string | `nil` |  |
| peregrine.image.tag | string | `nil` |  |
| pidgin.enabled | bool | `true` |  |
| pidgin.image.repository | string | `nil` |  |
| pidgin.image.tag | string | `nil` |  |
| portal.enabled | bool | `true` |  |
| portal.image.repository | string | `nil` |  |
| portal.image.tag | string | `nil` |  |
| postgresql.primary.persistence.enabled | bool | `false` |  |
| requestor.enabled | bool | `false` |  |
| requestor.image.repository | string | `nil` |  |
| requestor.image.tag | string | `nil` |  |
| revproxy.enabled | bool | `true` |  |
| revproxy.image.repository | string | `nil` |  |
| revproxy.image.tag | string | `nil` |  |
| secrets.awsAccessKeyId | string | `"test"` |  |
| secrets.awsSecretAccessKey | string | `"test"` |  |
| sheepdog.enabled | bool | `true` |  |
| sheepdog.image.repository | string | `nil` |  |
| sheepdog.image.tag | string | `nil` |  |
| ssjdispatcher.enabled | bool | `false` |  |
| ssjdispatcher.image.repository | string | `nil` |  |
| ssjdispatcher.image.tag | string | `nil` |  |
| tags.dev | bool | `false` |  |
| wts.enabled | bool | `true` |  |
| wts.image.repository | string | `nil` |  |
| wts.image.tag | string | `nil` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
