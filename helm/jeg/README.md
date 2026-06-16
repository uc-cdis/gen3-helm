# jeg

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.2.3](https://img.shields.io/badge/AppVersion-3.2.3-informational?style=flat-square)

Jupyter Enterprise Gateway for gen3 vectis workspaces. Launches ephemeral kernel pods in the workspace namespace on behalf of user Jupyter sessions proxied through workspace-proxy.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.34 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| env.EG_AUTH_TOKEN | string | `""` |  |
| env.EG_CULL_CONNECTED | string | `"True"` |  |
| env.EG_CULL_IDLE_TIMEOUT | string | `"14400"` |  |
| env.EG_DEFAULT_KERNEL_NAME | string | `"python3"` |  |
| env.EG_KERNEL_IMAGE_PULL_POLICY | string | `"IfNotPresent"` |  |
| env.EG_KERNEL_LAUNCH_TIMEOUT | string | `"120"` |  |
| env.EG_KERNEL_WHITELIST_ENVS | string | `"ACCESS_TOKEN"` |  |
| env.EG_LIST_KERNELS | string | `"True"` |  |
| env.EG_MAX_KERNELS_PER_USER | string | `"2"` |  |
| env.EG_MIRROR_WORKING_DIRS | string | `"False"` |  |
| env.EG_NAMESPACE | string | `"jupyter-pods"` |  |
| env.EG_SHARED_NAMESPACE | string | `"False"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/gen3-vectis"` |  |
| image.tag | string | `"qa-jeg"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
| workspaceNamespace | string | `"jupyter-pods"` |  |
