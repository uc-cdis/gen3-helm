# gen3

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

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
| file://../ambassador | ambassador | 0.1.1 |
| file://../arborist | arborist | 0.1.1 |
| file://../argo-wrapper | argo-wrapper | 0.1.0 |
| file://../audit | audit | 0.1.1 |
| file://../aws-es-proxy | aws-es-proxy | 0.1.1 |
| file://../common | common | 0.1.1 |
| file://../elasticsearch | elasticsearch | 0.1.0 |
| file://../fence | fence | 0.1.1 |
| file://../guppy | guppy | 0.1.1 |
| file://../hatchery | hatchery | 0.1.1 |
| file://../indexd | indexd | 0.1.1 |
| file://../manifestservice | manifestservice | 0.1.1 |
| file://../metadata | metadata | 0.1.1 |
| file://../peregrine | peregrine | 0.1.1 |
| file://../pidgin | pidgin | 0.1.1 |
| file://../portal | portal | 0.1.0 |
| file://../requestor | requestor | 0.1.1 |
| file://../revproxy | revproxy | 0.1.1 |
| file://../sheepdog | sheepdog | 0.1.1 |
| file://../ssjdispatcher | ssjdispatcher | 0.1.0 |
| file://../wts | wts | 0.1.2 |
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
| dbCreate | bool | `true` |  |
| dbRestore | bool | `false` |  |
| fence.enabled | bool | `true` |  |
| fence.image.repository | string | `nil` |  |
| fence.image.tag | string | `nil` |  |
| global.aws.account | string | `nil` |  |
| global.aws.enabled | bool | `false` |  |
| global.dbRestoreBucket | string | `"gen3-dummy-data-2"` |  |
| global.ddEnabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| global.dispatcherJobNum | int | `10` |  |
| global.environment | string | `"default"` |  |
| global.hostname | string | `"localhost"` |  |
| global.kubeBucket | string | `"kube-gen3"` |  |
| global.logsBucket | string | `"logs-gen3"` |  |
| global.netPolicy | bool | `true` |  |
| global.origins_allow_credentials | list | `[]` |  |
| global.portalApp | string | `"gitops"` |  |
| global.postgres.dbCreate | bool | `true` |  |
| global.postgres.master.host | string | `nil` |  |
| global.postgres.master.password | string | `nil` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| global.publicDataSets | bool | `true` |  |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` |  |
| global.syncFromDbgap | bool | `false` |  |
| global.tierAccessLevel | string | `"libre"` |  |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` |  |
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
