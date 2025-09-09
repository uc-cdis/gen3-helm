# hatchery

![Version: 0.1.40](https://img.shields.io/badge/Version-0.1.40-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 Hatchery

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.23 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{}` | Affinity to use for the deployment. |
| autoscaling | object | `{}` |  |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `[{"name":"HTTP_PORT","value":"8000"},{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}}]` | Environment variables to pass to the container |
| externalSecrets | map | `{"createK8sStataSecret":false,"stataG3auto":null}` | External Secrets settings. |
| externalSecrets.createK8sStataSecret | string | `false` | Will create the Helm "stata-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.stataG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "stata-g3auto" |
| fence.image | string | `"quay.io/cdis/fence:master"` |  |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `100` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| global.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.crossplane | map | `{"accountId":123456789012,"enabled":false,"oidcProviderUrl":"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890","providerConfigName":"provider-aws","s3":{"kmsKeyId":null,"versioningEnabled":false}}` | Kubernetes configuration |
| global.crossplane.accountId | string | `123456789012` | The account ID of the AWS account. |
| global.crossplane.enabled | bool | `false` | Set to true if deploying to AWS and want to use crossplane for AWS resources. |
| global.crossplane.oidcProviderUrl | string | `"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890"` | OIDC provider URL. This is used for authentication of roles/service accounts. |
| global.crossplane.providerConfigName | string | `"provider-aws"` | The name of the crossplane provider config. |
| global.crossplane.s3.kmsKeyId | string | `nil` | The kms key id for the s3 bucket. |
| global.crossplane.s3.versioningEnabled | bool | `false` | Whether to use s3 bucket versioning. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.externalSecrets | map | `{"deploy":false,"fenceConfig":null,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any audit secrets you have deployed. |
| global.externalSecrets.fenceConfig | string | `nil` | Will override the name of the aws secrets manager secret. Default is "fence-config". Required for sidecar in workspace launch test. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
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
| global.vpcId | string | `nil` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| hatchery.containers | list | `[{"args":["--NotebookApp.base_url=/lw-workspace/proxy/","--NotebookApp.default_url=/lab","--NotebookApp.password=''","--NotebookApp.token=''","--NotebookApp.shutdown_no_activity_timeout=5400","--NotebookApp.quit_button=False"],"command":["start-notebook.sh"],"cpu-limit":"1.0","env":{"FRAME_ANCESTORS":"https://{{ .Values.global.hostname }}"},"fs-gid":100,"gen3-volume-location":"/home/jovyan/.gen3","image":"quay.io/cdis/heal-notebooks:combined_tutorials__latest","lifecycle-post-start":["/bin/sh","-c","export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found; ln -s /data /home/$IAM/pd/; true"],"memory-limit":"2Gi","name":"(Tutorials) Example Analysis Jupyter Lab Notebooks","path-rewrite":"/lw-workspace/proxy/","ready-probe":"/lw-workspace/proxy/","target-port":8888,"use-tls":"false","user-uid":1000,"user-volume-location":"/home/jovyan/pd"}]` | Notebook configuration. |
| hatchery.json | string | `""` |  |
| hatchery.reaper.enabled | bool | `true` |  |
| hatchery.reaper.idleTimeoutSeconds | int | `3600` |  |
| hatchery.reaper.schedule | string | `"*/15 * * * *"` |  |
| hatchery.reaper.suspendCronjob | bool | `false` |  |
| hatchery.sidecarContainer.args | list | `[]` | Arguments to pass to the sidecare container. |
| hatchery.sidecarContainer.command | list | `["/bin/bash","./sidecar.sh"]` | Commands to run for the sidecar container. |
| hatchery.sidecarContainer.cpu-limit | string | `"0.1"` | The maximum amount of CPU the sidecar container can use |
| hatchery.sidecarContainer.env | map | `{"HOSTNAME":"{{ .Values.global.hostname }}","NAMESPACE":"{{ .Release.Namespace }}"}` | Environment variables to pass to the sidecar container |
| hatchery.sidecarContainer.image | string | `"quay.io/cdis/ecs-ws-sidecar:master"` | The sidecar image. |
| hatchery.sidecarContainer.lifecycle-pre-stop | list | `["su","-c","echo test","-s","/bin/sh","root"]` | Commands that are run before the container is stopped. |
| hatchery.sidecarContainer.memory-limit | string | `"256Mi"` | The maximum amount of memory the sidecar container can use |
| hatchery.skipNodeSelector | bool | `false` | Whether to skip node selector for . Defaults to `global.dev`. |
| hatchery.useInternalServicesUrl | bool | `false` | Whether to use internal services url. Defaults to `global.dev`. |
| image | map | `{"pullPolicy":"IfNotPresent","repository":"quay.io/cdis/hatchery","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"IfNotPresent"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/hatchery"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | map | `{}` | Node selector labels. |
| partOf | string | `"Workspace-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"512Mi"},"requests":{"memory":"12Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"512Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"memory":"12Mi"}` | The amount of resources that the container requests |
| resources.requests.memory | string | `"12Mi"` | The amount of memory requested |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":"hatchery-sa"}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `"hatchery-sa"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations to use for the deployment. |
| volumeMounts | list | `[{"mountPath":"/hatchery.json","name":"hatchery-config","readOnly":true,"subPath":"json"}]` | Volumes to mount to the container. |
| volumes | list | `[{"configMap":{"name":"manifest-hatchery"},"name":"hatchery-config"}]` | Volumes to attach to the container. |
| workspaceLaunchTest | map | `{"enabled":true,"hostname":"https://example.com","operatorName":"username","schedule":"*/20 * * * *","workspaceImages":"(Generic) Jupyter Lab Notebook with R Kernel"}` | Configuration for workspace launch test crobjob |
| workspaceLaunchTest.enabled | bool | `true` | Whether the workspace launch test cron job is enabled. |
| workspaceLaunchTest.hostname | string | `"https://example.com"` | Hostname for the workspace launch test operator. |
| workspaceLaunchTest.operatorName | string | `"username"` | The name of the workspace launch test operator. |
| workspaceLaunchTest.schedule | string | `"*/20 * * * *"` | The schedule for the workspace launch test cron job. |
| workspaceLaunchTest.workspaceImages | string | `"(Generic) Jupyter Lab Notebook with R Kernel"` | Images to test in the workspace launch test cron job. Separate multiple images with '+'. Example: "(Generic) Jupyter Lab Notebook with R Kernel+(Tutorials) Example Analysis Jupyter Lab Notebooks" |
