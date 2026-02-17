# funnel

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.30 |
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.91 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| externalSecrets | map | `{"createFunnelOidcClientSecret":true,"dbcreds":"","funnelOidcClient":null}` | External Secrets settings. |
| externalSecrets.createFunnelOidcClientSecret | bool | `true` | Whether to create the Funnel OIDC client secret using the oidc job. |
| externalSecrets.dbcreds | string | `""` | Name of the secret that will be created in secrets manager |
| externalSecrets.funnelOidcClient | string | `nil` | Will override the name of the aws secrets manager secret. Default is "funnel-oidc-client". |
| funnel.Database | string | `"postgres"` |  |
| funnel.EventWriters[0] | string | `"postgres"` |  |
| funnel.EventWriters[1] | string | `"log"` |  |
| funnel.Logger.Level | string | `"info"` |  |
| funnel.Plugins.Params.OidcClientId | string | `"FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER"` |  |
| funnel.Plugins.Params.OidcClientSecret | string | `"FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER"` |  |
| funnel.Plugins.Params.S3Url | string | `"FUNNEL_PLUGIN_S3URL_PLACEHOLDER"` |  |
| funnel.Plugins.Path | string | `"plugin-binaries/auth-plugin"` |  |
| funnel.Postgres.Database | string | `"FUNNEL_POSTGRES_DATABASE_PLACEHOLDER"` |  |
| funnel.Postgres.Host | string | `"FUNNEL_POSTGRES_HOST_PLACEHOLDER"` |  |
| funnel.Postgres.Password | string | `"FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER"` |  |
| funnel.Postgres.User | string | `"FUNNEL_POSTGRES_USER_PLACEHOLDER"` |  |
| funnel.Worker.LeaveWorkDir | bool | `true` |  |
| funnel.image | map | `{"initContainers":[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","# Create a funnel-patched.conf since /etc/config/funnel.conf is readonly\nCONFIG=/tmp/funnel-patched.conf\ncp /etc/config/funnel.conf $CONFIG\n\nnamespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)\nJOBS_NAMESPACE=workflow-pods-$namespace\nS3_URL=gen3-workflow-service.$namespace.svc.cluster.local\nDB_HOST=$DB_HOST:5432\n\n# `Kubernetes.JobsNamespace` has to be configured manually because of templating\n# limitations. This ensures it is configured to the value that is hardcoded elsewhere.\nconfigured=$(yq -r '.Kubernetes.JobsNamespace' \"$CONFIG\")\nif [[ \"$configured\" != \"$JOBS_NAMESPACE\" ]]; then\n  echo \"ERROR: funnel.Kubernetes.JobsNamespace is set to '$configured' instead of '$JOBS_NAMESPACE'. Please fix the configuration\" >&2\n  exit 1\nfi\n\necho \"======= Funnel configuration =======\"\necho \"  Kubernetes.JobsNamespace   : $JOBS_NAMESPACE\"\necho \"  Plugins.Params.OidcClientId: $FUNNEL_OIDC_CLIENT_ID\"\necho \"  Plugins.Params.S3Url       : $S3_URL\"\necho \"  Postgres.Host              : $DB_HOST\"\necho \"  Postgres.Database          : $DB_DATABASE\"\necho \"  Postgres.User              : $DB_USER\"\necho \"====================================\"\n\n# Replace placeholders with actual values (in-place)\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_ID}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_SECRET}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_S3URL_PLACEHOLDER|${S3_URL}|g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_HOST_PLACEHOLDER/${DB_HOST}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_DATABASE_PLACEHOLDER/${DB_DATABASE}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_USER_PLACEHOLDER/${DB_USER}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/g\" $CONFIG\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"key":"host","name":"funnel-dbcreds","optional":false}}},{"name":"DB_USER","valueFrom":{"secretKeyRef":{"key":"username","name":"funnel-dbcreds","optional":false}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"funnel-dbcreds","optional":false}}},{"name":"DB_DATABASE","valueFrom":{"secretKeyRef":{"key":"database","name":"funnel-dbcreds","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"config-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}],"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel"}` | Configuration for the Funnel container image. |
| funnel.image.initContainers | map | `[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","# Create a funnel-patched.conf since /etc/config/funnel.conf is readonly\nCONFIG=/tmp/funnel-patched.conf\ncp /etc/config/funnel.conf $CONFIG\n\nnamespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)\nJOBS_NAMESPACE=workflow-pods-$namespace\nS3_URL=gen3-workflow-service.$namespace.svc.cluster.local\nDB_HOST=$DB_HOST:5432\n\n# `Kubernetes.JobsNamespace` has to be configured manually because of templating\n# limitations. This ensures it is configured to the value that is hardcoded elsewhere.\nconfigured=$(yq -r '.Kubernetes.JobsNamespace' \"$CONFIG\")\nif [[ \"$configured\" != \"$JOBS_NAMESPACE\" ]]; then\n  echo \"ERROR: funnel.Kubernetes.JobsNamespace is set to '$configured' instead of '$JOBS_NAMESPACE'. Please fix the configuration\" >&2\n  exit 1\nfi\n\necho \"======= Funnel configuration =======\"\necho \"  Kubernetes.JobsNamespace   : $JOBS_NAMESPACE\"\necho \"  Plugins.Params.OidcClientId: $FUNNEL_OIDC_CLIENT_ID\"\necho \"  Plugins.Params.S3Url       : $S3_URL\"\necho \"  Postgres.Host              : $DB_HOST\"\necho \"  Postgres.Database          : $DB_DATABASE\"\necho \"  Postgres.User              : $DB_USER\"\necho \"====================================\"\n\n# Replace placeholders with actual values (in-place)\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_ID}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_SECRET}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_S3URL_PLACEHOLDER|${S3_URL}|g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_HOST_PLACEHOLDER/${DB_HOST}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_DATABASE_PLACEHOLDER/${DB_DATABASE}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_USER_PLACEHOLDER/${DB_USER}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/g\" $CONFIG\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"key":"host","name":"funnel-dbcreds","optional":false}}},{"name":"DB_USER","valueFrom":{"secretKeyRef":{"key":"username","name":"funnel-dbcreds","optional":false}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"funnel-dbcreds","optional":false}}},{"name":"DB_DATABASE","valueFrom":{"secretKeyRef":{"key":"database","name":"funnel-dbcreds","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"config-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}]` | Configuration for the Funnel init container. |
| funnel.image.initContainers[0].command | list | `["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| funnel.image.initContainers[0].image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| funnel.image.initContainers[0].pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.initContainers[0].tag | string | `"main-gen3"` | The Docker image tag for the Funnel init/plugin container. |
| funnel.image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.repository | string | `"quay.io/ohsu-comp-bio/funnel"` | The Docker image repository for the Funnel service. |
| funnel.mongodb.enabled | bool | `false` |  |
| funnel.mongodb.readinessProbe.enabled | bool | `true` |  |
| funnel.mongodb.readinessProbe.failureThreshold | int | `10` |  |
| funnel.mongodb.readinessProbe.initialDelaySeconds | int | `20` |  |
| funnel.mongodb.readinessProbe.periodSeconds | int | `10` |  |
| funnel.mongodb.readinessProbe.timeoutSeconds | int | `10` |  |
| funnel.postgresql.enabled | bool | `false` |  |
| funnel.resources.requests.ephemeral_storage | string | `"2Gi"` |  |
| funnel.resources.requests.memory | string | `"2Gi"` |  |
| funnel.volumeMounts[0].mountPath | string | `"/etc/config/funnel-server.yaml"` |  |
| funnel.volumeMounts[0].name | string | `"funnel-patched-config-volume"` |  |
| funnel.volumeMounts[0].subPath | string | `"funnel-patched.conf"` |  |
| funnel.volumeMounts[1].mountPath | string | `"/etc/config/oidc"` |  |
| funnel.volumeMounts[1].name | string | `"funnel-oidc-volume"` |  |
| funnel.volumeMounts[1].readOnly | bool | `true` |  |
| funnel.volumeMounts[2].mountPath | string | `"/etc/funnel/templates"` |  |
| funnel.volumeMounts[2].name | string | `"worker-templates-volume"` |  |
| funnel.volumeMounts[3].mountPath | string | `"/opt/funnel/plugin-binaries"` |  |
| funnel.volumeMounts[3].name | string | `"plugin-volume"` |  |
| funnel.volumes[0].configMap.name | string | `"funnel-server-config"` |  |
| funnel.volumes[0].name | string | `"funnel-config-volume"` |  |
| funnel.volumes[1].name | string | `"funnel-oidc-volume"` |  |
| funnel.volumes[1].secret.items[0].key | string | `"client_id"` |  |
| funnel.volumes[1].secret.items[0].path | string | `"client_id"` |  |
| funnel.volumes[1].secret.items[1].key | string | `"client_secret"` |  |
| funnel.volumes[1].secret.items[1].path | string | `"client_secret"` |  |
| funnel.volumes[1].secret.secretName | string | `"funnel-oidc-client"` |  |
| funnel.volumes[2].configMap.name | string | `"funnel-worker-templates"` |  |
| funnel.volumes[2].name | string | `"worker-templates-volume"` |  |
| funnel.volumes[3].emptyDir | object | `{}` |  |
| funnel.volumes[3].name | string | `"plugin-volume"` |  |
| funnel.volumes[4].emptyDir | object | `{}` |  |
| funnel.volumes[4].name | string | `"funnel-patched-config-volume"` |  |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.aws.externalSecrets.pushSecret | bool | `false` | Whether to create the database and Secrets Manager secrets via PushSecret. |
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.clusterName | string | `"default"` |  |
| global.environment | string | `"default"` |  |
| global.externalSecrets.clusterSecretStoreRef | string | `""` |  |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any gen3-workflow secrets you have deployed. |
| global.externalSecrets.pushFunnelOidcClientToExternalSecrets | bool | `true` |  |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `""` | Hostname for the deployment. |
| global.netPolicy | map | `{"enabled":false}` | Network policy settings. |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.postgres.dbCreate | bool | `true` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of master Postgres secret in Secrets Manager. Disabled if empty |
| global.postgres.master | map | `{"host":"test","password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `"test"` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| metricsEnabled | bool | `false` |  |
| oidc_job_enabled | bool | `true` | Whether to create a job to generate the OIDC client for Funnel. |
| partOf | string | `"Workflow_Execution"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
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
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
