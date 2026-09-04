# gen3-embeddings

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: main](https://img.shields.io/badge/AppVersion-main-informational?style=flat-square)

A Helm chart for Kubernetes

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Requirements

| Repository | Name |
|------------|------|
| file://../common | common |
| https://charts.bitnami.com/bitnami | postgresql |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| automountServiceAccountToken | bool | `false` |  |
| autoscaling | object | `{}` |  |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| debug | bool | `false` |  |
| env | list | `[{"name":"GEN3_DEBUG","value":"false"},{"name":"ARBORIST_URL","valueFrom":{"configMapKeyRef":{"key":"arborist_url","name":"manifest-global","optional":true}}},{"name":"PGPOOL_MIN_SIZE","value":"1"},{"name":"PGPOOL_MAX_SIZE","value":"5"}]` | Environment variables to pass to the container |
| externalSecrets | map | `{"createK8sGen3EmbeddingsSecret":false,"dbcreds":null,"gen3EmbeddingsEnvSecret":null,"gen3EmbeddingsG3auto":null,"pushSecret":false}` | External Secrets settings. |
| externalSecrets.createK8sGen3EmbeddingsSecret | string | `false` | Will create the Helm "gen3Embeddings-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.dbcreds | string | `nil` | Will override the name of the aws secrets manager secret. Default is "Values.global.environment-.Chart.Name-creds" |
| externalSecrets.gen3EmbeddingsEnvSecret | string | `nil` | Will override the name of both the Secret holding secret environment variables and the aws secrets manager secret it is populated from. Default is "gen3-embeddings-env-secret". |
| externalSecrets.gen3EmbeddingsG3auto | string | `nil` | Will override the name of the aws secrets manager secret. Default is "gen3embeddings-g3auto" |
| externalSecrets.pushSecret | bool | `false` | Whether to create the database and Secrets Manager secrets via PushSecret. |
| extraEnv | map | `{}` | Public, non-secret environment variables, by their real ALL_UPPER name. Prefer this over `env` for per-environment settings: Helm replaces lists wholesale, so overriding `env` drops the defaults above, while map keys merge. Rendered after `env`, so a name set in both resolves here. Values must be scalars; use `env` for anything needing `valueFrom`. Secret values belong in `secretEnv` or Secrets Manager, not here - this file is public. |
| extraVolumes | list | `[]` | Additional volumes on the output Deployment definition. |
| fullnameOverride | string | `""` |  |
| global.autoscaling.averageCPUValue | string | `"500m"` |  |
| global.autoscaling.averageMemoryValue | string | `"500Mi"` |  |
| global.autoscaling.enabled | bool | `false` |  |
| global.autoscaling.maxReplicas | int | `10` |  |
| global.autoscaling.minReplicas | int | `1` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.externalSecrets | map | `{"deploy":false,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any metadata secrets you have deployed. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.minAvailable | int | `1` | Minimum pods the PodDisruptionBudget keeps available. Only consulted when global.pdb is set and replicaCount is above 1; the PDB renders an empty minAvailable and is rejected without it. |
| global.postgres.dbCreate | bool | `true` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/gen3_embeddings"` |  |
| image.tag | string | `"main"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe | map | `{"httpGet":{"path":"/_status","port":"http"},"initialDelaySeconds":30,"periodSeconds":60,"timeoutSeconds":30}` | Liveness probe. `port: http` follows service.targetPort, so the probe cannot drift from the port the container actually listens on. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| nameOverride | string | `""` |  |
| partOf | string | `"Embeddings"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| postgres | map | `{"database":null,"dbCreate":null,"dbRestore":false,"host":null,"migrations":{"dir":"/services/gen3_embeddings/db/migrations","enabled":true,"sslmode":"disable"},"password":null,"port":"5432","separate":false,"username":null}` | Postgres database configuration. If db does not exist in postgres cluster and dbCreate is set ot true then these databases will be created for you |
| postgres.database | string | `nil` | Database name for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgres.dbCreate | bool | `nil` | Whether the database should be created. Default to global.postgres.dbCreate |
| postgres.host | string | `nil` | Hostname for postgres server. This is a service override, defaults to global.postgres.host |
| postgres.migrations | map | `{"dir":"/services/gen3_embeddings/db/migrations","enabled":true,"sslmode":"disable"}` | dbmate schema migrations. dbmate takes no lock while migrating, so migrations run in a single Job with parallelism 1 and the deployment waits for them rather than each replica racing to apply the same migration. |
| postgres.migrations.dir | string | `"/services/gen3_embeddings/db/migrations"` | Directory inside the image holding dbmate migrations. |
| postgres.migrations.enabled | bool | `true` | Run migrations as a Job, and make the deployment wait for them before serving. |
| postgres.migrations.sslmode | string | `"disable"` | sslmode for the migration connection. |
| postgres.password | string | `nil` | Password for Postgres. Will be autogenerated if left empty. |
| postgres.port | string | `"5432"` | Port for Postgres. |
| postgres.separate | string | `false` | Will create a Database for the individual service to help with developing it. |
| postgres.username | string | `nil` | Username for postgres. This is a service override, defaults to <serviceName>-<releaseName> |
| postgresql | map | `{"primary":{"persistence":{"enabled":false}}}` | Postgresql subchart settings if deployed separately option is set to "true". Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| readinessProbe | map | `{"httpGet":{"path":"/_status","port":"http"}}` | Readiness probe. Removes the pod from the Service until /_status answers. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `2` | The image runs a single Uvicorn process, so concurrency comes from replicas rather than from workers inside the container. Replicas do not migrate: postgres.migrations runs that once in a Job and each replica waits for it, so this can be raised freely. |
| resources | map | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Compute resources. Sized for the single Uvicorn process the image runs; add replicas rather than raising these to serve more concurrent traffic. The same values apply to the migration initContainer. |
| secretEnv | map | `{}` | Secret environment variables, rendered into the <name>-env-secret Secret and projected with envFrom. Intended for local development only: when global.externalSecrets.deploy is set, this Secret is populated from Secrets Manager instead and anything here is ignored. Never commit real credentials to a public values file. |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information to access the db restore job S3 bucket. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service.port | int | `80` |  |
| service.targetPort | int | `8000` | Port the service listens on inside the container. Also the container port the probes address by name, so changing it here moves the Service, the container port and both probes together. |
| service.type | string | `"ClusterIP"` |  |
| volumeMounts[0].mountPath | string | `"/services/gen3_embeddings/.env"` |  |
| volumeMounts[0].name | string | `"gen3-embeddings-g3auto-volume"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"gen3-embeddings.env"` |  |
