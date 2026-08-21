# ohdsi-atlas

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.15.0](https://img.shields.io/badge/AppVersion-2.15.0-informational?style=flat-square)

A Helm chart for OHDSI Atlas

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.hostname | string | `""` |  |
| global.webapiHost | string | `""` | URL for the WebAPI, e.g. "https://atlas.mywebapi.com" |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"quay.io/cdis/ohdsi-atlas"` |  |
| image.tag | string | `"2.15.0-DEV"` |  |
| replicaCount | int | `1` |  |
| service.port | int | `80` |  |
| service.targetPort | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
