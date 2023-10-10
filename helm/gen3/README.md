# gen3

![Version: 0.1.21](https://img.shields.io/badge/Version-0.1.21-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

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
| file://../ambassador | ambassador | 0.1.8 |
| file://../arborist | arborist | 0.1.8 |
| file://../argo-wrapper | argo-wrapper | 0.1.4 |
| file://../audit | audit | 0.1.9 |
| file://../aws-es-proxy | aws-es-proxy | 0.1.6 |
| file://../common | common | 0.1.7 |
| file://../elasticsearch | elasticsearch | 0.1.5 |
| file://../fence | fence | 0.1.13 |
| file://../frontend-framework | frontend-framework | 0.0.9 |
| file://../guppy | guppy | 0.1.8 |
| file://../hatchery | hatchery | 0.1.6 |
| file://../indexd | indexd | 0.1.10 |
| file://../manifestservice | manifestservice | 0.1.10 |
| file://../metadata | metadata | 0.1.8 |
| file://../peregrine | peregrine | 0.1.9 |
| file://../pidgin | pidgin | 0.1.7 |
| file://../portal | portal | 0.1.8 |
| file://../requestor | requestor | 0.1.8 |
| file://../revproxy | revproxy | 0.1.11 |
| file://../sheepdog | sheepdog | 0.1.10 |
| file://../sower | sower | 0.1.6 |
| file://../ssjdispatcher | ssjdispatcher | 0.1.6 |
| file://../wts | wts | 0.1.10 |
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
| aws-es-proxy.enabled | bool | `false` | Whether to deploy the aws-es-proxy subchart. |
| aws-es-proxy.esEndpoint | str | `"test.us-east-1.es.amazonaws.com"` | Elasticsearch endpoint in AWS |
| aws-es-proxy.secrets | map | `{"awsAccessKeyId":"","awsSecretAccessKey":""}` | Secret information |
| aws-es-proxy.secrets.awsAccessKeyId | str | `""` | AWS access key ID for aws-es-proxy |
| aws-es-proxy.secrets.awsSecretAccessKey | str | `""` | AWS secret access key for aws-es-proxy |
| fence | map | `{"FENCE_CONFIG":null,"USER_YAML":null,"enabled":true,"image":{"repository":null,"tag":null},"usersync":{"addDbgap":false,"custom_image":null,"onlyDbgap":false,"schedule":"*/30 * * * *","secrets":{"awsAccessKeyId":"","awsSecretAccessKey":""},"slack_send_dbgap":false,"slack_webhook":"None","syncFromDbgap":false,"userYamlS3Path":"s3://cdis-gen3-users/helm-test/user.yaml","usersync":false}}` | Configurations for fence chart. |
| fence.FENCE_CONFIG | map | `nil` | Configuration settings for Fence app |
| fence.USER_YAML | string | `nil` | USER YAML. Passed in as a multiline string. |
| fence.enabled | bool | `true` | Whether to deploy the fence subchart. |
| fence.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| fence.image.repository | string | `nil` | The Docker image repository for the fence service. |
| fence.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| fence.usersync | map | `{"addDbgap":false,"custom_image":null,"onlyDbgap":false,"schedule":"*/30 * * * *","secrets":{"awsAccessKeyId":"","awsSecretAccessKey":""},"slack_send_dbgap":false,"slack_webhook":"None","syncFromDbgap":false,"userYamlS3Path":"s3://cdis-gen3-users/helm-test/user.yaml","usersync":false}` | Configuration options for usersync cronjob. |
| fence.usersync.addDbgap | bool | `false` | Force attempting a dbgap sync if "true", falls back on user.yaml |
| fence.usersync.custom_image | string | `nil` | To set a custom image for pulling the user.yaml file from S3. Default is the Gen3 Awshelper image. |
| fence.usersync.onlyDbgap | bool | `false` | Forces ONLY a dbgap sync if "true", IGNORING user.yaml |
| fence.usersync.schedule | string | `"*/30 * * * *"` | The cron schedule expression to use in the usersync cronjob. Runs every 30 minutes by default. |
| fence.usersync.secrets | map | `{"awsAccessKeyId":"","awsSecretAccessKey":""}` | Secret information |
| fence.usersync.secrets.awsAccessKeyId | str | `""` | AWS access key ID for usersync S3 bucket |
| fence.usersync.secrets.awsSecretAccessKey | str | `""` | AWS secret access key for usersync S3 bucket |
| fence.usersync.slack_send_dbgap | bool | `false` | Will echo what files we are seeing on dbgap ftp to Slack. |
| fence.usersync.slack_webhook | string | `"None"` | Slack webhook endpoint used with certain jobs. |
| fence.usersync.syncFromDbgap | bool | `false` | Whether to sync data from dbGaP. |
| fence.usersync.userYamlS3Path | string | `"s3://cdis-gen3-users/helm-test/user.yaml"` | Path to the user.yaml file in S3. |
| fence.usersync.usersync | bool | `false` | Whether to run Fence usersync or not. |
| frontend-framework.enabled | bool | `true` | Whether to deploy the frontend-framework subchart. |
| frontend-framework.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| frontend-framework.image.repository | string | `nil` | The Docker image repository for the guppy service. |
| frontend-framework.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| gitops.createdby | string | `nil` | - createdby.png - base64 |
| gitops.css | string | `nil` | - multiline string - gitops.css |
| gitops.favicon | string | `nil` | - favicon in base64 |
| gitops.json | string | `nil` | multiline string - gitops.json |
| gitops.logo | string | `nil` | - logo in base64 |
| gitops.sponsors | string | `nil` |  |
| global | map | `{"aws":{"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","gcp":true,"hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","tierAccessLimit":1000,"tls":{"cert":null,"key":null},"userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Deploys postgres/elasticsearch for dev |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces in same cluster. |
| global.gcp | map | `true` | AWS configuration |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.netPolicy | bool | `true` | Whether network policies are enabled. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres | map | `{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}}` | Postgres database configuration. |
| global.postgres.dbCreate | bool | `true` | Whether the database create job should run. |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | global postgres master host |
| global.postgres.master.password | string | `nil` | global postgres master password |
| global.postgres.master.port | string | `"5432"` | global postgres master port |
| global.postgres.master.username | string | `"postgres"` | global postgres master username |
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
| hatchery | map | `{"enabled":true,"hatchery":{"containers":[{"args":["--NotebookApp.base_url=/lw-workspace/proxy/","--NotebookApp.default_url=/lab","--NotebookApp.password=''","--NotebookApp.token=''","--NotebookApp.shutdown_no_activity_timeout=5400","--NotebookApp.quit_button=False"],"command":["start-notebook.sh"],"cpu-limit":"1.0","env":{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"},"fs-gid":100,"gen3-volume-location":"/home/jovyan/.gen3","image":"quay.io/cdis/heal-notebooks:combined_tutorials__latest","lifecycle-post-start":["/bin/sh","-c","export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found; ln -s /data /home/$IAM/pd/; true"],"memory-limit":"2Gi","name":"(Tutorials) Example Analysis Jupyter Lab Notebooks","path-rewrite":"/lw-workspace/proxy/","ready-probe":"/lw-workspace/proxy/","target-port":8888,"use-tls":"false","user-uid":1000,"user-volume-location":"/home/jovyan/pd"}],"sidecarContainer":{"args":[],"command":["/bin/bash","./sidecar.sh"],"cpu-limit":"0.1","env":{"HOSTNAME":"{{ .Values.global.hostname }}","NAMESPACE":"{{ .Release.Namespace }}"},"image":"quay.io/cdis/ecs-ws-sidecar:master","lifecycle-pre-stop":["su","-c","echo test","-s","/bin/sh","root"],"memory-limit":"256Mi"}},"image":{"repository":null,"tag":null}}` | Configurations for hatchery chart. |
| hatchery.enabled | bool | `true` | Whether to deploy the hatchery subchart. |
| hatchery.hatchery.containers[0].cpu-limit | string | `"1.0"` | cpu limit of workspace container |
| hatchery.hatchery.containers[0].env | object | `{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"}` | environment variables for workspace container |
| hatchery.hatchery.containers[0].image | string | `"quay.io/cdis/heal-notebooks:combined_tutorials__latest"` | docker image for workspace |
| hatchery.hatchery.containers[0].memory-limit | string | `"2Gi"` | memory limit of workspace container |
| hatchery.hatchery.containers[0].name | string | `"(Tutorials) Example Analysis Jupyter Lab Notebooks"` | name of workspace |
| hatchery.hatchery.containers[0].target-port | int | `8888` | port to proxy traffic to in docker contaniner |
| hatchery.hatchery.sidecarContainer.args | list | `[]` | Arguments to pass to the sidecare container. |
| hatchery.hatchery.sidecarContainer.command | list | `["/bin/bash","./sidecar.sh"]` | Commands to run for the sidecar container. |
| hatchery.hatchery.sidecarContainer.cpu-limit | string | `"0.1"` | The maximum amount of CPU the sidecar container can use |
| hatchery.hatchery.sidecarContainer.env | map | `{"HOSTNAME":"{{ .Values.global.hostname }}","NAMESPACE":"{{ .Release.Namespace }}"}` | Environment variables to pass to the sidecar container |
| hatchery.hatchery.sidecarContainer.image | string | `"quay.io/cdis/ecs-ws-sidecar:master"` | The sidecar image. |
| hatchery.hatchery.sidecarContainer.memory-limit | string | `"256Mi"` | The maximum amount of memory the sidecar container can use |
| hatchery.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| hatchery.image.repository | string | `nil` | The Docker image repository for the hatchery service. |
| hatchery.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| indexd.defaultPrefix | string | `"PREFIX/"` | the default prefix for indexd records |
| indexd.enabled | bool | `true` | Whether to deploy the indexd subchart. |
| indexd.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| indexd.image.repository | string | `nil` | The Docker image repository for the indexd service. |
| indexd.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
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
| postgresql | map | `{"primary":{"persistence":{"enabled":false}}}` | To configure postgresql subchart Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| requestor.enabled | bool | `false` | Whether to deploy the requestor subchart. |
| requestor.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| requestor.image.repository | string | `nil` | The Docker image repository for the requestor service. |
| requestor.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| revproxy | map | `{"enabled":true,"image":{"repository":null,"tag":null},"ingress":{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local"}],"tls":[]}}` | Configurations for revproxy chart. |
| revproxy.enabled | bool | `true` | Whether to deploy the revproxy subchart. |
| revproxy.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| revproxy.image.repository | string | `nil` | The Docker image repository for the revproxy service. |
| revproxy.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| revproxy.ingress.annotations | map | `{}` | Annotations to add to the ingress. |
| revproxy.ingress.className | string | `""` | The ingress class name. |
| revproxy.ingress.enabled | bool | `false` | Whether to create the custom revproxy ingress |
| revproxy.ingress.hosts | list | `[{"host":"chart-example.local"}]` | Where to route the traffic. |
| revproxy.ingress.tls | list | `[]` | To secure an Ingress by specifying a secret that contains a TLS private key and certificate. |
| secrets | map | `{"awsAccessKeyId":"test","awsSecretAccessKey":"test"}` | AWS credentials to access the db restore job S3 bucket |
| secrets.awsAccessKeyId | string | `"test"` | AWS access key. |
| secrets.awsSecretAccessKey | string | `"test"` | AWS secret access key. |
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
| wts.enabled | bool | `true` | Whether to deploy the wts subchart. |
| wts.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| wts.image.repository | string | `nil` | The Docker image repository for the wts service. |
| wts.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
