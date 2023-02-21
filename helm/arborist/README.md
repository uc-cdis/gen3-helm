# arborist

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 arborist

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{}` | Affinity rules to apply to the pod |
| autoscaling | map | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling settings |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| env | list | `[{"name":"JWKS_ENDPOINT","value":"http://fence-service/.well-known/jwks"}]` | Environment variables to pass to the container |
| env[0] | string | `{"name":"JWKS_ENDPOINT","value":"http://fence-service/.well-known/jwks"}` | The URL of the JSON Web Key Set (JWKS) endpoint for authentication |
| fullnameOverride | string | `""` | Override the full name of the deployment. |
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
| image | map | `{"pullPolicy":"IfNotPresent","repository":"quay.io/cdis/arborist","tag":""}` | Docker image information. |
| image.pullPolicy | string | `"IfNotPresent"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/arborist"` | Docker repository. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | map | `{}` | Node selector to apply to the pod |
| podAnnotations | map | `{}` | Annotations to add to the pod |
| podSecurityContext | map | `nil` | Security context to apply to the pod |
| postgres | map | `{"database":null,"dbCreate":null,"host":null,"password":null,"port":"5432","username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `nil` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":0.1,"memory":"12Mi"}}` | Resource requests and limits |
| resources.limits | map | `{"cpu":1,"memory":"512Mi"}` | Resource limits |
| resources.limits.cpu | string | `1` | CPU limit |
| resources.limits.memory | string | `"512Mi"` | Memory limit |
| resources.requests | map | `{"cpu":0.1,"memory":"12Mi"}` | Resource requests |
| resources.requests.cpu | string | `0.1` | CPU request |
| resources.requests.memory | string | `"12Mi"` | Memory request |
| securityContext | map | `{}` | Security context to apply to the container |
| service | map | `{"port":80,"type":"ClusterIP"}` | Kubernetes service settings |
| service.port | int | `80` | The port number that the service exposes |
| service.type | string | `"ClusterIP"` | The type of the Kubernetes service |
| serviceAccount | map | `{"annotations":{},"create":true,"name":""}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. |
| tolerations | list | `[]` | Tolerations to apply to the pod |
| volumeMounts | list | `[]` | Volume mounts to attach to the container |
| volumes | list | `[]` | Volumes to attach to the pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
