# data-upload-cron

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for the data upload cronjob

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.29 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configmaps.pending.initialPending | object | `{}` |  |
| configmaps.pending.name | string | `"pending-state"` |  |
| configmaps.pending.pendingKey | string | `"pending.json"` |  |
| configmaps.state.initialLastRun | object | `{}` |  |
| configmaps.state.lastRunKey | string | `"current.json"` |  |
| configmaps.state.name | string | `"current-state"` |  |
| enabled | bool | `true` |  |
| env.bucket | string | `"test"` |  |
| env.dispatcherUrl | string | `"http://ssjdispatcher-service/dispatchJob"` |  |
| env.indexdUrl | string | `"http://indexd-service"` |  |
| externalSecrets | map | `{"awsCredsSecret":null,"dcfDataserviceSettingsSecret":null,"deploy":true,"googleCredsSecret":null}` | external secrets for datareplicate jobs |
| global.externalSecrets | map | `{"deploy":true}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `true` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override secrets you have deployed. |
| image.repository | string | `"quay.io/cdis/data-upload-cron"` | Docker repository. |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| rbac.create | bool | `true` |  |
| resources | map | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"2","memory":"512Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"2Gi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"2Gi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"2","memory":"512Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"2"` | The amount of CPU requested |
| resources.requests.memory | string | `"512Mi"` | The amount of memory requested |
| schedule | string | `"*/15 * * * *"` |  |
| serviceAccount.create | bool | `true` |  |
| slack.enabled | bool | `false` |  |
| suspend | bool | `false` |  |
| suspendCronjob | bool | `false` |  |
