# gen3

![Version: 0.1.65](https://img.shields.io/badge/Version-0.1.65-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

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
| file://../ambassador | ambassador | 0.1.17 |
| file://../arborist | arborist | 0.1.15 |
| file://../argo-wrapper | argo-wrapper | 0.1.11 |
| file://../audit | audit | 0.1.17 |
| file://../aws-es-proxy | aws-es-proxy | 0.1.14 |
| file://../cohort-middleware | cohort-middleware | 0.1.1 |
| file://../common | common | 0.1.16 |
| file://../etl | etl | 0.1.11 |
| file://../fence | fence | 0.1.32 |
| file://../frontend-framework | frontend-framework | 0.1.6 |
| file://../gen3-network-policies | gen3-network-policies | 0.1.2 |
| file://../guppy | guppy | 0.1.18 |
| file://../hatchery | hatchery | 0.1.13 |
| file://../indexd | indexd | 0.1.19 |
| file://../manifestservice | manifestservice | 0.1.19 |
| file://../metadata | metadata | 0.1.18 |
| file://../neuvector | neuvector | 0.1.2 |
| file://../peregrine | peregrine | 0.1.19 |
| file://../portal | portal | 0.1.27 |
| file://../requestor | requestor | 0.1.17 |
| file://../revproxy | revproxy | 0.1.23 |
| file://../sheepdog | sheepdog | 0.1.21 |
| file://../sower | sower | 0.1.19 |
| file://../ssjdispatcher | ssjdispatcher | 0.1.19 |
| file://../wts | wts | 0.1.19 |
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
| cohort-middleware | map | `{"enabled":false}` | Configurations for cohort-middleware chart. |
| cohort-middleware.enabled | bool | `false` | Whether to deploy the cohort-middleware subchart. |
| elasticsearch.clusterHealthCheckParams | string | `"wait_for_status=yellow&timeout=1s"` |  |
| elasticsearch.clusterName | string | `"gen3-elasticsearch"` |  |
| elasticsearch.esConfig."elasticsearch.yml" | string | `"# Here we can add elasticsearch config\n"` |  |
| elasticsearch.maxUnavailable | int | `0` |  |
| elasticsearch.replicas | int | `1` |  |
| elasticsearch.singleNode | bool | `true` |  |
| etl.enabled | bool | `true` | Whether to deploy the etl subchart. |
| fence.enabled | bool | `true` | Whether to deploy the fence subchart. |
| fence.usersync | map | `{"addDbgap":false,"onlyDbgap":false,"schedule":"*/30 * * * *","slack_send_dbgap":false,"slack_webhook":"None","syncFromDbgap":false,"userYamlS3Path":"s3://cdis-gen3-users/helm-test/user.yaml","usersync":false}` | Configuration options for usersync cronjob. |
| fence.usersync.addDbgap | bool | `false` | Force attempting a dbgap sync if "true", falls back on user.yaml |
| fence.usersync.onlyDbgap | bool | `false` | Forces ONLY a dbgap sync if "true", IGNORING user.yaml |
| fence.usersync.schedule | string | `"*/30 * * * *"` | The cron schedule expression to use in the usersync cronjob. Runs every 30 minutes by default. |
| fence.usersync.slack_send_dbgap | bool | `false` | Will echo what files we are seeing on dbgap ftp to Slack. |
| fence.usersync.slack_webhook | string | `"None"` | Slack webhook endpoint used with certain jobs. |
| fence.usersync.syncFromDbgap | bool | `false` | Whether to sync data from dbGaP. |
| fence.usersync.userYamlS3Path | string | `"s3://cdis-gen3-users/helm-test/user.yaml"` | Path to the user.yaml file in S3. |
| fence.usersync.usersync | bool | `false` | Whether to run Fence usersync or not. |
| frontend-framework | map | `{"enabled":false,"image":{"repository":"quay.io/cdis/frontend-framework","tag":"develop"}}` | Configurations for frontend-framework chart. |
| frontend-framework.enabled | bool | `false` | Whether to deploy the frontend-framework subchart. |
| frontend-framework.image | map | `{"repository":"quay.io/cdis/frontend-framework","tag":"develop"}` | Docker image information. |
| frontend-framework.image.repository | string | `"quay.io/cdis/frontend-framework"` | The Docker image repository for the frontend-framework. |
| frontend-framework.image.tag | string | `"develop"` | Overrides the image tag whose default is the chart appVersion. |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"region":"us-east-1","secretStoreServiceAccount":{"enabled":false,"name":"secret-store-sa","roleArn":null},"useLocalSecret":{"enabled":false,"localSecretName":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.aws.secretStoreServiceAccount | map | `{"enabled":false,"name":"secret-store-sa","roleArn":null}` | Service account and AWS role for authentication to AWS Secrets Manager |
| global.aws.secretStoreServiceAccount.enabled | bool | `false` | Set true if deploying to AWS and want to use service account and IAM role instead of aws keys. Must provide role-arn. |
| global.aws.secretStoreServiceAccount.name | string | `"secret-store-sa"` | Name of the service account to create |
| global.aws.secretStoreServiceAccount.roleArn | string | `nil` | AWS Role ARN for Secret Store to use |
| global.aws.useLocalSecret | map | `{"enabled":false,"localSecretName":null}` | Local secret setting if using a pre-exising secret. |
| global.aws.useLocalSecret.enabled | bool | `false` | Set to true if you would like to use a secret that is already running on your cluster. |
| global.aws.useLocalSecret.localSecretName | string | `nil` | Name of the local secret. |
| global.dev | bool | `true` | Deploys postgres/elasticsearch for dev |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces in same cluster. |
| global.externalSecrets | map | `{"dbCreate":false,"deploy":false}` | External Secrets settings. |
| global.externalSecrets.dbCreate | bool | `false` | Will create the databases and store the creds in Kubernetes Secrets even if externalSecrets is deployed. Useful if you want to use ExternalSecrets for other secrets besides db secrets. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| global.frontendRoot | string | `"portal"` | Which app will be served on /. Needs be set to portal for portal, or "gen3ff" for frontendframework. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.manifestGlobalExtraValues | map | `{}` | If you would like to add any extra values to the manifest-global configmap. |
| global.netPolicy | bool | `{"dbSubnet":"","enabled":false}` | Global flags to control and manage network policies for a Gen3 installation NOTE: Network policies are currently a beta feature. Use with caution! |
| global.netPolicy.dbSubnet | array | `""` | A CIDR range representing a database subnet, that services with a database need access to |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
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
| guppy | map | `{"enabled":false}` | Configurations for guppy chart. |
| guppy.enabled | bool | `false` | Whether to deploy the guppy subchart. |
| hatchery.enabled | bool | `true` | Whether to deploy the hatchery subchart. |
| hatchery.hatchery.containers[0] | int | `{"args":["--NotebookApp.base_url=/lw-workspace/proxy/","--NotebookApp.default_url=/lab","--NotebookApp.password=''","--NotebookApp.token=''","--NotebookApp.shutdown_no_activity_timeout=5400","--NotebookApp.quit_button=False"],"command":["start-notebook.sh"],"cpu-limit":"1.0","env":{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"},"fs-gid":100,"gen3-volume-location":"/home/jovyan/.gen3","image":"quay.io/cdis/heal-notebooks:combined_tutorials__latest","lifecycle-post-start":["/bin/sh","-c","export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found; ln -s /data /home/$IAM/pd/; true"],"memory-limit":"2Gi","name":"(Tutorials) Example Analysis Jupyter Lab Notebooks","path-rewrite":"/lw-workspace/proxy/","ready-probe":"/lw-workspace/proxy/","target-port":8888,"use-tls":"false","user-uid":1000,"user-volume-location":"/home/jovyan/pd"}` | port to proxy traffic to in docker contaniner |
| hatchery.hatchery.containers[0].cpu-limit | string | `"1.0"` | cpu limit of workspace container |
| hatchery.hatchery.containers[0].env | object | `{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"}` | environment variables for workspace container |
| hatchery.hatchery.containers[0].image | string | `"quay.io/cdis/heal-notebooks:combined_tutorials__latest"` | docker image for workspace |
| hatchery.hatchery.containers[0].memory-limit | string | `"2Gi"` | memory limit of workspace container |
| hatchery.hatchery.containers[0].name | string | `"(Tutorials) Example Analysis Jupyter Lab Notebooks"` | name of workspace |
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
| neuvector.DB_HOST | string | `"development-gen3-postgresql"` |  |
| neuvector.ES_HOST | string | `"gen3-elasticsearch-master"` |  |
| neuvector.enabled | bool | `false` |  |
| neuvector.ingress.class | string | `"nginx"` |  |
| neuvector.ingress.controller | string | `"nginx-ingress-controller"` |  |
| neuvector.ingress.namespace | string | `"nginx"` |  |
| neuvector.policies.include | bool | `false` |  |
| neuvector.policies.policyMode | string | `"Monitor"` |  |
| peregrine.enabled | bool | `true` | Whether to deploy the peregrine subchart. |
| pidgin.enabled | bool | `false` | Whether to deploy the pidgin subchart. |
| portal.enabled | bool | `true` | Whether to deploy the portal subchart. |
| postgresql | map | `{"primary":{"persistence":{"enabled":false}}}` | To configure postgresql subchart Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| requestor.enabled | bool | `false` | Whether to deploy the requestor subchart. |
| revproxy.enabled | bool | `true` | Whether to deploy the revproxy subchart. |
| revproxy.ingress.annotations | map | `{}` | Annotations to add to the ingress. |
| revproxy.ingress.enabled | bool | `false` | Whether to create the custom revproxy ingress |
| revproxy.ingress.hosts | list | `[{"host":"chart-example.local"}]` | Where to route the traffic. |
| revproxy.ingress.tls | list | `[]` | To secure an Ingress by specifying a secret that contains a TLS private key and certificate. |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets and DB Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| sheepdog.enabled | bool | `true` | Whether to deploy the sheepdog subchart. |
| sower.enabled | bool | `false` | Whether to deploy the sower subchart. |
| ssjdispatcher.enabled | bool | `false` | Whether to deploy the ssjdispatcher subchart. |
| tests | map | `{"SERVICE_TO_TEST":null,"TEST_LABEL":null,"image":{"tag":null},"resources":{"limits":{"cpu":"1","memory":"10G"},"requests":{"cpu":"1","memory":"6G"}}}` | Environment variables that control which tests are run. |
| tests.SERVICE_TO_TEST | str | `nil` | Name of the service we are testing. Default is empty as GH workflow automatically sets this. |
| tests.TEST_LABEL | str | `nil` | Name of the test that will run. Default is empty as GH workflow automatically sets this. |
| wts.enabled | bool | `true` | Whether to deploy the wts subchart. |
