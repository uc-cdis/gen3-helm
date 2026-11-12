# workspace-proxy

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Per-user workspace HTTP/WebSocket router for gen3 vectis. Replaces Emissary/Ambassador. Reads Service annotations written by Hatchery to resolve each user's workspace upstream, then proxies traffic from revproxy.

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Requirements

| Repository | Name |
|------------|------|
| file://../common | common |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deploymentNamespace | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/gen3-vectis"` |  |
| image.tag | string | `"qa-goproxy"` |  |
| jegKernelSpecPolicy | string | `""` |  |
| kubernetesApiServerCIDRs | list | `[]` |  |
| listenAddr | string | `":8080"` |  |
| networkPolicy.enabled | bool | `true` |  |
| replicaCount | int | `2` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| workspaceNamespace | string | `""` |  |
