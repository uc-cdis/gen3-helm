# neuvector

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

NeuVector Kubernetes Security Policy templates to protect Gen3

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ARGOCD_PREFIX | string | `"development-gen3"` |  |
| DB_HOST | string | `"development-gen3-postgresql"` |  |
| ES_HOST | string | `"gen3-elasticsearch-master"` |  |
| fullnameOverride | string | `""` |  |
| ingress.class | string | `"nginx"` |  |
| ingress.controller | string | `"nginx-ingress-controller"` |  |
| ingress.namespace | string | `"nginx"` |  |
| nameOverride | string | `""` |  |
| policies.include | bool | `true` |  |
| policies.policyMode | string | `"Monitor"` |  |
