# gen3

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

Helm chart to deploy Gen3 Data Commons

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ahilt | <ahilt@uchicago.edu> |  |
| ajoaugustine | <ajoa@uchicago.edu> |  |
| emalinowski | <emalinowski@uchicago.edu> |  |
| EliseCastle23 | <elisemcastle@uchicago.edu> |  |
| jawadqur | <qureshi@uchicago.edu> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../app | arborist(app) | 0.1.0 |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |
| https://helm.elastic.co | elasticsearch | 7.10.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| arborist.args[0] | string | `"-c"` |  |
| arborist.args[1] | string | `"set -e\n# set env vars\nexport PGSSLMODE=\"disable\"\n\n# bring the database schema up to the latest version\n/go/src/github.com/uc-cdis/arborist/migrations/latest\n\n# run arborist\n/go/src/github.com/uc-cdis/arborist/bin/arborist\n"` |  |
| arborist.command[0] | string | `"sh"` |  |
| arborist.cronjobs[0].affinityOverride | object | `{}` |  |
| arborist.cronjobs[0].args[0] | string | `"-c"` |  |
| arborist.cronjobs[0].args[1] | string | `"/go/src/github.com/uc-cdis/arborist/jobs/delete_expired_access\n"` |  |
| arborist.cronjobs[0].automountServiceAccountToken | bool | `false` |  |
| arborist.cronjobs[0].command[0] | string | `"sh"` |  |
| arborist.cronjobs[0].dbSecretName | string | `"arborist-dbcreds"` |  |
| arborist.cronjobs[0].dnsConfig.options[0].name | string | `"use-vc"` |  |
| arborist.cronjobs[0].dnsConfig.options[1].name | string | `"single-request-reopen"` |  |
| arborist.cronjobs[0].envFromApp | bool | `true` |  |
| arborist.cronjobs[0].name | string | `"arborist-rm-expired-access"` |  |
| arborist.cronjobs[0].schedule | string | `"*/5 * * * *"` |  |
| arborist.dbService | bool | `true` |  |
| arborist.enabled | bool | `true` | Whether to deploy the ambassador subchart. |
| arborist.env[0].name | string | `"PGSSLMODE"` |  |
| arborist.env[0].value | string | `"disable"` |  |
| arborist.image.pullPolicy | string | `"IfNotPresent"` |  |
| arborist.image.repository | string | `"quay.io/cdis/arborist"` |  |
| arborist.image.tag | string | `"master"` |  |
| arborist.livenessProbe.path | string | `"/health"` |  |
| arborist.readinessProbe.path | string | `"/health"` |  |
| auroraRdsCopyJob.auroraMasterSecret | string | `""` |  |
| auroraRdsCopyJob.enabled | bool | `false` |  |
| auroraRdsCopyJob.services | list | `[]` |  |
| auroraRdsCopyJob.sourceNamespace | string | `""` |  |
| auroraRdsCopyJob.targetNamespace | string | `""` |  |
| auroraRdsCopyJob.writeToAwsSecret | bool | `false` |  |
| auroraRdsCopyJob.writeToK8sSecret | bool | `false` |  |
| elasticsearch.clusterHealthCheckParams | string | `"wait_for_status=yellow&timeout=1s"` |  |
| elasticsearch.clusterName | string | `"gen3-elasticsearch"` |  |
| elasticsearch.esConfig."elasticsearch.yml" | string | `"# Here we can add elasticsearch config\n"` |  |
| elasticsearch.maxUnavailable | int | `0` |  |
| elasticsearch.replicas | int | `1` |  |
| elasticsearch.resources.requests.cpu | string | `"500m"` |  |
| elasticsearch.singleNode | bool | `true` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null,"pushSecret":false},"region":"us-east-1","secretStoreServiceAccount":{"enabled":false,"name":"secret-store-sa","roleArn":null},"useLocalSecret":{"enabled":false,"localSecretName":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.aws.externalSecrets.pushSecret | bool | `false` | Whether to create the database and Secrets Manager secrets via PushSecret. |
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.aws.secretStoreServiceAccount | map | `{"enabled":false,"name":"secret-store-sa","roleArn":null}` | Service account and AWS role for authentication to AWS Secrets Manager |
| global.aws.secretStoreServiceAccount.enabled | bool | `false` | Set true if deploying to AWS and want to use service account and IAM role instead of aws keys. Must provide role-arn. |
| global.aws.secretStoreServiceAccount.name | string | `"secret-store-sa"` | Name of the service account to create |
| global.aws.secretStoreServiceAccount.roleArn | string | `nil` | AWS Role ARN for Secret Store to use |
| global.aws.useLocalSecret | map | `{"enabled":false,"localSecretName":null}` | Local secret setting if using a pre-exising secret. |
| global.aws.useLocalSecret.enabled | bool | `false` | Set to true if you would like to use a secret that is already running on your cluster. |
| global.aws.useLocalSecret.localSecretName | string | `nil` | Name of the local secret. |
| global.clusterName | string | `"default"` | Kubernetes cluster name. |
| global.createSlackWebhookSecret | bool | `false` | Will create a Kubernetes Secret for the slack webhook. |
| global.crossplane | map | `{"accountId":123456789012,"enabled":false,"oidcProviderUrl":"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890","providerConfigName":"provider-aws","s3":{"kmsKeyId":null,"versioningEnabled":false}}` | Kubernetes configuration |
| global.crossplane.accountId | string | `123456789012` | The account ID of the AWS account. |
| global.crossplane.enabled | bool | `false` | Set to true if deploying to AWS and want to use crossplane for AWS resources. |
| global.crossplane.oidcProviderUrl | string | `"oidc.eks.us-east-1.amazonaws.com/id/12345678901234567890"` | OIDC provider URL. This is used for authentication of roles/service accounts. |
| global.crossplane.providerConfigName | string | `"provider-aws"` | The name of the crossplane provider config. |
| global.crossplane.s3.kmsKeyId | string | `nil` | The kms key id for the s3 bucket. |
| global.crossplane.s3.versioningEnabled | bool | `false` | Whether to use s3 bucket versioning. |
| global.dataUploadBucket | string | `nil` |  |
| global.dev | bool | `true` | Deploys postgres/elasticsearch for dev |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces in same cluster. |
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","createLocalK8sSecret":false,"createSlackWebhookSecret":false,"deploy":false,"slackWebhookSecretName":""}` | External Secrets settings. |
| global.externalSecrets.createLocalK8sSecret | bool | `false` | Will create the databases and store the creds in Kubernetes Secrets even if externalSecrets is deployed. Useful if you want to use ExternalSecrets for other secrets besides db secrets. |
| global.externalSecrets.createSlackWebhookSecret | bool | `false` | Will create a Kubernetes Secret for the slack webhook. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| global.externalSecrets.slackWebhookSecretName | string | `""` | Name of the secret in Secrets Manager that contains the slack webhook. |
| global.frontendRoot | string | `"portal"` | Which app will be served on /. Needs be set to portal for portal, or "gen3ff" for frontendframework. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.logoutInactiveUsers | bool | `true` |  |
| global.maintenanceMode | string | `"off"` |  |
| global.manifestGlobalExtraValues | map | `{}` | If you would like to add any extra values to the manifest-global configmap. |
| global.metricsEnabled | bool | `true` |  |
| global.netPolicy | bool | `{"dbSubnet":"","enabled":false}` | Global flags to control and manage network policies for a Gen3 installation NOTE: Network policies are currently a beta feature. Use with caution! |
| global.netPolicy.dbSubnet | array | `""` | A CIDR range representing a database subnet, that services with a database need access to |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres.dbCreate | bool | `true` | Whether the database create job should run. |
| global.postgres.externalSecret | string | `""` | Name of external secret of the postgres master credentials. Disabled if empty |
| global.postgres.master.host | string | `nil` | global postgres master host |
| global.postgres.master.password | string | `nil` | global postgres master password |
| global.postgres.master.port | string | `"5432"` | global postgres master port |
| global.postgres.master.username | string | `"postgres"` | global postgres master username |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.slackWebhook | string | `""` | slack webhook for notifications |
| global.tierAccessLevel | string | `"private"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| global.tierAccessLimit | int | `"1000"` | Only relevant if tireAccessLevel is set to "regular". Summary charts below this limit will not appear for aggregated data. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| global.workspaceTimeoutInMinutes | int | `480` |  |
| mutatingWebhook.enabled | bool | `false` | Whether to deploy the mutating webhook service. |
| mutatingWebhook.image | string | `"quay.io/cdis/node-affinity-daemonset:feat_pods"` | image |
| postgresql | map | `{"image":{"repository":"bitnamilegacy/postgresql"},"primary":{"persistence":{"enabled":false}}}` | To configure postgresql subchart Disable persistence by default so we can spin up and down ephemeral environments |
| postgresql.primary.persistence.enabled | bool | `false` | Option to persist the dbs data. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
