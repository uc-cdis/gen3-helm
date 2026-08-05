# workspace-proxy

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Per-user workspace HTTP/WebSocket router for gen3 vectis. Replaces Emissary/Ambassador. Reads Service annotations written by Hatchery to resolve each user's workspace upstream, then proxies traffic from revproxy.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.34 |

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
