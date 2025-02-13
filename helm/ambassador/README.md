# ambassador

![Version: 0.1.17](https://img.shields.io/badge/Version-0.1.17-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.2](https://img.shields.io/badge/AppVersion-1.4.2-informational?style=flat-square)

A Helm chart for deploying ambassador for gen3

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.16 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{}` | Affinity to use for the deployment. |
| autoscaling | map | `{"enabled":false,"maxReplicas":10,"minReplicas":1,"targetCPUUtilizationPercentage":60}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled or not |
| autoscaling.maxReplicas | int | `10` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `60` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"true"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| fullnameOverride | string | `"ambassador-deployment"` | Override the full name of the deployment. |
| global.environment | string | `"default"` | Environment name. This should be the same as vpcname if you're doing an AWS deployment. Currently this is being used to share ALB's if you have multiple namespaces. Might be used other places too. |
| global.minAvialable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/datawire/ambassador","tag":"1.4.2"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/datawire/ambassador"` | Docker repository. |
| image.tag | string | `"1.4.2"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | map | `{}` | Node selector labels. |
| partOf | string | `"Workspace-Tab"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `nil` | Annotations to add to the pod. |
| podSecurityContext | map | `{"runAsUser":8888}` | Pod-level security context. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of replicas for the deployment. |
| resources | map | `{"limits":{"memory":"400Mi"},"requests":{"cpu":"100m","memory":"100Mi"}}` | Resource requests and limits for the containers in the pod |
| resources.limits | map | `{"memory":"400Mi"}` | The maximum amount of resources that the container is allowed to use |
| resources.limits.memory | string | `"400Mi"` | The maximum amount of memory the container can use |
| resources.requests | map | `{"cpu":"100m","memory":"100Mi"}` | The amount of resources that the container requests |
| resources.requests.cpu | string | `"100m"` | The amount of CPU requested |
| resources.requests.memory | string | `"100Mi"` | The amount of memory requested |
| securityContext | map | `{}` | Container-level security context. |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":8877,"type":"ClusterIP"}` | Kubernetes service information. |
| service.port | int | `8877` | The port number that the service exposes. |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
| serviceAccount | map | `{"annotations":{},"create":true,"name":""}` | Service account to use or create. |
| serviceAccount.annotations | map | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations to use for the deployment. |
| userNamespace | string | `"jupyter-pods"` | Namespace to use for user resources. |
