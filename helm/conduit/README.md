# conduit

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for the Conduit tunnel broker (server)

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
| affinity | map | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchLabels":{"app":"conduit"}},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity to use for the deployment. |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `[]` | Environment variables to pass to the container |
| extraVolumeMounts | list | `[]` | Extra volume mounts for the container. |
| extraVolumes | list | `[]` | Extra volumes for the pod. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.hostname | string | `"localhost"` | Hostname for the deployment. |
| global.metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| global.minAvailable | int | `1` | The minimum amount of pods that are available at all times if the PDB is deployed. |
| global.netPolicy | map | `{"enabled":false}` | Controls network policy settings |
| global.pdb | bool | `false` | If the service will be deployed with a Pod Disruption Budget. Note- you need to have more than 2 replicas for the pdb to be deployed. |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| grpcLoadBalancer | map | `{"allowedCIDRs":["0.0.0.0/0"],"annotations":{},"enabled":false,"hostname":"","loadBalancerSourceRanges":[],"port":443}` | LoadBalancer Service for remote agents. Must be an L4 passthrough (agents use mTLS). |
| grpcLoadBalancer.allowedCIDRs | list | `["0.0.0.0/0"]` | CIDRs allowed to reach the gRPC port when global.netPolicy.enabled is true. |
| grpcLoadBalancer.annotations | map | `{}` | Annotations for the Service, e.g. for an AWS NLB: service.beta.kubernetes.io/aws-load-balancer-type: "nlb" service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" |
| grpcLoadBalancer.enabled | bool | `false` | Create the gRPC LoadBalancer Service. |
| grpcLoadBalancer.hostname | string | `""` | DNS name agents dial. Added to the server certificate SANs. |
| grpcLoadBalancer.loadBalancerSourceRanges | list | `[]` | Restrict client source ranges on the load balancer. |
| grpcLoadBalancer.port | int | `443` | Port the load balancer listens on. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/conduit-server"` | The Docker image repository for the conduit server. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| ingress | map | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | Optional dedicated Ingress for tunnel HTTP traffic. Not needed when routing through revproxy. |
| leaderElection | map | `{"enabled":true,"leaseDuration":"10s","lockName":"conduit-server-leader","podLabelKey":"conduit-role","podLabelValue":"active","renewDeadline":"6s","retryPeriod":"2s"}` | Leader election. Only the lease holder is labelled active and receives traffic. |
| leaderElection.enabled | bool | `true` | Enable leader election. Required when replicaCount > 1. |
| leaderElection.leaseDuration | string | `"10s"` | Lease duration. |
| leaderElection.lockName | string | `"conduit-server-leader"` | Name of the Lease object. |
| leaderElection.podLabelKey | string | `"conduit-role"` | Label key the leader sets on its own pod. |
| leaderElection.podLabelValue | string | `"active"` | Label value the leader sets on its own pod. |
| leaderElection.renewDeadline | string | `"6s"` | Renew deadline. |
| leaderElection.retryPeriod | string | `"2s"` | Retry period. |
| livenessProbe | map | `{"httpGet":{"path":"/healthz","port":"admin"},"initialDelaySeconds":10,"periodSeconds":30}` | Liveness probe. |
| logLevel | string | `"info"` | Server log level: debug, info, warn, or error. |
| metricsEnabled | bool | `nil` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. |
| partOf | string | `"Conduit"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| ports | map | `{"admin":9090,"grpc":8443,"http":8080}` | Container ports. Rendered into the listen addresses in server.json. |
| ports.admin | int | `9090` | Admin API, UI, health and metrics. Serves agent private keys; keep it in-cluster. |
| ports.grpc | int | `8443` | mTLS gRPC listener that agents connect to. |
| ports.http | int | `8080` | Public HTTP listener that proxies requests into agent tunnels. |
| readinessProbe | map | `{"httpGet":{"path":"/readyz","port":"admin"},"initialDelaySeconds":5,"periodSeconds":10}` | Readiness probe. Standby replicas report ready too. |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `2` | Number of server replicas. With leader election only one replica is active; the rest are hot standbys. |
| resources | map | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource requests and limits for the container |
| revisionHistoryLimit | int | `2` | Number of old revisions to retain |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| serverConfig | map | `{"allowed_agent_ids":[],"chunk_bytes":65536,"default_timeout":"30s","max_concurrent":1000,"routes":[{"path_prefix":"/conduit/","route_id":"default","route_mode":"path_agent","strip_prefix":true,"timeout":"30s"}],"server_names":[]}` | Passed through to server.json (snake_case keys, see conduit internal/config). http_addr, grpc_addr, admin_addr, cert_backend, kubernetes and leader_election are set by the chart and cannot be overridden here. server_names entries are appended to the in-cluster service names. |
| serverConfig.allowed_agent_ids | list | `[]` | Restrict which agent IDs may connect. Empty allows any agent with a valid cert. |
| serverConfig.routes | list | `[{"path_prefix":"/conduit/","route_id":"default","route_mode":"path_agent","strip_prefix":true,"timeout":"30s"}]` | Routes from public HTTP requests to agent tunnels. At least one is required. |
| serverConfig.server_names | list | `[]` | Extra DNS names / IPs added to the auto-generated server certificate SANs. |
| service.httpPort | int | `80` | Port conduit-service exposes for tunnel HTTP traffic (revproxy targets this). |
| serviceAccount.annotations | map | `{}` | Service account annotations. |
| serviceAccount.create | bool | `true` | Create the service account. |
| serviceAccount.name | string | `""` | Service account name. Defaults to conduit-server. |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| terminationGracePeriodSeconds | int | `30` | Should exceed the server's shutdown_grace (default 15s). |
