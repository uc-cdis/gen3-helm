# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for AWS ES Proxy Service for gen3

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `false` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| esEndpoint | string | `"test.us-east-1.es.amazonaws.com"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/aws-es-proxy"` |  |
| image.tag | string | `""` |  |
| podAnnotations."gen3.io/network-ingress" | string | `"guppy,metadata,spark,tube"` |  |
| ports[0].containerPort | int | `9200` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | int | `1` |  |
| resources.limits.memory | string | `"2Gi"` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| secrets.awsAccessKeyId | string | `"asdpofasdokj"` |  |
| secrets.awsSecretAccessKey | string | `"asdfjkljklj"` |  |
| service.port | int | `9200` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| volumeMounts[0].mountPath | string | `"/root/.aws"` |  |
| volumeMounts[0].name | string | `"credentials"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumes[0].name | string | `"credentials"` |  |
| volumes[0].secret.secretName | string | `"aws-es-proxy"` |  |

