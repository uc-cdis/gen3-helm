# terraform-runner-job

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: feat_tf1X_jq](https://img.shields.io/badge/AppVersion-feat_tf1X_jq-informational?style=flat-square)

A Helm chart for provisioning prequisites cloud resources for gen3

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| credentials.aws.key | string | `""` |  |
| credentials.aws.secret | string | `""` |  |
| credentials.aws.session_token | string | `""` |  |
| image.tag | string | `"master"` |  |
| terraform.destroy | bool | `false` |  |
| terraform.resource_name | string | `""` |  |
| terraform.workspace_name | string | `""` |  |

