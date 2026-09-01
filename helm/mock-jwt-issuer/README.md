# mock-jwt-issuer

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.12-alpine](https://img.shields.io/badge/AppVersion-3.12--alpine-informational?style=flat-square)

A test-only OIDC-ish issuer that serves the public half of fence's JWT signing
key. Useful for exercising token exchange / GA4GH passport flows without a real
external IdP: sign a token with fence's private key and point the consumer at
this service as the issuer.

Published versions of this chart are listed in the
[Helm repository](https://helm.gen3.org) (`helm search repo gen3`) and on the
[releases page](https://github.com/uc-cdis/gen3-helm/releases).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| alg | string | `"RS256"` | `alg` advertised in the JWKS. |
| containerPort | int | `8080` | Port the server listens on inside the pod. |
| fullnameOverride | string | `""` | Name used for the Deployment/Service/ConfigMap. Defaults to the chart name so the in-cluster DNS name (and therefore the issuer URL) is stable and does not depend on the release name. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"python"` |  |
| image.tag | string | `"3.12-alpine"` |  |
| issuer | string | `""` | The `iss` value this server advertises, and the base URL it builds `jwks_uri` from. Leave empty to use `http://<fullname>.<namespace>.svc.cluster.local`, which matches the Service below when `service.port` is 80. |
| jwtKeys.existingSecret | string | `"fence-jwt-keys"` | Name of an existing secret holding the RSA private key. Defaults to the secret the fence chart creates, so this chart serves exactly the key fence signs with. |
| jwtKeys.existingSecretKey | string | `"jwt_private_key.pem"` | Key within that secret containing the PEM private key. |
| jwtKeys.privateKey | string | `""` | Inline PEM private key (PKCS#1 or PKCS#8 RSA). If set, this chart creates its own secret and ignores `existingSecret`. Only the public half is ever served. |
| kid | string | `"test-kid-01"` | Key ID advertised in the JWKS. Tokens you mint must carry this `kid` in their header. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels.netnolimit | string | `"yes"` |  |
| podLabels.public | string | `"yes"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| service.port | int | `80` | Service port. Keep this at 80 so the issuer URL needs no port suffix. |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |
