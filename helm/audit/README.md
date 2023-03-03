# audit

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.3 |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"audit"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| api.QUERY_PAGE_SIZE | int | `1000` |  |
| api.QUERY_TIMEBOX_MAX_DAYS | string | `nil` |  |
| api.QUERY_USERNAMES | bool | `true` |  |
| autoscaling | map | `{"enabled":false,"maxReplicas":4,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled or not |
| autoscaling.maxReplicas | int | `4` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| env[0].name | string | `"DEBUG"` |  |
| env[0].value | string | `"false"` |  |
| env[1].name | string | `"ARBORIST_URL"` |  |
| env[1].valueFrom.configMapKeyRef.key | string | `"arborist_url"` |  |
| env[1].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| env[1].valueFrom.configMapKeyRef.optional | bool | `true` |  |
| fullnameOverride | string | `""` | Override the full name of the chart, which is used as the name of resources created by the chart |
| global | map | `{"ddEnabled":false,"dev":true,"dictionaryUrl":"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json","dispatcherJobNum":10,"environment":"default","hostname":"localhost","kubeBucket":"kube-gen3","logsBucket":"logs-gen3","netPolicy":true,"portalApp":"gitops","postgres":{"dbCreate":true,"master":{"host":null,"password":null,"port":"5432","username":"postgres"}},"publicDataSets":true,"revproxyArn":"arn:aws:acm:us-east-1:123456:certificate","syncFromDbgap":false,"tierAccessLevel":"libre","userYamlS3Path":"s3://cdis-gen3-users/test/user.yaml"}` | Global configuration options. |
| global.ddEnabled | bool | `false` | Whether Datadog is enabled. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
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
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` | Path to the user.yaml file in S3. |
| image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.repository | string | `"quay.io/cdis/audit-service"` | The Docker image repository for the audit service |
| image.tag | string | `"master"` | The tag to use for the image. |
| imagePullSecrets | list | `[]` |  |
| initEnv | object | `{}` |  |
| initVolumeMounts | list | `[]` |  |
| labels."tags.datadoghq.com/service" | string | `"audit"` |  |
| labels.app | string | `"audit"` |  |
| labels.authprovider | string | `"yes"` |  |
| labels.netnolimit | string | `"yes"` |  |
| labels.public | string | `"yes"` |  |
| labels.release | string | `"production"` |  |
| labels.userhelper | string | `"yes"` |  |
| nameOverride | string | `""` | Override the name of the chart. This can be used to provide a unique name for a chart |
| nodeSelector | map | `{}` | Node Selector for the pods |
| podAnnotations | map | `{}` | Annotations to add to the pod |
| podSecurityContext | map | `{}` | Security context for the pod |
| postgres | map | `{"database":null,"dbCreate":null,"host":null,"password":null,"port":"5432","separate":true,"username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `nil` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.separate | string | `true` | Will create a Database for the individual service to help with developing it. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgresql.primary.persistence.enabled | bool | `false` |  |
| replicaCount | int | `1` | Number of desired replicas |
| resources | map | `{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":0.1,"memory":"12Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"cpu":1,"memory":"512Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.cpu | string | `1` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":0.1,"memory":"12Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `0.1` | The amount of CPU requested |
| resources.requests.memory | string | `"12Mi"` | The amount of memory requested |
| securityContext | map | `{}` | Security context for the containers in the pod |
| server.AWS_CREDENTIALS | object | `{}` |  |
| server.debug | bool | `false` |  |
| server.pull_from_queue | bool | `false` |  |
| server.sqs.region | string | `"us-east-1"` |  |
| server.sqs.url | string | `"http://sqs.com"` |  |
| service | map | `{"port":80,"type":"ClusterIP"}` | Configuration for the service |
| service.port | int | `80` | Port on which the service is exposed |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `nil` | The Amazon Resource Name (ARN) of the role to associate with the service account |
| serviceAccount.create | bool | `true` | Whether to create a service account |
| serviceAccount.name | string | `"audit-service-sa"` | The name of the service account |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
