# gen3

![Version: 0.1.19](https://img.shields.io/badge/Version-0.1.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

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
| https://helm.elastic.co | elasticsearch | 7.10.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ambassador.enabled | bool | `true` | Whether to deploy the ambassador subchart. |
| arborist.enabled | bool | `true` | Whether to deploy the arborist subchart. |
| argo-wrapper.enabled | bool | `false` | Whether to deploy the argo-wrapper subchart. |
| audit.enabled | bool | `true` | Whether to deploy the audit subchart. |
| aws-es-proxy.enabled | bool | `false` | Whether to deploy the aws-es-proxy subchart. |
| aws-es-proxy.esEndpoint | str | `"test.us-east-1.es.amazonaws.com"` | Elasticsearch endpoint in AWS |
| aws-es-proxy.secrets | map | `{"awsAccessKeyId":"","awsSecretAccessKey":""}` | Secret information |
| aws-es-proxy.secrets.awsAccessKeyId | str | `""` | AWS access key ID for aws-es-proxy |
| aws-es-proxy.secrets.awsSecretAccessKey | str | `""` | AWS secret access key for aws-es-proxy |
| elasticsearch.clusterHealthCheckParams | string | `"wait_for_status=yellow&timeout=1s"` |  |
| elasticsearch.clusterName | string | `"gen3-elasticsearch"` |  |
| elasticsearch.maxUnavailable | int | `0` |  |
| elasticsearch.replicas | int | `1` |  |
| elasticsearch.singleNode | bool | `true` |  |
| etl.enabled | bool | `true` | Whether to deploy the etl subchart. |
| fence.enabled | bool | `true` | Whether to deploy the fence subchart. |
| fence.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| fence.image.repository | string | `nil` | The Docker image repository for the fence service. |
| fence.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| frontend-framework.enabled | bool | `true` | Whether to deploy the frontend-framework subchart. |
| frontend-framework.image | map | `{"repository":null,"tag":null}` | Docker image information. |
| frontend-framework.image.repository | string | `nil` | The Docker image repository for the guppy service. |
| frontend-framework.image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| global | map | `{"aws":{"account":{"aws_access_key_id":null,"aws_secret_access_key":null},"enabled":false},"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","frontendRoot":"gen3ff","gcp":true,"hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","tls":{"cert":null,"key":null},"userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.aws.account | map | `{"aws_access_key_id":null,"aws_secret_access_key":null}` | Credentials for AWS |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.useLocalSecret | map | `{"enabled":false,"localSecretName":null}` | Local secret setting if using a pre-exising secret. |
| global.aws.useLocalSecret.enabled | bool | `false` | Set to true if you would like to use a secret that is already running on your cluster. |
| global.aws.useLocalSecret.localSecretName | string | `nil` | Name of the local secret. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Deploys postgres/elasticsearch for dev |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `10` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.frontendRoot | string | `"gen3ff"` | which frontend to use "portal" or "gen3ff" |
| global.gcp | map | `true` | AWS configuration |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.manifestGlobalExtraValues | map | `{}` | If you would like to add any extra values to the manifest-global configmap. |
| global.netPolicy | bool | `true` | Whether network policies are enabled. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres.dbCreate | bool | `true` | Whether the database create job should run. |
| global.postgres.master.host | string | `nil` | global postgres master host |
| global.postgres.master.password | string | `nil` | global postgres master password |
| global.postgres.master.port | string | `"5432"` | global postgres master port |
| global.postgres.master.username | string | `"postgres"` | global postgres master username |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| global.tierAccessLimit | int | `"1000"` | Only relevant if tireAccessLevel is set to "regular". Summary charts below this limit will not appear for aggregated data. |
| guppy.enabled | bool | `false` | Whether to deploy the guppy subchart. |
| hatchery.enabled | bool | `true` | Whether to deploy the hatchery subchart. |
| hatchery.hatchery.containers[0].args[0] | string | `"--NotebookApp.base_url=/lw-workspace/proxy/"` |  |
| hatchery.hatchery.containers[0].args[1] | string | `"--NotebookApp.default_url=/lab"` |  |
| hatchery.hatchery.containers[0].args[2] | string | `"--NotebookApp.password=''"` |  |
| hatchery.hatchery.containers[0].args[3] | string | `"--NotebookApp.token=''"` |  |
| hatchery.hatchery.containers[0].args[4] | string | `"--NotebookApp.shutdown_no_activity_timeout=5400"` |  |
| hatchery.hatchery.containers[0].args[5] | string | `"--NotebookApp.quit_button=False"` |  |
| hatchery.hatchery.containers[0].command[0] | string | `"start-notebook.sh"` |  |
| hatchery.hatchery.containers[0].cpu-limit | string | `"1.0"` | cpu limit of workspace container |
| hatchery.hatchery.containers[0].env | object | `{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"}` | environment variables for workspace container |
| hatchery.hatchery.containers[0].fs-gid | int | `100` |  |
| hatchery.hatchery.containers[0].gen3-volume-location | string | `"/home/jovyan/.gen3"` |  |
| hatchery.hatchery.containers[0].image | string | `"quay.io/cdis/heal-notebooks:combined_tutorials__latest"` | docker image for workspace |
| hatchery.hatchery.containers[0].lifecycle-post-start[0] | string | `"/bin/sh"` |  |
| hatchery.hatchery.containers[0].lifecycle-post-start[1] | string | `"-c"` |  |
| hatchery.hatchery.containers[0].lifecycle-post-start[2] | string | `"export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found; ln -s /data /home/$IAM/pd/; true"` |  |
| hatchery.hatchery.containers[0].memory-limit | string | `"2Gi"` | memory limit of workspace container |
| hatchery.hatchery.containers[0].name | string | `"(Tutorials) Example Analysis Jupyter Lab Notebooks"` | name of workspace |
| hatchery.hatchery.containers[0].path-rewrite | string | `"/lw-workspace/proxy/"` |  |
| hatchery.hatchery.containers[0].ready-probe | string | `"/lw-workspace/proxy/"` |  |
| hatchery.hatchery.containers[0].target-port | int | `8888` | port to proxy traffic to in docker contaniner |
| hatchery.hatchery.containers[0].use-tls | string | `"false"` |  |
| hatchery.hatchery.containers[0].user-uid | int | `1000` |  |
| hatchery.hatchery.containers[0].user-volume-location | string | `"/home/jovyan/pd"` |  |
| hatchery.hatchery.sidecarContainer.args | list | `[]` | Arguments to pass to the sidecare container. |
| hatchery.hatchery.sidecarContainer.command | list | `["/bin/bash","./sidecar.sh"]` | Commands to run for the sidecar container. |
| hatchery.hatchery.sidecarContainer.cpu-limit | string | `"0.1"` | The maximum amount of CPU the sidecar container can use |
| hatchery.hatchery.sidecarContainer.env | map | `{"HOSTNAME":"{{ .Values.global.hostname }}","NAMESPACE":"{{ .Release.Namespace }}"}` | Environment variables to pass to the sidecar container |
| hatchery.hatchery.sidecarContainer.image | string | `"quay.io/cdis/ecs-ws-sidecar:master"` | The sidecar image. |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[0] | string | `"su"` |  |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[1] | string | `"-c"` |  |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[2] | string | `"echo test"` |  |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[3] | string | `"-s"` |  |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[4] | string | `"/bin/sh"` |  |
| hatchery.hatchery.sidecarContainer.lifecycle-pre-stop[5] | string | `"root"` |  |
| hatchery.hatchery.sidecarContainer.memory-limit | string | `"256Mi"` | The maximum amount of memory the sidecar container can use |
| indexd.defaultPrefix | string | `"PREFIX/"` | the default prefix for indexd records |
| indexd.enabled | bool | `true` | Whether to deploy the indexd subchart. |
| manifestservice.enabled | bool | `true` | Whether to deploy the manifest service subchart. |
| metadata.enabled | bool | `true` | Whether to deploy the metadata subchart. |
| peregrine.enabled | bool | `true` | Whether to deploy the peregrine subchart. |
| pidgin.enabled | bool | `true` | Whether to deploy the pidgin subchart. |
| portal.enabled | bool | `true` | Whether to deploy the portal subchart. |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| requestor.enabled | bool | `false` | Whether to deploy the requestor subchart. |
| revproxy.enabled | bool | `true` | Whether to deploy the revproxy subchart. |
| revproxy.ingress.annotations | map | `{}` | Annotations to add to the ingress. |
| revproxy.ingress.enabled | bool | `false` | Whether to create the custom revproxy ingress |
| revproxy.ingress.hosts | list | `[{"host":"chart-example.local"}]` | Where to route the traffic. |
| revproxy.ingress.tls | list | `[]` | To secure an Ingress by specifying a secret that contains a TLS private key and certificate. |
| sheepdog.enabled | bool | `true` | Whether to deploy the sheepdog subchart. |
| ssjdispatcher.enabled | bool | `false` | Whether to deploy the ssjdispatcher subchart. |
| wts.enabled | bool | `true` | Whether to deploy the wts subchart. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
