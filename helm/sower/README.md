# sower

![Version: 0.1.19](https://img.shields.io/badge/Version-0.1.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 sower

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.16 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["sower"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity to use for the deployment. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["sower"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["sower"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["sower"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["sower"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
| automountServiceAccountToken | bool | `true` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| awsRegion | string | `"us-east-1"` | AWS region to be used. |
| awsStsRegionalEndpoints | string | `"regional"` | AWS STS to issue temporary credentials to users and roles that make an AWS STS request. Values regional or global. |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `nil` | Environment variables to pass to the container |
| externalSecrets | map | `{"createK8sPelicanServiceSecret":false,"createK8sSowerJobsSecret":false,"pelicanserviceG3auto":null,"sowerjobsG3auto":null}` | External Secrets settings. |
| externalSecrets.createK8sPelicanServiceSecret | string | `false` | Will create the Helm "pelicanservice-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.createK8sSowerJobsSecret | string | `false` | Will create the Helm "sower-jobs-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.pelicanserviceG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "pelicanservice-g3auto" |
| externalSecrets.sowerjobsG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "sower-jobs-g3auto" |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
| gen3Namespace | string | `"default"` | Namespace to deploy the job. |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any sower secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.netPolicy | map | `{"enabled":false}` | Controls network policy settings |
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
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/sower","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/sower"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| netPolicy | map | `{"egressApps":["pidgin"],"ingressApps":["pidgin"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["pidgin"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["pidgin"]` | List of app labels that require ingress to this service |
| nodeSelector | map | `{}` | Node Selector for the pods |
| partOf | string | `"Core-Service"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| pelican.bucket | string | `"sower-pfb-bucket"` |  |
| podSecurityContext | map | `{"fsGroup":1000,"runAsUser":1000}` | Security context to apply to the pod |
| podSecurityContext.fsGroup | int | `1000` | Group that Kubernetes will change the permissions of all files in volumes to when volumes are mounted by a pod. |
| podSecurityContext.runAsUser | int | `1000` | User that all the processes will run under in the container. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"400Mi"},"requests":{"cpu":"100m","memory":"20Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"400Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"400Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"100m","memory":"20Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"100m"` | The amount of CPU requested |
| resources.requests.memory | string | `"20Mi"` | The amount of memory requested |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Values for sower secrets and keys for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS access key ID. Overrides global key. |
| securityContext | map | `{}` | Security context for the containers in the pod |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":"sower-service-account"}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `"sower-service-account"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| sowerConfig[0].action | string | `"export"` |  |
| sowerConfig[0].container.cpu-limit | string | `"1"` |  |
| sowerConfig[0].container.env[0].name | string | `"DICTIONARY_URL"` |  |
| sowerConfig[0].container.env[0].valueFrom.configMapKeyRef.key | string | `"dictionary_url"` |  |
| sowerConfig[0].container.env[0].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| sowerConfig[0].container.env[1].name | string | `"GEN3_HOSTNAME"` |  |
| sowerConfig[0].container.env[1].valueFrom.configMapKeyRef.key | string | `"hostname"` |  |
| sowerConfig[0].container.env[1].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| sowerConfig[0].container.env[2].name | string | `"ROOT_NODE"` |  |
| sowerConfig[0].container.env[2].value | string | `"subject"` |  |
| sowerConfig[0].container.env[3].name | string | `"DB_HOST"` |  |
| sowerConfig[0].container.env[3].valueFrom.secretKeyRef.key | string | `"host"` |  |
| sowerConfig[0].container.env[3].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[0].container.env[4].name | string | `"DB_DATABASE"` |  |
| sowerConfig[0].container.env[4].valueFrom.secretKeyRef.key | string | `"database"` |  |
| sowerConfig[0].container.env[4].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[0].container.env[5].name | string | `"DB_USER"` |  |
| sowerConfig[0].container.env[5].valueFrom.secretKeyRef.key | string | `"username"` |  |
| sowerConfig[0].container.env[5].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[0].container.env[6].name | string | `"DB_PASS"` |  |
| sowerConfig[0].container.env[6].valueFrom.secretKeyRef.key | string | `"password"` |  |
| sowerConfig[0].container.env[6].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[0].container.env[7].name | string | `"SHEEPDOG"` |  |
| sowerConfig[0].container.env[7].valueFrom.secretKeyRef.key | string | `"sheepdog"` |  |
| sowerConfig[0].container.env[7].valueFrom.secretKeyRef.name | string | `"indexd-service-creds"` |  |
| sowerConfig[0].container.image | string | `"quay.io/cdis/pelican-export:master"` |  |
| sowerConfig[0].container.memory-limit | string | `"12Gi"` |  |
| sowerConfig[0].container.name | string | `"job-task"` |  |
| sowerConfig[0].container.pull_policy | string | `"Always"` |  |
| sowerConfig[0].container.volumeMounts[0].mountPath | string | `"/pelican-creds.json"` |  |
| sowerConfig[0].container.volumeMounts[0].name | string | `"pelican-creds-volume"` |  |
| sowerConfig[0].container.volumeMounts[0].readOnly | bool | `true` |  |
| sowerConfig[0].container.volumeMounts[0].subPath | string | `"config.json"` |  |
| sowerConfig[0].name | string | `"pelican-export"` |  |
| sowerConfig[0].restart_policy | string | `"Never"` |  |
| sowerConfig[0].volumes[0].name | string | `"pelican-creds-volume"` |  |
| sowerConfig[0].volumes[0].secret.secretName | string | `"pelicanservice-g3auto"` |  |
| sowerConfig[1].action | string | `"export-files"` |  |
| sowerConfig[1].container.cpu-limit | string | `"1"` |  |
| sowerConfig[1].container.env[0].name | string | `"DICTIONARY_URL"` |  |
| sowerConfig[1].container.env[0].valueFrom.configMapKeyRef.key | string | `"dictionary_url"` |  |
| sowerConfig[1].container.env[0].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| sowerConfig[1].container.env[1].name | string | `"GEN3_HOSTNAME"` |  |
| sowerConfig[1].container.env[1].valueFrom.configMapKeyRef.key | string | `"hostname"` |  |
| sowerConfig[1].container.env[1].valueFrom.configMapKeyRef.name | string | `"manifest-global"` |  |
| sowerConfig[1].container.env[2].name | string | `"ROOT_NODE"` |  |
| sowerConfig[1].container.env[2].value | string | `"file"` |  |
| sowerConfig[1].container.env[3].name | string | `"EXTRA_NODES"` |  |
| sowerConfig[1].container.env[3].value | string | `""` |  |
| sowerConfig[1].container.env[4].name | string | `"DB_HOST"` |  |
| sowerConfig[1].container.env[4].valueFrom.secretKeyRef.key | string | `"host"` |  |
| sowerConfig[1].container.env[4].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[1].container.env[5].name | string | `"DB_DATABASE"` |  |
| sowerConfig[1].container.env[5].valueFrom.secretKeyRef.key | string | `"database"` |  |
| sowerConfig[1].container.env[5].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[1].container.env[6].name | string | `"DB_USER"` |  |
| sowerConfig[1].container.env[6].valueFrom.secretKeyRef.key | string | `"username"` |  |
| sowerConfig[1].container.env[6].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[1].container.env[7].name | string | `"DB_PASS"` |  |
| sowerConfig[1].container.env[7].valueFrom.secretKeyRef.key | string | `"password"` |  |
| sowerConfig[1].container.env[7].valueFrom.secretKeyRef.name | string | `"sheepdog-dbcreds"` |  |
| sowerConfig[1].container.env[8].name | string | `"SHEEPDOG"` |  |
| sowerConfig[1].container.env[8].valueFrom.secretKeyRef.key | string | `"sheepdog"` |  |
| sowerConfig[1].container.env[8].valueFrom.secretKeyRef.name | string | `"indexd-service-creds"` |  |
| sowerConfig[1].container.image | string | `"quay.io/cdis/pelican-export:master"` |  |
| sowerConfig[1].container.memory-limit | string | `"12Gi"` |  |
| sowerConfig[1].container.name | string | `"job-task"` |  |
| sowerConfig[1].container.pull_policy | string | `"Always"` |  |
| sowerConfig[1].container.volumeMounts[0].mountPath | string | `"/pelican-creds.json"` |  |
| sowerConfig[1].container.volumeMounts[0].name | string | `"pelican-creds-volume"` |  |
| sowerConfig[1].container.volumeMounts[0].readOnly | bool | `true` |  |
| sowerConfig[1].container.volumeMounts[0].subPath | string | `"config.json"` |  |
| sowerConfig[1].name | string | `"pelican-export-files"` |  |
| sowerConfig[1].restart_policy | string | `"Never"` |  |
| sowerConfig[1].volumes[0].name | string | `"pelican-creds-volume"` |  |
| sowerConfig[1].volumes[0].secret.secretName | string | `"pelicanservice-g3auto"` |  |
| sowerjobsG3auto | string | `"{\n  \"index-object-manifest\": {\n    \"job_requires\": {\n      \"arborist_url\": \"http://arborist-service\",\n      \"job_access_req\": []\n    },\n    \"bucket\": \"$bucketName\",\n    \"indexd_user\": \"diirm\",\n    \"indexd_password\": \"$indexdPassword\"\n  },\n  \"download-indexd-manifest\": {\n    \"job_requires\": {\n      \"arborist_url\": \"http://arborist-service\",\n      \"job_access_req\": []\n    },\n    \"bucket\": \"$bucketName\"\n  },\n  \"get-dbgap-metadata\": {\n    \"job_requires\": {\n      \"arborist_url\": \"http://arborist-service\",\n      \"job_access_req\": []\n    },\n    \"bucket\": \"$bucketName\"\n  },\n  \"ingest-metadata-manifest\": {\n    \"job_requires\": {\n      \"arborist_url\": \"http://arborist-service\",\n      \"job_access_req\": []\n    },\n    \"bucket\": \"$bucketName\"\n  }\n}\n"` | Additional configuration for Sower Jobs Passed in as a multiline string. This secret can be mounted in sowerConfig. |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[{"mountPath":"/sower_config.json","name":"sower-config","readOnly":true,"subPath":"sower_config.json"}]` | Volumes to mount to the container. |
| volumes | list | `[{"configMap":{"items":[{"key":"json","path":"sower_config.json"}],"name":"manifest-sower"},"name":"sower-config"}]` | Volumes to attach to the container. |
