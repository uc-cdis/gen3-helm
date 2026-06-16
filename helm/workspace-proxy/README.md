# workspace-proxy

![Version: 0.1.5](https://img.shields.io/badge/Version-0.1.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.15.0](https://img.shields.io/badge/AppVersion-2.15.0-informational?style=flat-square)

Per-user workspace HTTP/WebSocket router for gen3 vectis.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.36 |

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
