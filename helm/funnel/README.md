# funnel

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.29 |
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.82 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| externalSecrets | map | `{"createFunnelOidcClientSecret":true,"dbcreds":"","funnelOidcClient":null}` | External Secrets settings. |
| externalSecrets.createFunnelOidcClientSecret | bool | `true` | Whether to create the Funnel OIDC client secret using the oidc job. |
| externalSecrets.dbcreds | string | `""` | Name of the secret that will be created in secrets manager |
| externalSecrets.funnelOidcClient | string | `nil` | Will override the name of the aws secrets manager secret. Default is "funnel-oidc-client". |
| funnel."nodeclass.yaml" | string | `"apiVersion: karpenter.k8s.aws/v1\nkind: EC2NodeClass\nmetadata:\n  name: gen3-workflow-user-USER_ID\nspec:\n  amiFamily: AL2\n  amiSelectorTerms:\n  - name: 1-31-EKS-FIPS*\n    owner: \"143731057154\"\n  blockDeviceMappings:\n  - deviceName: /dev/xvda\n    ebs:\n      deleteOnTermination: true\n      encrypted: true\n      volumeSize: 100Gi\n      volumeType: gp2\n  metadataOptions:\n    httpEndpoint: enabled\n    httpProtocolIPv6: disabled\n    httpPutResponseHopLimit: 2\n    httpTokens: optional\n  role: eks_ENVIRONMENT_workers_role\n  securityGroupSelectorTerms:\n  - tags:\n      karpenter.sh/discovery: ENVIRONMENT-workflow\n  subnetSelectorTerms:\n  - tags:\n      karpenter.sh/discovery: ENVIRONMENT\n  tags:\n    Environment: ENVIRONMENT\n    Name: eks-ENVIRONMENT-workflow-karpenter\n    gen3service: argo-workflows\n    gen3username: GEN3_USERNAME\n    gen3teamproject: \"GEN3_TEAMNAME\"\n    karpenter.sh/discovery: ENVIRONMENT\n    purpose: gen3-workflow-task\n    \"vadc:cost-type\": user-based-variable\n    \"vadc:usage-type\": user-infrastructure\n    \"vadc:environment-type\": \"ENVIRONMENT_TYPE_CODE\"\n  userData: |\n    MIME-Version: 1.0\n    Content-Type: multipart/mixed; boundary=\"BOUNDARY\"\n\n    --BOUNDARY\n    Content-Type: text/x-shellscript; charset=\"us-ascii\"\n\n    #!/bin/bash -x\n    instanceId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId)\n    curl https://raw.githubusercontent.com/uc-cdis/cloud-automation/master/files/authorized_keys/ops_team >> /home/ec2-user/.ssh/authorized_keys\n\n    echo \"$(jq '.registryPullQPS=0' /etc/kubernetes/kubelet/kubelet-config.json)\" > /etc/kubernetes/kubelet/kubelet-config.json\n\n    sysctl -w fs.inotify.max_user_watches=12000\n\n    --BOUNDARY--\n"` |  |
| funnel."nodepool.yaml" | string | `"apiVersion: karpenter.sh/v1\nkind: NodePool\nmetadata:\n  name: gen3-workflow-USER_ID\nspec:\n  disruption:\n    consolidateAfter: 10s\n    consolidationPolicy: WhenEmpty\n  limits:\n    cpu: 4k\n  template:\n    metadata:\n      labels:\n        purpose: workflow\n        role: WORKFLOW_NAME\n    spec:\n      nodeClassRef:\n        group: karpenter.k8s.aws\n        kind: EC2NodeClass\n        name: gen3-workflow-USER_ID\n      requirements:\n      - key: karpenter.sh/capacity-type\n        operator: In\n        values:\n        - on-demand\n      - key: kubernetes.io/arch\n        operator: In\n        values:\n        - amd64\n      - key: node.kubernetes.io/instance-type\n        operator: In\n        values:\n        - c6a.large\n        - c6a.xlarge\n        - c6a.2xlarge\n        - c6a.4xlarge\n        - c6a.8xlarge\n        - c6a.12xlarge\n        - c7a.large\n        - c7a.xlarge\n        - c7a.2xlarge\n        - c7a.4xlarge\n        - c7a.8xlarge\n        - c7a.12xlarge\n        - c6i.large\n        - c6i.xlarge\n        - c6i.2xlarge\n        - c6i.4xlarge\n        - c6i.8xlarge\n        - c6i.12xlarge\n        - c7i.large\n        - c7i.xlarge\n        - c7i.2xlarge\n        - c7i.4xlarge\n        - c7i.8xlarge\n        - c7i.12xlarge\n        - m6a.2xlarge\n        - m6a.4xlarge\n        - m6a.8xlarge\n        - m6a.12xlarge\n        - m6a.16xlarge\n        - m6a.24xlarge\n        - m7a.2xlarge\n        - m7a.4xlarge\n        - m7a.8xlarge\n        - m7a.12xlarge\n        - m7a.16xlarge\n        - m7a.24xlarge\n        - m6i.2xlarge\n        - m6i.4xlarge\n        - m6i.8xlarge\n        - m6i.12xlarge\n        - m6i.16xlarge\n        - m6i.24xlarge\n        - m7i.2xlarge\n        - m7i.4xlarge\n        - m7i.8xlarge\n        - m7i.12xlarge\n        - m7i.16xlarge\n        - m7i.24xlarge\n        - r7iz.2xlarge\n        - r7iz.4xlarge\n        - r7iz.8xlarge\n        - r7iz.12xlarge\n        - r7iz.16xlarge\n        - r7iz.24xlarge\n      - key: kubernetes.io/os\n        operator: In\n        values:\n        - linux\n      taints:\n      - effect: NoSchedule\n        key: role\n        value: WORKFLOW_NAME"` |  |
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
| funnel.image | map | `{"initContainers":[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","# Create a funnel-patched.conf since /etc/config/funnel.conf is readonly\nCONFIG=/tmp/funnel-patched.conf\ncp /etc/config/funnel.conf $CONFIG\n\nnamespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)\nexport JOBS_NAMESPACE=workflow-pods-$namespace\nexport S3_URL=gen3-workflow-service.$namespace.svc.cluster.local\n\n# `Kubernetes.JobsNamespace` has to be configured manually because of templating\n# limitations. This ensures it is configured to the value that is hardcoded elsewhere.\nconfigured=$(yq -r '.Kubernetes.JobsNamespace' \"$CONFIG\")\nif [[ \"$configured\" != \"$JOBS_NAMESPACE\" ]]; then\n  echo \"ERROR: funnel.Kubernetes.JobsNamespace is set to '$configured' instead of '$JOBS_NAMESPACE'. Please fix the configuration\" >&2\n  exit 1\nfi\n\necho \"======= Funnel configuration =======\"\necho \"  Kubernetes.JobsNamespace   : $JOBS_NAMESPACE\"\necho \"  Plugins.Params.OidcClientId: $FUNNEL_OIDC_CLIENT_ID\"\necho \"  Plugins.Params.S3Url       : $S3_URL\"\necho \"  Postgres.Database          : $DB_DATABASE\"\necho \"====================================\"\n\n# Replace placeholders with actual values (in-place)\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_ID}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_SECRET}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_S3URL_PLACEHOLDER|${S3_URL}|g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_HOST_PLACEHOLDER/${DB_HOST}:5432/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_DATABASE_PLACEHOLDER/${DB_DATABASE}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_USER_PLACEHOLDER/${DB_USER}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/g\" $CONFIG\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"key":"host","name":"funnel-dbcreds","optional":false}}},{"name":"DB_USER","valueFrom":{"secretKeyRef":{"key":"username","name":"funnel-dbcreds","optional":false}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"funnel-dbcreds","optional":false}}},{"name":"DB_DATABASE","valueFrom":{"secretKeyRef":{"key":"database","name":"funnel-dbcreds","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"config-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}],"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel"}` | Configuration for the Funnel container image. |
| funnel.image.initContainers | map | `[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","# Create a funnel-patched.conf since /etc/config/funnel.conf is readonly\nCONFIG=/tmp/funnel-patched.conf\ncp /etc/config/funnel.conf $CONFIG\n\nnamespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)\nexport JOBS_NAMESPACE=workflow-pods-$namespace\nexport S3_URL=gen3-workflow-service.$namespace.svc.cluster.local\n\n# `Kubernetes.JobsNamespace` has to be configured manually because of templating\n# limitations. This ensures it is configured to the value that is hardcoded elsewhere.\nconfigured=$(yq -r '.Kubernetes.JobsNamespace' \"$CONFIG\")\nif [[ \"$configured\" != \"$JOBS_NAMESPACE\" ]]; then\n  echo \"ERROR: funnel.Kubernetes.JobsNamespace is set to '$configured' instead of '$JOBS_NAMESPACE'. Please fix the configuration\" >&2\n  exit 1\nfi\n\necho \"======= Funnel configuration =======\"\necho \"  Kubernetes.JobsNamespace   : $JOBS_NAMESPACE\"\necho \"  Plugins.Params.OidcClientId: $FUNNEL_OIDC_CLIENT_ID\"\necho \"  Plugins.Params.S3Url       : $S3_URL\"\necho \"  Postgres.Database          : $DB_DATABASE\"\necho \"====================================\"\n\n# Replace placeholders with actual values (in-place)\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_ID_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_ID}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_OIDC_CLIENT_SECRET_PLACEHOLDER|${FUNNEL_OIDC_CLIENT_SECRET}|g\" $CONFIG\nsed -i \"s|FUNNEL_PLUGIN_S3URL_PLACEHOLDER|${S3_URL}|g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_HOST_PLACEHOLDER/${DB_HOST}:5432/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_DATABASE_PLACEHOLDER/${DB_DATABASE}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_USER_PLACEHOLDER/${DB_USER}/g\" $CONFIG\nsed -i \"s/FUNNEL_POSTGRES_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/g\" $CONFIG\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"key":"host","name":"funnel-dbcreds","optional":false}}},{"name":"DB_USER","valueFrom":{"secretKeyRef":{"key":"username","name":"funnel-dbcreds","optional":false}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"funnel-dbcreds","optional":false}}},{"name":"DB_DATABASE","valueFrom":{"secretKeyRef":{"key":"database","name":"funnel-dbcreds","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"config-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}]` | Configuration for the Funnel init container. |
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
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| metricsEnabled | bool | `false` |  |
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
