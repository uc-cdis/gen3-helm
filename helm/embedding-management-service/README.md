# embedding-management-service

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| embeddingsConfig | string | `"{\n  \"expr\": 256,\n  \"hist\": 1536,\n  \"summ\": 4096,\n  \"text\": 4096\n}"` |  |
| externalSecrets | map | `{"createK8sServiceCredsSecret":false,"dbcreds":null}` | External Secrets settings. |
| externalSecrets.createK8sServiceCredsSecret | string | `false` | Will create the Helm "indexd-service-creds" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.dbcreds | string | `nil` | Will override the name of the aws secrets manager secret. Default is "Values.global.environment-.Chart.Name-creds" |
| fullnameOverride | string | `""` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any metadata secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.kubeBucket | string | `"kube-gen3"` | S3 bucket name for Kubernetes manifest files. |
| global.logsBucket | string | `"logs-gen3"` | S3 bucket name for log files. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy | map | `{"enabled":false}` | Controls network policy settings |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres.dbCreate | bool | `false` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/cdis/embedding-management-service"` |  |
| image.tag | string | `"feat_service"` |  |
| imagePullSecrets | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/_status"` |  |
| livenessProbe.httpGet.port | int | `8000` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgres | map | `{"database":null,"dbCreate":false,"dbRestore":false,"host":null,"password":null,"port":"5432","separate":false,"username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `false` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.separate | string | `false` | Will create a Database for the individual service to help with developing it. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| readinessProbe.httpGet.path | string | `"/_status"` |  |
| readinessProbe.httpGet.port | int | `8000` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service | map | `{"port":[{"name":"http","port":80,"protocol":"TCP","targetPort":8000}],"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `[{"name":"http","port":80,"protocol":"TCP","targetPort":8000}]` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| spec.template.spec.volumes[0].configMap.name | string | `"ems-config"` |  |
| spec.template.spec.volumes[0].name | string | `"config"` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/config.json"` |  |
| volumeMounts[0].name | string | `"config-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"config.json"` |  |
| volumes[0].configMap.configMapName | string | `"ems-config"` |  |
| volumes[0].configMap.name | string | `"ems-config"` |  |
| volumes[0].configMap.optional | bool | `false` |  |
| volumes[0].name | string | `"config"` |  |
