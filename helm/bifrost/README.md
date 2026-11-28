# ai-gateway

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

CTDS unified AI gateway. Deploys Bifrost, Headroom (token compression),
the reversible redactor plugin sidecars (Presidio + detect-secrets +
Redis vault), the admin-API façade, and the org-standards MCP server.

All workload images are CTDS-built on the hardened AL2023 base.

**Homepage:** <https://github.com/uc-cdis/ctds-ai-gateway>

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CTDS Platform | <platform@ctds.uchicago.edu> |  |

## Source Code

* <https://github.com/uc-cdis/ctds-ai-gateway>

## Requirements

| Repository | Name |
|------------|------|
| https://charts.bitnami.com/bitnami | postgresql |
| https://charts.bitnami.com/bitnami | redis |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminApi.allowedProviders[0] | string | `"bedrock/anthropic.claude-haiku-4-5-20251001-v1:0"` |  |
| adminApi.allowedProviders[1] | string | `"bedrock/anthropic.claude-opus-4-6-v1"` |  |
| adminApi.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| adminApi.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| adminApi.autoscaling.behavior.scaleDown.policy.value | int | `30` |  |
| adminApi.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| adminApi.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| adminApi.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| adminApi.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| adminApi.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| adminApi.autoscaling.enabled | bool | `false` |  |
| adminApi.autoscaling.maxReplicas | int | `6` |  |
| adminApi.autoscaling.minReplicas | int | `2` |  |
| adminApi.autoscaling.targetCPUUtilizationPercentage | int | `70` |  |
| adminApi.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| adminApi.bearerTokenSecret.key | string | `"token"` |  |
| adminApi.bearerTokenSecret.name | string | `"ai-gateway-admin-token"` |  |
| adminApi.enabled | bool | `true` |  |
| adminApi.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| adminApi.image.tag | string | `"ai-gateway-admin-api-0.1.9"` |  |
| adminApi.podDisruptionBudget.enabled | bool | `true` |  |
| adminApi.podDisruptionBudget.minAvailable | int | `1` |  |
| adminApi.replicaCount | int | `2` |  |
| adminApi.service.port | int | `8090` |  |
| adminApi.service.type | string | `"ClusterIP"` |  |
| adminApi.tierBudgetDefaults.admin | string | `"60:8:15000"` |  |
| adminApi.tierBudgetDefaults.default | string | `"50:6:10000"` |  |
| adminApi.tierBudgetDefaults.researcher | string | `"90:12:24000"` |  |
| adminApi.tierBudgetDefaults.staff | string | `"120:15:30000"` |  |
| autoRouter.dryRun | bool | `false` |  |
| autoRouter.enabled | bool | `false` |  |
| autoRouter.hardStopAtCap | bool | `true` |  |
| autoRouter.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| autoRouter.image.tag | string | `"ai-gateway-auto-router-0.1.1"` |  |
| autoRouter.models.balanced[0] | string | `"bedrock/anthropic.claude-sonnet-4-v1"` |  |
| autoRouter.models.balanced[1] | string | `"vertex/gemini-1.5-flash"` |  |
| autoRouter.models.cheap[0] | string | `"bedrock/anthropic.claude-haiku-3-5-v1"` |  |
| autoRouter.models.cheap[1] | string | `"bedrock/meta.llama3-70b-instruct-v1"` |  |
| autoRouter.models.onprem[0] | string | `"kserve/qwen2.5-32b-onprem"` |  |
| autoRouter.models.onprem[1] | string | `"onprem_openai/qwen2.5-coder-32b-instruct"` |  |
| autoRouter.models.premium[0] | string | `"bedrock/anthropic.claude-opus-4-6-v1"` |  |
| autoRouter.models.premium[1] | string | `"vertex/gemini-1.5-pro"` |  |
| autoRouter.orgBudgetLimitUsd | int | `200` |  |
| autoRouter.pollSeconds | int | `60` |  |
| autoRouter.replicaCount | int | `1` |  |
| autoRouter.routingPatchPathTemplate | string | `"/v1/keys/by-email/{email}/routing"` |  |
| autoRouter.service.port | int | `8093` |  |
| autoRouter.service.type | string | `"ClusterIP"` |  |
| autoRouter.thresholds.stage1 | float | `0.6` |  |
| autoRouter.thresholds.stage2 | float | `0.85` |  |
| autoRouter.thresholds.stage3 | float | `1` |  |
| bifrost.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| bifrost.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| bifrost.autoscaling.behavior.scaleDown.policy.value | int | `30` |  |
| bifrost.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| bifrost.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| bifrost.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| bifrost.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| bifrost.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| bifrost.autoscaling.enabled | bool | `true` |  |
| bifrost.autoscaling.maxReplicas | int | `8` |  |
| bifrost.autoscaling.minReplicas | int | `2` |  |
| bifrost.autoscaling.targetCPUUtilizationPercentage | int | `70` |  |
| bifrost.autoscaling.targetMemoryUtilizationPercentage | int | `75` |  |
| bifrost.config.enableTelemetry | bool | `true` |  |
| bifrost.config.logLevel | string | `"info"` |  |
| bifrost.config.plugins[0].endpoint | string | `"http://ai-gateway-redactor:9090"` |  |
| bifrost.config.plugins[0].failOpen | bool | `false` |  |
| bifrost.config.plugins[0].name | string | `"redactor"` |  |
| bifrost.config.plugins[0].timeoutMs | int | `1500` |  |
| bifrost.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| bifrost.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| bifrost.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| bifrost.enabled | bool | `true` |  |
| bifrost.image.pullPolicy | string | `"IfNotPresent"` |  |
| bifrost.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| bifrost.image.tag | string | `"ai-gateway-bifrost-0.1.0"` |  |
| bifrost.podDisruptionBudget.enabled | bool | `true` |  |
| bifrost.podDisruptionBudget.minAvailable | int | `1` |  |
| bifrost.podSecurityContext.fsGroup | int | `10001` |  |
| bifrost.podSecurityContext.runAsGroup | int | `10001` |  |
| bifrost.podSecurityContext.runAsNonRoot | bool | `true` |  |
| bifrost.podSecurityContext.runAsUser | int | `10001` |  |
| bifrost.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| bifrost.providers.bedrock.aliases | object | `{}` |  |
| bifrost.providers.bedrock.authMode | string | `"irsa"` |  |
| bifrost.providers.bedrock.enabled | bool | `false` |  |
| bifrost.providers.bedrock.keyName | string | `"bedrock-iam"` |  |
| bifrost.providers.bedrock.models[0] | string | `"anthropic.claude-haiku-3-5-v1"` |  |
| bifrost.providers.bedrock.models[1] | string | `"anthropic.claude-sonnet-4-v1"` |  |
| bifrost.providers.bedrock.region | string | `"us-east-1"` |  |
| bifrost.providers.kserve.enabled | bool | `false` |  |
| bifrost.providers.kserve.services | list | `[]` |  |
| bifrost.providers.onpremOpenAI.authMode | string | `"none"` |  |
| bifrost.providers.onpremOpenAI.enabled | bool | `false` |  |
| bifrost.providers.onpremOpenAI.endpoint | string | `""` |  |
| bifrost.providers.onpremOpenAI.models[0] | string | `"qwen2.5-coder-32b-instruct"` |  |
| bifrost.providers.productShim.enabled | bool | `false` |  |
| bifrost.providers.vertex.authMode | string | `"workload_identity_federation"` |  |
| bifrost.providers.vertex.enabled | bool | `false` |  |
| bifrost.providers.vertex.location | string | `"us-central1"` |  |
| bifrost.providers.vertex.models[0] | string | `"gemini-1.5-flash"` |  |
| bifrost.providers.vertex.project | string | `""` |  |
| bifrost.replicaCount | int | `2` |  |
| bifrost.resources.limits.cpu | string | `"2"` |  |
| bifrost.resources.limits.memory | string | `"2Gi"` |  |
| bifrost.resources.requests.cpu | string | `"250m"` |  |
| bifrost.resources.requests.memory | string | `"512Mi"` |  |
| bifrost.service.port | int | `8080` |  |
| bifrost.service.type | string | `"ClusterIP"` |  |
| global.hardenedBaseDigest | string | `""` |  |
| global.imagePullSecrets[0].name | string | `"quay-pull"` |  |
| global.imageRegistry | string | `"quay.io/cdis"` |  |
| headroom.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| headroom.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| headroom.autoscaling.behavior.scaleDown.policy.value | int | `30` |  |
| headroom.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| headroom.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| headroom.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| headroom.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| headroom.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| headroom.autoscaling.enabled | bool | `true` |  |
| headroom.autoscaling.maxReplicas | int | `10` |  |
| headroom.autoscaling.minReplicas | int | `2` |  |
| headroom.autoscaling.targetCPUUtilizationPercentage | int | `65` |  |
| headroom.autoscaling.targetMemoryUtilizationPercentage | int | `75` |  |
| headroom.enabled | bool | `true` |  |
| headroom.extraEnv | list | `[]` |  |
| headroom.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| headroom.image.tag | string | `"ai-gateway-headroom-0.1.3"` |  |
| headroom.openaiTargetUrl | string | `"http://ai-gateway-bifrost:8080/v1"` |  |
| headroom.podDisruptionBudget.enabled | bool | `true` |  |
| headroom.podDisruptionBudget.minAvailable | int | `1` |  |
| headroom.replicaCount | int | `2` |  |
| headroom.resources.limits.cpu | string | `"2"` |  |
| headroom.resources.limits.memory | string | `"2Gi"` |  |
| headroom.resources.requests.cpu | string | `"250m"` |  |
| headroom.resources.requests.memory | string | `"512Mi"` |  |
| headroom.service.port | int | `8081` |  |
| headroom.service.type | string | `"ClusterIP"` |  |
| headroom.upstreamUrl | string | `"http://ai-gateway-bifrost:8080"` |  |
| ingress.className | string | `"alb"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"ai-gw.staff-portal.io"` |  |
| ingress.hosts[0].paths[0].path | string | `"/v1"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.hosts[0].paths[0].service | string | `"headroom"` |  |
| ingress.hosts[0].paths[1].path | string | `"/admin"` |  |
| ingress.hosts[0].paths[1].pathType | string | `"Prefix"` |  |
| ingress.hosts[0].paths[1].service | string | `"adminApi"` |  |
| ingress.tls | list | `[]` |  |
| metrics.enabled | bool | `true` |  |
| metrics.serviceMonitor.enabled | bool | `true` |  |
| metrics.serviceMonitor.interval | string | `"30s"` |  |
| metrics.serviceMonitor.labels | object | `{}` |  |
| networkPolicy.allowDns | bool | `true` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.externalEgressCidrs[0] | string | `"0.0.0.0/0"` |  |
| networkPolicy.externalEgressPorts[0] | int | `443` |  |
| networkPolicy.extraIngressNamespaceSelectors | list | `[]` |  |
| orgStandardsMcp.cacheTtlSeconds | int | `300` |  |
| orgStandardsMcp.enabled | bool | `true` |  |
| orgStandardsMcp.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| orgStandardsMcp.image.tag | string | `"ai-gateway-org-standards-mcp-0.1.0"` |  |
| orgStandardsMcp.replicaCount | int | `2` |  |
| orgStandardsMcp.service.port | int | `8092` |  |
| orgStandardsMcp.service.type | string | `"ClusterIP"` |  |
| orgStandardsMcp.standardsRepo | string | `"https://github.com/uc-cdis/ctds-agent-standards"` |  |
| redactor.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| redactor.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| redactor.autoscaling.behavior.scaleDown.policy.value | int | `30` |  |
| redactor.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| redactor.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| redactor.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| redactor.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| redactor.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| redactor.autoscaling.enabled | bool | `true` |  |
| redactor.autoscaling.maxReplicas | int | `12` |  |
| redactor.autoscaling.minReplicas | int | `3` |  |
| redactor.autoscaling.targetCPUUtilizationPercentage | int | `65` |  |
| redactor.autoscaling.targetMemoryUtilizationPercentage | int | `75` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleDown.policy.value | int | `30` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| redactor.detectSecrets.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| redactor.detectSecrets.autoscaling.enabled | bool | `false` |  |
| redactor.detectSecrets.autoscaling.maxReplicas | int | `6` |  |
| redactor.detectSecrets.autoscaling.minReplicas | int | `2` |  |
| redactor.detectSecrets.autoscaling.targetCPUUtilizationPercentage | int | `70` |  |
| redactor.detectSecrets.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| redactor.detectSecrets.enabled | bool | `true` |  |
| redactor.detectSecrets.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| redactor.detectSecrets.image.tag | string | `"ai-gateway-detect-secrets-0.1.0"` |  |
| redactor.detectSecrets.podDisruptionBudget.enabled | bool | `false` |  |
| redactor.detectSecrets.podDisruptionBudget.minAvailable | int | `1` |  |
| redactor.detectSecrets.port | int | `5002` |  |
| redactor.detectSecrets.replicaCount | int | `2` |  |
| redactor.detectSecrets.resources.limits.cpu | string | `"1"` |  |
| redactor.detectSecrets.resources.limits.memory | string | `"512Mi"` |  |
| redactor.detectSecrets.resources.requests.cpu | string | `"100m"` |  |
| redactor.detectSecrets.resources.requests.memory | string | `"128Mi"` |  |
| redactor.detectSecrets.service.port | int | `5002` |  |
| redactor.detectSecrets.service.type | string | `"ClusterIP"` |  |
| redactor.enabled | bool | `true` |  |
| redactor.failOpen | bool | `false` |  |
| redactor.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| redactor.image.tag | string | `"ai-gateway-redactor-0.1.0"` |  |
| redactor.podDisruptionBudget.enabled | bool | `true` |  |
| redactor.podDisruptionBudget.minAvailable | int | `2` |  |
| redactor.port | int | `9090` |  |
| redactor.presidio.autoscaling.behavior.scaleDown.policy.periodSeconds | int | `60` |  |
| redactor.presidio.autoscaling.behavior.scaleDown.policy.type | string | `"Percent"` |  |
| redactor.presidio.autoscaling.behavior.scaleDown.policy.value | int | `25` |  |
| redactor.presidio.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| redactor.presidio.autoscaling.behavior.scaleUp.policy.periodSeconds | int | `60` |  |
| redactor.presidio.autoscaling.behavior.scaleUp.policy.type | string | `"Percent"` |  |
| redactor.presidio.autoscaling.behavior.scaleUp.policy.value | int | `100` |  |
| redactor.presidio.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `0` |  |
| redactor.presidio.autoscaling.enabled | bool | `true` |  |
| redactor.presidio.autoscaling.maxReplicas | int | `8` |  |
| redactor.presidio.autoscaling.minReplicas | int | `2` |  |
| redactor.presidio.autoscaling.targetCPUUtilizationPercentage | int | `70` |  |
| redactor.presidio.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| redactor.presidio.enabled | bool | `true` |  |
| redactor.presidio.image.repository | string | `"quay.io/cdis/ctds-ai-gateway"` |  |
| redactor.presidio.image.tag | string | `"ai-gateway-presidio-0.1.0-amd64"` |  |
| redactor.presidio.podDisruptionBudget.enabled | bool | `true` |  |
| redactor.presidio.podDisruptionBudget.minAvailable | int | `1` |  |
| redactor.presidio.port | int | `5001` |  |
| redactor.presidio.replicaCount | int | `2` |  |
| redactor.presidio.resources.limits.cpu | string | `"4"` |  |
| redactor.presidio.resources.limits.memory | string | `"8Gi"` |  |
| redactor.presidio.resources.requests.cpu | string | `"500m"` |  |
| redactor.presidio.resources.requests.memory | string | `"2Gi"` |  |
| redactor.presidio.service.port | int | `5001` |  |
| redactor.presidio.service.type | string | `"ClusterIP"` |  |
| redactor.replicaCount | int | `3` |  |
| redactor.resources.limits.cpu | string | `"2"` |  |
| redactor.resources.limits.memory | string | `"2Gi"` |  |
| redactor.resources.requests.cpu | string | `"250m"` |  |
| redactor.resources.requests.memory | string | `"512Mi"` |  |
| redactor.service.port | int | `9090` |  |
| redactor.service.type | string | `"ClusterIP"` |  |
| redactor.vault.redisAddr | string | `"ai-gateway-redis-master:6379"` |  |
| redactor.vault.ttlSeconds | int | `900` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"ai-gateway-bifrost"` |  |
