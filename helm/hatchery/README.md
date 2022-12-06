# <no value>

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 2022.10](https://img.shields.io/badge/AppVersion-2022.10-informational?style=for-the-badge)

![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Description

A Helm chart for gen3 Hatchery

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| env[0].name | string | `"HTTP_PORT"` |  |
| env[0].value | string | `"8000"` |  |
| env[1].name | string | `"POD_NAMESPACE"` |  |
| env[1].valueFrom.fieldRef.fieldPath | string | `"metadata.namespace"` |  |
| fullnameOverride | string | `""` |  |
| global.aws.account | string | `nil` |  |
| global.aws.enabled | bool | `false` |  |
| global.ddEnabled | bool | `false` |  |
| global.dev | bool | `true` |  |
| global.dictionaryUrl | string | `"https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json"` |  |
| global.dispatcherJobNum | int | `10` |  |
| global.environment | string | `"default"` |  |
| global.hostname | string | `"localhost"` |  |
| global.kubeBucket | string | `"kube-gen3"` |  |
| global.logsBucket | string | `"logs-gen3"` |  |
| global.netPolicy | string | `"on"` |  |
| global.portalApp | string | `"gitops"` |  |
| global.postgres.db_create | bool | `true` |  |
| global.postgres.master.host | string | `nil` |  |
| global.postgres.master.password | string | `nil` |  |
| global.postgres.master.port | string | `"5432"` |  |
| global.postgres.master.username | string | `"postgres"` |  |
| global.publicDataSets | bool | `true` |  |
| global.revproxyArn | string | `"arn:aws:acm:us-east-1:123456:certificate"` |  |
| global.syncFromDbgap | bool | `false` |  |
| global.tierAccessLevel | string | `"libre"` |  |
| global.userYamlS3Path | string | `"s3://cdis-gen3-users/test/user.yaml"` |  |
| hatchery.containers[0].args[0] | string | `"--NotebookApp.base_url=/lw-workspace/proxy/"` |  |
| hatchery.containers[0].args[1] | string | `"--NotebookApp.default_url=/lab"` |  |
| hatchery.containers[0].args[2] | string | `"--NotebookApp.password=''"` |  |
| hatchery.containers[0].args[3] | string | `"--NotebookApp.token=''"` |  |
| hatchery.containers[0].args[4] | string | `"--NotebookApp.shutdown_no_activity_timeout=5400"` |  |
| hatchery.containers[0].args[5] | string | `"--NotebookApp.quit_button=False"` |  |
| hatchery.containers[0].command[0] | string | `"start-notebook.sh"` |  |
| hatchery.containers[0].cpu-limit | string | `"1.0"` |  |
| hatchery.containers[0].env.FRAME_ANCESTORS | string | `"https://{{ .Values.global.hostname }}"` |  |
| hatchery.containers[0].fs-gid | int | `100` |  |
| hatchery.containers[0].gen3-volume-location | string | `"/home/jovyan/.gen3"` |  |
| hatchery.containers[0].image | string | `"quay.io/cdis/heal-notebooks:combined_tutorials__latest"` |  |
| hatchery.containers[0].lifecycle-post-start[0] | string | `"/bin/sh"` |  |
| hatchery.containers[0].lifecycle-post-start[1] | string | `"-c"` |  |
| hatchery.containers[0].lifecycle-post-start[2] | string | `"export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found; ln -s /data /home/$IAM/pd/; true"` |  |
| hatchery.containers[0].memory-limit | string | `"2Gi"` |  |
| hatchery.containers[0].name | string | `"(Tutorials) Example Analysis Jupyter Lab Notebooks"` |  |
| hatchery.containers[0].path-rewrite | string | `"/lw-workspace/proxy/"` |  |
| hatchery.containers[0].ready-probe | string | `"/lw-workspace/proxy/"` |  |
| hatchery.containers[0].target-port | int | `8888` |  |
| hatchery.containers[0].use-tls | string | `"false"` |  |
| hatchery.containers[0].user-uid | int | `1000` |  |
| hatchery.containers[0].user-volume-location | string | `"/home/jovyan/pd"` |  |
| hatchery.sidecarContainer.args | list | `[]` |  |
| hatchery.sidecarContainer.command[0] | string | `"/bin/bash"` |  |
| hatchery.sidecarContainer.command[1] | string | `"./sidecar.sh"` |  |
| hatchery.sidecarContainer.cpu-limit | string | `"1.0"` |  |
| hatchery.sidecarContainer.env.GEN3_ENDPOINT | string | `"{{ .Values.global.hostname }}"` |  |
| hatchery.sidecarContainer.env.HOSTNAME | string | `"{{ .Values.global.hostname }}"` |  |
| hatchery.sidecarContainer.env.NAMESPACE | string | `"{{ .Release.Namespace }}"` |  |
| hatchery.sidecarContainer.image | string | `"quay.io/cdis/ecs-ws-sidecar:master"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[0] | string | `"su"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[1] | string | `"-c"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[2] | string | `"echo test"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[3] | string | `"-s"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[4] | string | `"/bin/sh"` |  |
| hatchery.sidecarContainer.lifecycle-pre-stop[5] | string | `"root"` |  |
| hatchery.sidecarContainer.memory-limit | string | `"256Mi"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/cdis/hatchery"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/hatchery.json"` |  |
| volumeMounts[0].name | string | `"hatchery-config"` |  |
| volumeMounts[0].readOnly | bool | `true` |  |
| volumeMounts[0].subPath | string | `"json"` |  |
| volumes[0].configMap.name | string | `"manifest-hatchery"` |  |
| volumes[0].name | string | `"hatchery-config"` |  |

