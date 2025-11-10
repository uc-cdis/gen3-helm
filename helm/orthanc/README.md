# orthanc

![Version: 0.1.7](https://img.shields.io/badge/Version-0.1.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for gen3 Dicom Server

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.26 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| AuthenticationEnabled | bool | `false` | Whether or not the password protection is enabled. |
| PostgreSQL.EnableIndex | bool | `true` | Whether to enable index. If set to "false", Orthanc will continue to use its default SQLite back-end. |
| PostgreSQL.EnableStorage | bool | `true` | Whether to enable storage. If set to "false", Orthanc will continue to use its default filesystem storage area. |
| PostgreSQL.Enabled | bool | `false` | Whether or not to enable postgres for orthanc or just use s3. |
| PostgreSQL.IndexConnectionsCount | int | `5` | The number of connections from the index plugin to the PostgreSQL database |
| PostgreSQL.Lock | bool | `false` | Whether to lock the database. |
| PostgreSQL.Port | string | `"5432"` | Port for Postgres. |
| RegisteredUsers.public | string | `"hello"` |  |
| RemoteAccessAllowed | bool | `true` |  |
| S3Storage.AccessKey | string | `nil` |  |
| S3Storage.BucketName | string | `nil` |  |
| S3Storage.Region | string | `"us-east-1"` |  |
| S3Storage.SecretKey | string | `nil` |  |
| autoscaling | object | `{}` |  |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| externalSecrets | map | `{"createK8sOrthancS3G3auto":false,"orthancS3G3Auto":null,"pushSecret":false}` | External Secrets settings. |
| externalSecrets.createK8sOrthancS3G3auto | string | `false` | Will create the Helm "orthanc-s3-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.orthancS3G3Auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "orthanc-s3-g3auto" |
| externalSecrets.pushSecret | bool | `false` | Whether to create the database and Secrets Manager secrets via PushSecret. |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `10` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","dbCreate":false,"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.clusterSecretStoreRef | string | `""` | Will use a manually deployed clusterSecretStore if defined. |
| global.externalSecrets.dbCreate | bool | `false` | Will create the databases and store the creds in Kubernetes Secrets even if externalSecrets is deployed. Useful if you want to use ExternalSecrets for other secrets besides db secrets. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.minAvailable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy | map | `{"enabled":false}` | Settings for network policies |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.postgres.dbCreate | bool | `true` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/gen3-orthanc","tag":"orthancteam-master-gen3-24.3.5"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/gen3-orthanc"` | Docker repository. |
| image.tag | string | `"orthancteam-master-gen3-24.3.5"` | Overrides the image tag whose default is the chart appVersion. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| partOf | string | `"Imaging"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| postgres | map | `{"database":null,"dbCreate":null,"dbRestore":false,"host":null,"password":null,"port":"5432","separate":false,"username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `nil` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.separate | string | `false` | Will create a Database for the individual service to help with developing it. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgresql | map | `{"primary":{"persistence":{"enabled":false}}}` | Postgresql subchart settings if deployed separately option is set to "true". Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"targetport":8042}` | Kubernetes service information. |
| service.port | int | `80` | The port number that the service exposes. |
| service.targetport | int | `8042` | The port on the host machine that traffic is directed to. |
| volumeMounts | list | `[{"mountPath":"/etc/orthanc/orthanc_config_overwrites.json","name":"config-volume-g3auto","readOnly":true,"subPath":"orthanc_config_overwrites.json"}]` | Volumes to mount to the pod. |
| volumes | list | `[{"name":"config-volume-g3auto","secret":{"secretName":"orthanc-s3-g3auto"}}]` | Volumes to attach to the pod. |
