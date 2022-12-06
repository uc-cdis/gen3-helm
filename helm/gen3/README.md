# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

Helm chart to deploy Gen3 Data Commons

## Usage
<fill out>

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
| db_create | bool | `true` |  |
| db_restore | bool | `false` |  |
| fence.enabled | bool | `true` |  |
| fence.image.repository | string | `nil` |  |
| fence.image.tag | string | `nil` |  |
| global.aws.account | string | `nil` |  |
| global.aws.enabled | bool | `false` |  |
| global.dbRestoreBucket | string | `"gen3-dummy-data"` |  |
| global.ddEnabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| global.dispatcherJobNum | int | `10` |  |
| global.environment | string | `"default"` |  |
| global.hostname | string | `"localhost"` |  |
| global.kubeBucket | string | `"kube-gen3"` |  |
| global.logsBucket | string | `"logs-gen3"` |  |
| global.netPolicy | string | `"on"` |  |
| global.portalApp | string | `"gitops"` |  |
| global.postgres.db_create | bool | `true` |  |
| global.postgres.master.host | string | `nil` |  |
| global.postgres.master.password | string | `nil` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| global.publicDataSets | bool | `true` |  |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` |  |
| global.syncFromDbgap | bool | `false` |  |
| global.tierAccessLevel | string | `"libre"` |  |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` |  |
| guppy.enabled | bool | `true` |  |
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
| requestor.enabled | bool | `true` |  |
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
| ssjdispatcher.enabled | bool | `true` |  |
| ssjdispatcher.image.repository | string | `nil` |  |
| ssjdispatcher.image.tag | string | `nil` |  |
| wts.enabled | bool | `true` |  |
| wts.image.repository | string | `nil` |  |
| wts.image.tag | string | `nil` |  |

