# <no value>

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 Dicom Server

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/gen3-orthanc"` |  |
| image.tag | string | `"master"` |  |
| livenessProbe.httpGet.path | string | `"/system"` |  |
| livenessProbe.httpGet.port | int | `8042` |  |
| livenessProbe.initialDelaySeconds | int | `5` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| ports[0].containerPort | int | `8042` |  |
| readinessProbe.httpGet.path | string | `"/system"` |  |
| readinessProbe.httpGet.port | int | `8042` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `20` |  |
| readinessProbe.timeoutSeconds | int | `30` |  |
| replicaCount | int | `1` |  |
| secrets.authenticationEnabled | bool | `false` |  |
| secrets.dataBase | string | `"postgres"` |  |
| secrets.enableIndex | bool | `true` |  |
| secrets.enableStorage | bool | `true` |  |
| secrets.host | string | `"postgres-postgresql.postgres.svc.cluster.local"` |  |
| secrets.indexConnectionsCount | int | `5` |  |
| secrets.lock | bool | `false` |  |
| secrets.password | string | `"postgres"` |  |
| secrets.port | string | `"5432"` |  |
| secrets.userName | string | `"postgres"` |  |
| service.port | int | `80` |  |
| service.targetport | int | `8042` |  |
| volumeMounts[0].mountPath | string | `"/etc/orthanc/orthanc_config_overwrites.json"` |  |
| volumeMounts[0].name | string | `"config-volume-g3auto"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"orthanc_config_overwrites.json"` |  |
| volumes[0].name | string | `"config-volume-g3auto"` |  |
| volumes[0].secret.secretName | string | `"orthanc-g3auto"` |  |

