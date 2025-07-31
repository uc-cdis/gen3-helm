# neuvector

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

NeuVector Kubernetes Security Policy templates to protect Gen3

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
