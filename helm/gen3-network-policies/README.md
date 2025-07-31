# gen3-network-policies

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.2](https://img.shields.io/badge/AppVersion-0.1.2-informational?style=flat-square)

A Helm chart that holds network policies needed to run Gen3

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-workflows.enabled | bool | `true` |  |
| argocd.enabled | bool | `true` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"region":"us-east-1","secretStoreServiceAccount":{"enabled":false,"name":"secret-store-sa","roleArn":null},"useLocalSecret":{"enabled":false,"localSecretName":null}}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.aws.secretStoreServiceAccount | map | `{"enabled":false,"name":"secret-store-sa","roleArn":null}` | Service account and AWS role for authentication to AWS Secrets Manager |
| global.aws.secretStoreServiceAccount.enabled | bool | `false` | Set true if deploying to AWS and want to use service account and IAM role instead of aws keys. Must provide role-arn. |
| global.aws.secretStoreServiceAccount.name | string | `"secret-store-sa"` | Name of the service account to create |
| global.aws.secretStoreServiceAccount.roleArn | string | `nil` | AWS Role ARN for Secret Store to use |
| global.aws.useLocalSecret | map | `{"enabled":false,"localSecretName":null}` | Local secret setting if using a pre-exising secret. |
| global.aws.useLocalSecret.enabled | bool | `false` | Set to true if you would like to use a secret that is already running on your cluster. |
| global.aws.useLocalSecret.localSecretName | string | `nil` | Name of the local secret. |
| global.dev | bool | `true` | Deploys postgres/elasticsearch for dev |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` | URL of the data dictionary. |
| global.dispatcherJobNum | int | `"10"` | Number of dispatcher jobs. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces in same cluster. |
| global.externalSecrets | map | `{"dbCreate":false,"deploy":false}` | External Secrets settings. |
| global.externalSecrets.dbCreate | bool | `false` | Will create the databases and store the creds in Kubernetes Secrets even if externalSecrets is deployed. Useful if you want to use ExternalSecrets for other secrets besides db secrets. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| global.frontendRoot | string | `"portal"` | Which app will be served on /. Needs be set to portal for portal, or "gen3ff" for frontendframework. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.manifestGlobalExtraValues | map | `{}` | If you would like to add any extra values to the manifest-global configmap. |
| global.netPolicy | bool | `{"dbSubnet":"","enabled":false}` | Global flags to control and manage network policies for a Gen3 installation NOTE: Network policies are currently a beta feature. Use with caution! |
| global.netPolicy.dbSubnet | array | `""` | A CIDR range representing a database subnet, that services with a database need access to |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.portalApp | string | `"gitops"` | Portal application name. |
| global.postgres.dbCreate | bool | `true` | Whether the database create job should run. |
| global.postgres.master.host | string | `nil` | global postgres master host |
| global.postgres.master.password | string | `nil` | global postgres master password |
| global.postgres.master.port | string | `"5432"` | global postgres master port |
| global.postgres.master.username | string | `"postgres"` | global postgres master username |
| global.publicDataSets | bool | `true` | Whether public datasets are enabled. |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` | ARN of the reverse proxy certificate. |
| global.tierAccessLevel | string | `"libre"` | Access level for tiers. acceptable values for `tier_access_level` are: `libre`, `regular` and `private`. If omitted, by default common will be treated as `private` |
| global.tierAccessLimit | int | `"1000"` | Only relevant if tireAccessLevel is set to "regular". Summary charts below this limit will not appear for aggregated data. |
| s3CidrRanges[0].ipBlock.cidr | string | `"18.34.0.0/19"` |  |
| s3CidrRanges[1].ipBlock.cidr | string | `"16.15.192.0/18"` |  |
| s3CidrRanges[2].ipBlock.cidr | string | `"54.231.0.0/16"` |  |
| s3CidrRanges[3].ipBlock.cidr | string | `"52.216.0.0/15"` |  |
| s3CidrRanges[4].ipBlock.cidr | string | `"18.34.232.0/21"` |  |
| s3CidrRanges[5].ipBlock.cidr | string | `"16.15.176.0/20"` |  |
| s3CidrRanges[6].ipBlock.cidr | string | `"16.182.0.0/16"` |  |
| s3CidrRanges[7].ipBlock.cidr | string | `"3.5.0.0/19"` |  |
| s3CidrRanges[8].ipBlock.cidr | string | `"44.192.134.240/28"` |  |
| s3CidrRanges[9].ipBlock.cidr | string | `"44.192.140.64/28"` |  |
