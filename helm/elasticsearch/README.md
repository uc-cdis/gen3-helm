# elasticsearch

![Version: 7.10.3-SNAPSHOT](https://img.shields.io/badge/Version-7.10.3--SNAPSHOT-informational?style=flat-square) ![AppVersion: 7.10.3-SNAPSHOT](https://img.shields.io/badge/AppVersion-7.10.3--SNAPSHOT-informational?style=flat-square)

Official Elastic helm chart for Elasticsearch

**Homepage:** <https://github.com/elastic/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Elastic | <helm-charts@elastic.co> |  |

## Source Code

* <https://github.com/elastic/elasticsearch>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| antiAffinity | string | `"hard"` |  |
| antiAffinityTopologyKey | string | `"kubernetes.io/hostname"` |  |
| clusterHealthCheckParams | string | `"wait_for_status=green&timeout=1s"` |  |
| clusterName | string | `"elasticsearch"` |  |
| enableServiceLinks | bool | `true` |  |
| envFrom | list | `[]` |  |
| esConfig | object | `{}` |  |
| esJavaOpts | string | `"-Xmx1g -Xms1g"` |  |
| esMajorVersion | string | `""` |  |
| extraContainers | list | `[]` |  |
| extraEnvs | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fsGroup | string | `""` |  |
| fullnameOverride | string | `""` |  |
| hostAliases | list | `[]` |  |
| httpPort | int | `9200` |  |
| image | string | `"docker.elastic.co/elasticsearch/elasticsearch"` |  |
| imagePullPolicy | string | `"IfNotPresent"` |  |
| imagePullSecrets | list | `[]` |  |
| imageTag | string | `"7.10.3-SNAPSHOT"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0] | string | `"chart-example.local"` |  |
| ingress.path | string | `"/"` |  |
| ingress.tls | list | `[]` |  |
| initResources | object | `{}` |  |
| keystore | list | `[]` |  |
| labels | object | `{}` |  |
| lifecycle | object | `{}` |  |
| masterService | string | `""` |  |
| masterTerminationFix | bool | `false` |  |
| maxUnavailable | int | `1` |  |
| minimumMasterNodes | int | `2` |  |
| nameOverride | string | `""` |  |
| networkHost | string | `"0.0.0.0"` |  |
| nodeAffinity | object | `{}` |  |
| nodeGroup | string | `"master"` |  |
| nodeSelector | object | `{}` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.labels.enabled | bool | `false` |  |
| podAnnotations | object | `{}` |  |
| podManagementPolicy | string | `"Parallel"` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| podSecurityPolicy.create | bool | `false` |  |
| podSecurityPolicy.name | string | `""` |  |
| podSecurityPolicy.spec.fsGroup.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.privileged | bool | `true` |  |
| podSecurityPolicy.spec.runAsUser.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.seLinux.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.supplementalGroups.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.volumes[0] | string | `"secret"` |  |
| podSecurityPolicy.spec.volumes[1] | string | `"configMap"` |  |
| podSecurityPolicy.spec.volumes[2] | string | `"persistentVolumeClaim"` |  |
| podSecurityPolicy.spec.volumes[3] | string | `"emptyDir"` |  |
| priorityClassName | string | `""` |  |
| protocol | string | `"http"` |  |
| rbac.create | bool | `false` |  |
| rbac.serviceAccountAnnotations | object | `{}` |  |
| rbac.serviceAccountName | string | `""` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `3` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicas | int | `3` |  |
| resources.limits.cpu | string | `"1000m"` |  |
| resources.limits.memory | string | `"2Gi"` |  |
| resources.requests.cpu | string | `"1000m"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| roles.data | string | `"true"` |  |
| roles.ingest | string | `"true"` |  |
| roles.master | string | `"true"` |  |
| roles.remote_cluster_client | string | `"true"` |  |
| schedulerName | string | `""` |  |
| secretMounts | list | `[]` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.httpPortName | string | `"http"` |  |
| service.labels | object | `{}` |  |
| service.labelsHeadless | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.nodePort | string | `""` |  |
| service.transportPortName | string | `"transport"` |  |
| service.type | string | `"ClusterIP"` |  |
| sidecarResources | object | `{}` |  |
| sysctlInitContainer.enabled | bool | `true` |  |
| sysctlVmMaxMapCount | int | `262144` |  |
| terminationGracePeriod | int | `120` |  |
| tolerations | list | `[]` |  |
| transportPort | int | `9300` |  |
| updateStrategy | string | `"RollingUpdate"` |  |
| volumeClaimTemplate.accessModes[0] | string | `"ReadWriteOnce"` |  |
| volumeClaimTemplate.resources.requests.storage | string | `"30Gi"` |  |
