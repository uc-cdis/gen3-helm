# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 1.4.2](https://img.shields.io/badge/AppVersion-1.4.2-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for deploying ambassador for gen3

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `60` |  |
| fullnameOverride | string | `"ambassador-deployment"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/datawire/ambassador"` |  |
| image.tag | string | `"1.4.2"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations."consul.hashicorp.com/connect-inject" | string | `"false"` |  |
| podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| podAnnotations."prometheus.io/port" | string | `"8877"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podAnnotations."sidecar.istio.io/inject" | string | `"false"` |  |
| podLabels.app | string | `"ambassador"` |  |
| podLabels.netnolimit | string | `"yes"` |  |
| podLabels.public | string | `"yes"` |  |
| podLabels.service | string | `"ambassador"` |  |
| podLabels.userhelper | string | `"yes"` |  |
| podSecurityContext.runAsUser | int | `8888` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"400Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| securityContext | object | `{}` |  |
| selectorLabels.service | string | `"ambassador"` |  |
| service.port | int | `8877` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| userNamespace | string | `"jupyter-pods"` |  |

