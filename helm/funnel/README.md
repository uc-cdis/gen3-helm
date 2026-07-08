# funnel

![Version: 0.1.27](https://img.shields.io/badge/Version-0.1.27-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.36 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| AWSBatch.DisableReconciler | bool | `true` |  |
| AWSBatch.JobDefinition | string | `"funnel-job-def"` |  |
| AWSBatch.JobQueue | string | `"funnel-job-queue"` |  |
| AWSBatch.Key | string | `""` |  |
| AWSBatch.ReconcileRate | string | `"10s"` |  |
| AWSBatch.Region | string | `""` |  |
| AWSBatch.Secret | string | `""` |  |
| AmazonS3.AWSConfig.Key | string | `""` |  |
| AmazonS3.AWSConfig.MaxRetries | int | `10` |  |
| AmazonS3.AWSConfig.Secret | string | `""` |  |
| AmazonS3.Disabled | bool | `false` |  |
| AmazonS3.SSE.CustomerKeyFile | string | `""` |  |
| AmazonS3.SSE.KMSKey | string | `""` |  |
| BoltDB | object | `{"Path":"./funnel-work-dir/funnel.db"}` | Local file database configuration. |
| Compute | string | `"kubernetes"` |  |
| Database | string | `"postgres"` |  |
| Datastore.CredentialsFile | string | `""` |  |
| Datastore.Project | string | `""` |  |
| Datastore.Timeout.duration | string | `"300s"` |  |
| DynamoDB.AWSConfig.Key | string | `""` |  |
| DynamoDB.AWSConfig.Region | string | `""` |  |
| DynamoDB.AWSConfig.Secret | string | `""` |  |
| DynamoDB.TableBasename | string | `"funnel"` |  |
| Elastic.IndexPrefix | string | `"funnel"` |  |
| Elastic.URL | string | `"http://localhost:9200"` |  |
| EventWriters[0] | string | `"postgres"` |  |
| EventWriters[1] | string | `"log"` |  |
| FTPStorage.Disabled | bool | `false` |  |
| FTPStorage.Password | string | `"anonymous"` |  |
| FTPStorage.Timeout | string | `"10s"` |  |
| FTPStorage.User | string | `"anonymous"` |  |
| GoogleStorage.CredentialsFile | string | `""` |  |
| GoogleStorage.Disabled | bool | `false` |  |
| GridEngine.Template | string | `"#!bin/bash\n#$ -N {{.TaskId}}\n#$ -o {{.WorkDir}}/funnel-stdout\n#$ -e {{.WorkDir}}/funnel-stderr\n#$ -l nodes=1\n{{if ne .Cpus 0 -}}\n{{printf \"#$ -pe mpi %d\" .Cpus}}\n{{- end}}\n{{if ne .RamGb 0.0 -}}\n{{printf \"#$ -l h_vmem=%.0fG\" .RamGb}}\n{{- end}}\n{{if ne .DiskGb 0.0 -}}\n{{printf \"#$ -l h_fsize=%.0fG\" .DiskGb}}\n{{- end}}\n\n{{.Executable}} worker run --config {{.Config}} --taskID {{.TaskId}}\n"` |  |
| GridEngine.TemplateFile | string | `""` |  |
| HTCondor | object | `{"DisableReconciler":true,"ReconcileRate":"10s","Template":"universe = vanilla\ngetenv = True\nexecutable = {{.Executable}}\narguments = worker run --config {{.Config}} --task-id {{.TaskId}}\nlog = {{.WorkDir}}/condor-event-log\nerror = {{.WorkDir}}/funnel-stderr\noutput = {{.WorkDir}}/funnel-stdout\nshould_transfer_files = YES\nwhen_to_transfer_output = ON_EXIT_OR_EVICT\n{{if ne .Cpus 0 -}}\n{{printf \"request_cpus = %d\" .Cpus}}\n{{- end}}\n{{if ne .RamGb 0.0 -}}\n{{printf \"request_memory = %.0f GB\" .RamGb}}\n{{- end}}\n{{if ne .DiskGb 0.0 -}}\n{{printf \"request_disk = %.0f GB\" .DiskGb}}\n{{- end}}\n\nqueue\n","TemplateFile":""}` | HTCondor compute backend configuration. |
| HTTPStorage.Timeout | string | `"30s"` |  |
| Kafka.Topic | string | `"funnel"` |  |
| Kubernetes.DisableJobCleanup | bool | `false` |  |
| Kubernetes.DisableReconciler | bool | `false` |  |
| Kubernetes.Executor.Annotations."karpenter.sh/do-not-disrupt" | string | `"true"` |  |
| Kubernetes.Executor.PriorityClassName | string | `""` |  |
| Kubernetes.Executor.backoffLimit | int | `0` |  |
| Kubernetes.Executor.completions | int | `1` |  |
| Kubernetes.Executor.restartPolicy | string | `"Never"` |  |
| Kubernetes.ExecutorTemplate | string | `""` |  |
| Kubernetes.ForbiddenPathPrefixes | list | `[]` | Path prefixes that Funnel's Kubernetes backend must reject when creating worker pods. |
| Kubernetes.JobsNamespace | string | `""` |  |
| Kubernetes.Namespace | string | `""` |  |
| Kubernetes.NodeSelector | object | `{}` |  |
| Kubernetes.PVCTemplate | string | `""` |  |
| Kubernetes.PVTemplate | string | `""` |  |
| Kubernetes.ReconcileRate | string | `"120s"` |  |
| Kubernetes.Resources.Defaults.Cpus | string | `"1000m"` |  |
| Kubernetes.Resources.Defaults.DiskGb | string | `"512Mi"` |  |
| Kubernetes.Resources.Defaults.RamGb | string | `"512Mi"` |  |
| Kubernetes.Resources.Limits.Cpus | string | `"8000m"` |  |
| Kubernetes.Resources.Limits.DiskGb | string | `"4096Mi"` |  |
| Kubernetes.Resources.Limits.RamGb | string | `"4096Mi"` |  |
| Kubernetes.ServiceAccount | string | `""` |  |
| Kubernetes.Timeout.duration | string | `"300s"` |  |
| Kubernetes.Tolerations | list | `[]` |  |
| Kubernetes.Worker.Annotations."karpenter.sh/do-not-disrupt" | string | `"true"` |  |
| Kubernetes.Worker.PriorityClassName | string | `"system-cluster-critical"` |  |
| Kubernetes.Worker.backoffLimit | int | `0` |  |
| Kubernetes.Worker.completions | int | `1` |  |
| Kubernetes.Worker.restartPolicy | string | `"Never"` |  |
| Kubernetes.WorkerTemplate | string | `""` |  |
| LocalStorage | object | `{"AllowedDirs":["./"]}` | Local file system storage configuration. |
| Logger.Formatter | string | `"json"` |  |
| Logger.Level | string | `"debug"` |  |
| Logger.OutputFile | string | `""` |  |
| Logger.TextFormat.ForceColors | bool | `true` |  |
| Logger.TextFormat.FullTimestamp | bool | `true` |  |
| Logger.TextFormat.TimestampFormat | string | `"2006-01-02T15:04:05Z07:00"` |  |
| Node.ID | string | `""` |  |
| Node.Resources.Cpus | int | `0` |  |
| Node.Resources.DiskGb | float | `0` |  |
| Node.Resources.RamGb | float | `0` |  |
| Node.Timeout.disabled | bool | `true` |  |
| Node.UpdateRate | string | `"5s"` |  |
| PBS.DisableReconciler | bool | `true` |  |
| PBS.ReconcileRate | string | `"10s"` |  |
| PBS.Template | string | `"#!bin/bash\n#PBS -N {{.TaskId}}\n#PBS -o {{.WorkDir}}/funnel-stdout\n#PBS -e {{.WorkDir}}/funnel-stderr\n{{if ne .Cpus 0 -}}\n{{printf \"#PBS -l nodes=1:ppn=%d\" .Cpus}}\n{{- end}}\n{{if ne .RamGb 0.0 -}}\n{{printf \"#PBS -l mem=%.0fgb\" .RamGb}}\n{{- end}}\n{{if ne .DiskGb 0.0 -}}\n{{printf \"#PBS -l file=%.0fgb\" .DiskGb}}\n{{- end}}\n\n{{.Executable}} worker run --config {{.Config}} --taskID {{.TaskId}}\n"` |  |
| PBS.TemplateFile | string | `""` |  |
| Plugins.Params.OidcClientId | string | `"FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER"` |  |
| Plugins.Params.OidcClientSecret | string | `"FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER"` |  |
| Plugins.Params.S3Url | string | `"FUNNEL_PLUGIN_S3URL_PLACEHOLDER"` |  |
| Plugins.Path | string | `"plugin-binaries/auth-plugin"` |  |
| Postgres.AdminPassword | string | `"example"` |  |
| Postgres.AdminUser | string | `"postgres"` |  |
| Postgres.Database | string | `"FUNNEL_POSTGRES_DATABASE_PLACEHOLDER"` |  |
| Postgres.Host | string | `"FUNNEL_POSTGRES_HOST_PLACEHOLDER"` |  |
| Postgres.Password | string | `"FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER"` |  |
| Postgres.Timeout.duration | string | `"300s"` |  |
| Postgres.User | string | `"FUNNEL_POSTGRES_USER_PLACEHOLDER"` |  |
| RPCClient.MaxRetries | int | `10` |  |
| RPCClient.ServerAddress | string | `"localhost:9090"` |  |
| RPCClient.Timeout.duration | string | `"60s"` |  |
| Scheduler.NodeInitTimeout.duration | string | `"300s"` |  |
| Scheduler.NodePingTimeout.duration | string | `"60s"` |  |
| Scheduler.ScheduleChunk | int | `10` |  |
| Scheduler.ScheduleRate | string | `"1s"` |  |
| Server.DisableHTTPCache | bool | `true` |  |
| Server.HTTPPort | string | `"8000"` |  |
| Server.HostName | string | `"funnel"` |  |
| Server.RPCPort | string | `"9090"` |  |
| Slurm.DisableReconciler | bool | `true` |  |
| Slurm.ReconcileRate | string | `"10s"` |  |
| Slurm.Template | string | `"#!/bin/bash\n#SBATCH --job-name {{.TaskId}}\n#SBATCH --ntasks 1\n#SBATCH --error {{.WorkDir}}/funnel-stderr\n#SBATCH --output {{.WorkDir}}/funnel-stdout\n{{if ne .Cpus 0 -}}\n{{printf \"#SBATCH --cpus-per-task %d\" .Cpus}}\n{{- end}}\n{{if ne .RamGb 0.0 -}}\n{{printf \"#SBATCH --mem %.0fGB\" .RamGb}}\n{{- end}}\n{{if ne .DiskGb 0.0 -}}\n{{printf \"#SBATCH --tmp %.0fGB\" .DiskGb}}\n{{- end}}\n\n{{.Executable}} worker run --config {{.Config}} --taskID {{.TaskId}}\n"` |  |
| Slurm.TemplateFile | string | `""` |  |
| Swift.AuthURL | string | `""` |  |
| Swift.ChunkSizeBytes | int | `500000000` |  |
| Swift.Disabled | bool | `false` |  |
| Swift.Password | string | `""` |  |
| Swift.RegionName | string | `""` |  |
| Swift.TenantID | string | `""` |  |
| Swift.TenantName | string | `""` |  |
| Swift.UserName | string | `""` |  |
| Worker.LeaveWorkDir | bool | `true` |  |
| Worker.LeaveWorkDir | bool | `false` |  |
| Worker.LogTailSize | int | `10000` |  |
| Worker.LogUpdateRate | string | `"5s"` |  |
| Worker.MaxParallelTransfers | int | `10` |  |
| Worker.PollingRate | string | `"5s"` |  |
| Worker.WorkDir | string | `"./funnel-work-dir"` |  |
| authenticationSource | string | `"pod"` |  |
| cleanup.enabled | bool | `false` |  |
| cleanup.schedule | string | `""` |  |
| cleanup.scheduleOffsetMinutes | int | `0` |  |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| externalSecrets | map | `{"createFunnelOidcClientSecret":true,"dbcreds":"","funnelOidcClient":null}` | External Secrets settings. |
| externalSecrets.createFunnelOidcClientSecret | bool | `true` | Whether to create the Funnel OIDC client secret using the oidc job. |
| externalSecrets.dbcreds | string | `""` | Name of the secret that will be created in secrets manager |
| externalSecrets.funnelOidcClient | string | `nil` | Will override the name of the aws secrets manager secret. Default is "funnel-oidc-client". |
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
| global.kubeapi_endpoints | map | `{"enabled":false,"ip":[]}` | Configuration for kubeapi endpoints if you want to allowlist specific IPs for egress instead of allowing access to the entire cluster. |
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
| image.initContainers | map | `[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","# Create a funnel-patched.conf since /etc/config/funnel.conf is readonly\nCONFIG=/tmp/funnel-patched.conf\ncp /etc/config/funnel.conf $CONFIG\n\nnamespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)\nJOBS_NAMESPACE=workflow-pods-$namespace\nS3_URL=gen3-workflow-service.$namespace.svc.cluster.local\nDB_HOST=$DB_HOST:5432\n\n# `Kubernetes.JobsNamespace` has to be configured manually because of templating\n# limitations. This ensures it is configured to the value that is hardcoded elsewhere.\nconfigured=$(yq -r '.Kubernetes.JobsNamespace' \"$CONFIG\")\nif [[ \"$configured\" != \"$JOBS_NAMESPACE\" ]]; then\n  echo \"ERROR: funnel.Kubernetes.JobsNamespace is set to '$configured' instead of '$JOBS_NAMESPACE'. Please fix the configuration\" >&2\n  exit 1\nfi\n\necho \"======= Funnel configuration =======\"\necho \"  Kubernetes.JobsNamespace   : $JOBS_NAMESPACE\"\necho \"  Plugins.Params.OidcClientId: $FUNNEL_OIDC_CLIENT_ID\"\necho \"  Plugins.Params.S3Url       : $S3_URL\"\necho \"  Postgres.Host              : $DB_HOST\"\necho \"  Postgres.Database          : $DB_DATABASE\"\necho \"  Postgres.User              : $DB_USER\"\necho \"====================================\"\n\n# Replace placeholders with actual values (in-place)\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_ID}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_SECRET}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_S3URL_PLACEHOLDER|${S3_URL}|g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_HOST_PLACEHOLDER/${DB_HOST}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_DATABASE_PLACEHOLDER/${DB_DATABASE}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_USER_PLACEHOLDER/${DB_USER}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/g\" $CONFIG\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"key":"host","name":"funnel-dbcreds","optional":false}}},{"name":"DB_USER","valueFrom":{"secretKeyRef":{"key":"username","name":"funnel-dbcreds","optional":false}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"funnel-dbcreds","optional":false}}},{"name":"DB_DATABASE","valueFrom":{"secretKeyRef":{"key":"database","name":"funnel-dbcreds","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"config-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}]` | Configuration for the Funnel init container. |
| image.initContainers[0].command | list | `["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| image.initContainers[0].image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| image.initContainers[0].pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.initContainers[0].tag | string | `"main-gen3"` | The Docker image tag for the Funnel init/plugin container. |
| image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.repository | string | `"quay.io/ohsu-comp-bio/funnel"` | The Docker image repository for the Funnel service. |
| image.tag | string | `"2026-06-22"` |  |
| labels.app | string | `"funnel"` |  |
| metricsEnabled | bool | `false` |  |
| netPolicy | map | `{"egressApps":["gen3-workflow"],"ingressApps":["gen3-workflow"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["gen3-workflow"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["gen3-workflow"]` | List of app labels that require ingress to this service |
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
| rbac.create | bool | `true` |  |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"1000m"` |  |
| resources.limits.ephemeral_storage | string | `"2Gi"` |  |
| resources.limits.memory | string | `"2Gi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.ephemeral_storage | string | `"2Gi"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| service.httpPort | int | `8000` |  |
| service.rpcPort | int | `9090` |  |
| service.type | string | `"ClusterIP"` |  |
| storage.accessMode | string | `"ReadWriteMany"` |  |
| storage.className | string | `"s3-csi-sc"` |  |
| storage.createStorageClass | bool | `true` |  |
| storage.driver | string | `"aws-s3"` |  |
| storage.provisioner | string | `"s3.csi.aws.com"` |  |
| storage.size | string | `"10Mi"` |  |
| stsRegion | string | `"us-east-1"` |  |
| volumeMounts[0].mountPath | string | `"/etc/config/funnel-server.yaml"` |  |
| volumeMounts[0].name | string | `"funnel-patched-config-volume"` |  |
| volumeMounts[0].subPath | string | `"funnel-patched.conf"` |  |
| volumeMounts[1].mountPath | string | `"/etc/config/oidc"` |  |
| volumeMounts[1].name | string | `"funnel-oidc-volume"` |  |
| volumeMounts[1].readOnly | bool | `true` |  |
| volumeMounts[2].mountPath | string | `"/etc/funnel/templates"` |  |
| volumeMounts[2].name | string | `"worker-templates-volume"` |  |
| volumeMounts[3].mountPath | string | `"/opt/funnel/plugin-binaries"` |  |
| volumeMounts[3].name | string | `"plugin-volume"` |  |
| volumes[0].configMap.name | string | `"funnel-server-config"` |  |
| volumes[0].name | string | `"funnel-config-volume"` |  |
| volumes[1].name | string | `"funnel-oidc-volume"` |  |
| volumes[1].secret.items[0].key | string | `"client_id"` |  |
| volumes[1].secret.items[0].path | string | `"client_id"` |  |
| volumes[1].secret.items[1].key | string | `"client_secret"` |  |
| volumes[1].secret.items[1].path | string | `"client_secret"` |  |
| volumes[1].secret.secretName | string | `"funnel-oidc-client"` |  |
| volumes[2].configMap.name | string | `"funnel-worker-templates"` |  |
| volumes[2].name | string | `"worker-templates-volume"` |  |
| volumes[3].emptyDir | object | `{}` |  |
| volumes[3].name | string | `"plugin-volume"` |  |
| volumes[4].emptyDir | object | `{}` |  |
| volumes[4].name | string | `"funnel-patched-config-volume"` |  |
