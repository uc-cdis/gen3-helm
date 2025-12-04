<<<<<<< HEAD
# ohdsi-atlas

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.15.0](https://img.shields.io/badge/AppVersion-2.15.0-informational?style=flat-square)

A Helm chart for OHDSI Atlas

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
| service.type | string | `"ClusterIP"` |  |
=======
# Steps to test this Atlas chart locally

1. Start a WebAPI backend (see also ../ohdsi-webapi for a WebAPI helm chart)
3. Install this Atlas chart with:
```
helm install my-atlas-release . 
```
OR for developing and testing locally:
```
helm install my-atlas-release . --values ./values_local.yaml
```
4. Forward internal port 80 to 8889:
kubectl port-forward svc/ohdsi-atlas-service 8889:80


5. Browse to http://localhost:8889/atlas/
>>>>>>> 76517a99 (feat: add ohdsi-atlas and ohdsi-webapi helm charts)
