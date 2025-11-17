# gen3-workflow

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
![Version: 0.1.18](https://img.shields.io/badge/Version-0.1.18-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
=======
![Version: 0.1.11](https://img.shields.io/badge/Version-0.1.11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 10573193 (Update funnel to 0.1.53 and update netpols accordingly)
=======
![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> d0be3cc5 (Update versions to meet with Lint changes)
=======
![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> 9cc23438 (Update PV Template in funnel to add flags to csi driver config)
=======
![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)
>>>>>>> d89729c9 (Update Gen3Workflow secrets to include EKS cluster variables)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
| file://../common | common | 0.1.34 |
=======
| file://../common | common | 0.1.20 |
| file://../funnel | funnel | 0.1.50 |
>>>>>>> ac9ee302 (Add useryaml, update funnel secrets, add funnel local chart reference)
=======
| file://../common | common | 0.1.23 |
=======
| file://../common | common | 0.1.24 |
>>>>>>> f57d39fd (Update common chart version across the board)
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.53 |
>>>>>>> 10573193 (Update funnel to 0.1.53 and update netpols accordingly)
=======
| file://../common | common | 0.1.25 |
=======
| file://../common | common | 0.1.24 |
>>>>>>> dabe938c (Revert "Update version of common and gen3 charts")
=======
| file://../common | common | 0.1.25 |
>>>>>>> d0be3cc5 (Update versions to meet with Lint changes)
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.56 |
>>>>>>> 950b51ce (Update version of common and gen3 charts)
=======
| file://../common | common | 0.1.26 |
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.58 |
>>>>>>> 14bf12cf ( Setup PushSecret for DB init (#433))

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | map | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100},{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}]},"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}]}}` | Affinity to use for the deployment. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100},{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}]` | Option for scheduling to be required or preferred. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]},"weight":100}` | Weight value for preferred scheduling. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions | list | `[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]` | Label key for match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].values | list | `["spot"]` | Value for the match expression key. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1] | int | `{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]},"weight":99}` | Weight value for preferred scheduling. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions | list | `[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["SPOT"]}]` | Label key for match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].preference.matchExpressions[0].values | list | `["SPOT"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | map | `[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}]` | Option for scheduling to be required or preferred. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0] | int | `{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["gen3-workflow"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":25}` | Weight value for preferred scheduling. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0] | list | `{"key":"app","operator":"In","values":["gen3-workflow"]}` | Label key for match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` | Operation type for the match expression. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values | list | `["gen3-workflow"]` | Value for the match expression key. |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` | Value for topology key label. |
| automountServiceAccountToken | bool | `false` | Automount the default service account token |
| autoscaling | map | `{"enabled":false,"maxReplicas":4,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Configuration for autoscaling the number of replicas |
| autoscaling.enabled | bool | `false` | Whether autoscaling is enabled or not |
| autoscaling.maxReplicas | int | `4` | The maximum number of replicas to scale up to |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas to scale down to |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The target CPU utilization percentage for autoscaling |
| commonLabels | map | `nil` | Will completely override the commonLabels defined in the common chart's _label_setup.tpl |
| criticalService | string | `"false"` | Valid options are "true" or "false". If invalid option is set- the value will default to "false". |
| env | list | `[{"name":"DEBUG","value":"false"},{"name":"ARBORIST_URL","valueFrom":{"configMapKeyRef":{"key":"arborist_url","name":"manifest-global","optional":true}}}]` | Environment variables to pass to the container |
<<<<<<< HEAD
| externalSecrets | map | `{"createK8sGen3WorkflowSecret":true,"gen3workflowG3auto":""}` | External Secrets settings. |
| externalSecrets.createK8sGen3WorkflowSecret | string | `true` | Will create the Helm "gen3workflow-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
=======
| externalSecrets | map | `{"createFunnelOidcClientSecret":true,"createK8sGen3WorkflowSecret":false,"dbcreds":"","funnelOidcClient":null,"gen3workflowG3auto":""}` | External Secrets settings. |
| externalSecrets.createFunnelOidcClientSecret | bool | `true` | Whether to create the Funnel OIDC client secret using the oidc job. |
| externalSecrets.createK8sGen3WorkflowSecret | string | `false` | Will create the Helm "gen3workflow-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.dbcreds | string | `""` | Will override the name of the aws secrets manager secret. Default is "Values.global.environment-.Chart.Name-creds" |
| externalSecrets.funnelOidcClient | string | `nil` | Will override the name of the aws secrets manager secret. Default is "funnel-oidc-client". |
>>>>>>> af36d0cd (Updating all dependent charts to pass lint tests)
| externalSecrets.gen3workflowG3auto | string | `""` | Will override the name of the aws secrets manager secret. Default is "gen3workflow-g3auto" |
| extraLabels | map | `{"dbgen3workflow":"yes","netnolimit":"yes","public":"yes"}` | Will completely override the extraLabels defined in the common chart's _label_setup.tpl |
| fullnameOverride | string | `""` | Override the full name of the chart, which is used as the name of resources created by the chart |
<<<<<<< HEAD
<<<<<<< HEAD
| gen3WorkflowConfig.arboristUrl | string | `""` | Custom Arborist URL. Ignored if already set via environment variable. |
| gen3WorkflowConfig.debug | bool | `false` | Enables debug mode for the application. |
| gen3WorkflowConfig.enableOptimizedNodeScheduling | bool | `true` | When enabled, jobs are configured to run on specific nodes through Kubernetes NodeSelector and Tolerations. Disable this if using a cluster that does not support nodepools. |
| gen3WorkflowConfig.enablePrometheusMetrics | bool | `false` | Enables Prometheus metrics for the workflow service. |
| gen3WorkflowConfig.hostname | string | `""` | Override hostname where the workflow service runs. If empty, gen3-workflow falls back to values.global.hostname |
| gen3WorkflowConfig.httpxDebug | bool | `false` | Enables verbose logging specifically for httpx requests. |
| gen3WorkflowConfig.kmsEncryptionEnabled | bool | `true` | Enables KMS encryption for S3 uploads. |
| gen3WorkflowConfig.mockAuth | bool | `false` | Enables mock authentication, bypassing Arborist. Use only for development. |
| gen3WorkflowConfig.prometheusMultiprocDir | string | `"/var/tmp/prometheus_metrics"` | Filesystem directory used for Prometheus multi-process metrics collection. |
| gen3WorkflowConfig.proxyPrefix | string | `"/workflows"` | For deployments that run the app behind a proxy. The value should start with a slash. |
| gen3WorkflowConfig.s3AccessKeyId | string | `""` | AWS Access Key ID used to make S3 requests on behalf of users.    Leave empty to use credentials from an existing STS session. |
| gen3WorkflowConfig.s3ObjectsExpirationDays | int | `30` | Number of days after which workflow-generated S3 objects are deleted. |
| gen3WorkflowConfig.s3SecretAccessKey | string | `""` | AWS Secret Access Key used to make S3 requests on behalf of users.    Leave empty to use credentials from an existing STS session. |
| gen3WorkflowConfig.s3UpstreamEndpoint | string | `""` | Connect to another S3-compatible service than AWS S3 (default: AWS S3) |
| gen3WorkflowConfig.taskImageWhitelist | list | `[]` | Whitelist of container image patterns allowed for workflow tasks.    Supports wildcards `*` and `{username}` placeholders. |
| gen3WorkflowConfig.tesServerUrl | string | `"http://funnel:8000"` | TES server URL to which workflow tasks are forwarded. |
| gen3WorkflowConfig.userBucketsRegion | string | `"us-east-1"` | AWS region used for creating user S3 buckets. |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null},"region":"us-east-1"}` | AWS configuration |
=======
| funnel.Kubernetes | map | `{"JobsNamespace":"","Namespace":""}` | Kubernetes configuration for Funnel. |
| funnel.Kubernetes.JobsNamespace | string | `""` | Namespace where Funnel jobs will be created. |
| funnel.Kubernetes.Namespace | string | `""` | Namespace where Funnel server will be created. |
| funnel.Logger.level | string | `"debug"` |  |
| funnel.Plugins | map | `{"Disabled":false,"Params":{"OidcClientId":"","OidcClientSecret":"","OidcTokenUrl":"gen3-workflow-service.jenkins-blood.svc.cluster.local","S3Url":"https://jenkins-blood.planx-pla.net/user"},"Path":"plugin-binaries/auth-plugin"}` | Configuration for the Funnel plugin. |
| funnel.Plugins.Params | map | `{"OidcClientId":"","OidcClientSecret":"","OidcTokenUrl":"gen3-workflow-service.jenkins-blood.svc.cluster.local","S3Url":"https://jenkins-blood.planx-pla.net/user"}` | Parameters to send to the Funnel plugin. |
| funnel.Plugins.Params.OidcClientId | string | `""` | OIDC client ID for Funnel plugin. |
| funnel.Plugins.Params.OidcClientSecret | string | `""` | OIDC client secret for Funnel plugin. |
| funnel.Plugins.Params.OidcTokenUrl | string | `"gen3-workflow-service.jenkins-blood.svc.cluster.local"` | OIDC token URL for Funnel plugin. |
| funnel.Plugins.Params.S3Url | string | `"https://jenkins-blood.planx-pla.net/user"` | S3 URL for Funnel plugin. |
| funnel.Plugins.Path | string | `"plugin-binaries/auth-plugin"` | Path to the directory where Funnel plugins are stored. |
| funnel.image | map | `{"initContainer":{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","pullPolicy":"Always","tag":"debug-logging"},"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel","tag":"2025-07-09"}` | Configuration for the Funnel container image. |
| funnel.image.initContainer | map | `{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","pullPolicy":"Always","tag":"debug-logging"}` | Configuration for the Funnel init container. |
| funnel.image.initContainer.command | list | `["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| funnel.image.initContainer.image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| funnel.image.initContainer.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.initContainer.tag | string | `"debug-logging"` | The Docker image tag for the Funnel init/plugin container. |
=======
| funnel.Kubernetes.ExecutorTemplate | string | `"# Task Executor\napiVersion: batch/v1\nkind: Job\nmetadata:\n  name: {{.TaskId}}-{{.JobId}}\n  namespace: {{.JobsNamespace}}\n  labels:\n    app: funnel-executor\n    job-name: {{.TaskId}}-{{.JobId}}\nspec:\n  backoffLimit: 1\n  completions: 1\n  template:\n    spec:\n      restartPolicy: OnFailure\n      serviceAccountName: funnel-sa-{{.Namespace}}\n      containers:\n      - name: funnel-worker-{{.TaskId}}\n        image: {{.Image}}\n        imagePullPolicy: Always\n        command: [\"/bin/sh\", \"-c\"]\n        args: {{.Command}}\n        workingDir: {{.Workdir}}\n        resources:\n          requests:\n            cpu: {{if ne .Cpus 0 -}}{{.Cpus}}{{ else }}{{\"100m\"}}{{end}}\n            memory: '{{if ne .RamGb 0.0 -}}{{printf \"%.0fG\" .RamGb}}{{else}}{{\"4G\"}}{{end}}'\n            ephemeral-storage: '{{if ne .DiskGb 0.0 -}}{{printf \"%.0fG\" .DiskGb}}{{else}}{{\"2G\"}}{{end}}'\n\n        volumeMounts:\n        ### DO NOT CHANGE THIS\n        {{- if .NeedsPVC }}\n          {{range $idx, $item := .Volumes}}\n          - name: funnel-storage-{{$.TaskId}}\n            mountPath: {{$item.ContainerPath}}\n            subPath: {{$.TaskId}}{{$item.ContainerPath}}\n          {{end}}\n        {{- end }}\n\n      volumes:\n      {{- if .NeedsPVC }}\n      - name: funnel-storage-{{.TaskId}}\n        persistentVolumeClaim:\n          claimName: funnel-worker-pvc-{{.TaskId}}\n      {{- end }}\n"` |  |
| funnel.Kubernetes.PVTemplate | string | `"apiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: funnel-worker-pv-{{.TaskId}}\n  labels:\n    app: funnel\n    taskId: {{.TaskId}}\nspec:\n  storageClassName: \"\" # Required for static provisioning\n  capacity:\n    storage: \"10Mi\"\n  accessModes:\n    - ReadWriteMany\n  persistentVolumeReclaimPolicy: Retain\n  mountOptions:\n    - allow-delete\n    - allow-overwrite\n    - region={{.Region}}\n    - file-mode=0755\n    {{- if .KmsKeyID }}\n    - sse aws:kms\n    - sse-kms-key-id={{.KmsKeyID}}\n    {{- end }}\n  csi:\n    driver: s3.csi.aws.com\n    volumeHandle: s3-csi-{{.TaskId}}\n    volumeAttributes:\n      bucketName: {{.Bucket}}\n      authenticationSource: pod\n      stsRegion: us-east-1 # <-- Must match the EKS cluster region for your deployment\n  claimRef:\n    namespace: {{.Namespace}}\n    name: funnel-worker-pvc-{{.TaskId}}\n"` |  |
| funnel.image | map | `{"initContainers":[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","echo \"Priting FUNNEL_OIDC_CLIENT_ID: $FUNNEL_OIDC_CLIENT_ID\"\n\necho \"Patching values...\"\n\n# Assuming we don't have any other occurence of OidcClientId in the config file\nsed -E \"s|(OidcClientId:).*|\\1 ${FUNNEL_OIDC_CLIENT_ID}|\" /etc/config/funnel.conf \\\n| sed -E \"s|(OidcClientSecret:).*|\\1 ${FUNNEL_OIDC_CLIENT_SECRET}|\" > /tmp/funnel-patched.conf\n\nif [[ ! -s /tmp/funnel-patched.conf ]]; then\n  echo \"ERROR: Patched config is empty. Aborting.\"\n  exit 1\nfi\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"secrets-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}],"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel"}` | Configuration for the Funnel container image. |
| funnel.image.initContainers | map | `[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"main-gen3","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","echo \"Priting FUNNEL_OIDC_CLIENT_ID: $FUNNEL_OIDC_CLIENT_ID\"\n\necho \"Patching values...\"\n\n# Assuming we don't have any other occurence of OidcClientId in the config file\nsed -E \"s|(OidcClientId:).*|\\1 ${FUNNEL_OIDC_CLIENT_ID}|\" /etc/config/funnel.conf \\\n| sed -E \"s|(OidcClientSecret:).*|\\1 ${FUNNEL_OIDC_CLIENT_SECRET}|\" > /tmp/funnel-patched.conf\n\nif [[ ! -s /tmp/funnel-patched.conf ]]; then\n  echo \"ERROR: Patched config is empty. Aborting.\"\n  exit 1\nfi\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"secrets-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"},{"mountPath":"/etc/config/funnel.conf","name":"funnel-config-volume","subPath":"funnel-server.yaml"}]}]` | Configuration for the Funnel init container. |
| funnel.image.initContainers[0].command | list | `["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| funnel.image.initContainers[0].image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| funnel.image.initContainers[0].pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.initContainers[0].tag | string | `"main-gen3"` | The Docker image tag for the Funnel init/plugin container. |
>>>>>>> 48f8095f (Update funnel plugin branch)
| funnel.image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.repository | string | `"quay.io/ohsu-comp-bio/funnel"` | The Docker image repository for the Funnel service. |
<<<<<<< HEAD
| funnel.image.tag | string | `"feature-plugins"` | The Docker image tag for the Funnel service. |
=======
| funnel.image.tag | string | `"2025-07-09"` | The Docker image tag for the Funnel service. |
| funnel.mongodb.image.registry | string | `"docker.io"` |  |
| funnel.mongodb.image.repository | string | `"dlavrenuek/bitnami-mongodb-arm"` |  |
| funnel.mongodb.image.tag | string | `"6.0.13"` |  |
>>>>>>> ac9ee302 (Add useryaml, update funnel secrets, add funnel local chart reference)
| funnel.mongodb.readinessProbe.enabled | bool | `true` |  |
| funnel.mongodb.readinessProbe.failureThreshold | int | `10` |  |
| funnel.mongodb.readinessProbe.initialDelaySeconds | int | `20` |  |
| funnel.mongodb.readinessProbe.periodSeconds | int | `10` |  |
| funnel.mongodb.readinessProbe.timeoutSeconds | int | `10` |  |
| funnel.volumeMounts[0].mountPath | string | `"/etc/config/funnel-server.yaml"` |  |
| funnel.volumeMounts[0].name | string | `"config-volume"` |  |
| funnel.volumeMounts[0].subPath | string | `"funnel-server.yaml"` |  |
| funnel.volumeMounts[1].mountPath | string | `"/etc/funnel/templates"` |  |
| funnel.volumeMounts[1].name | string | `"worker-templates-volume"` |  |
| funnel.volumeMounts[2].mountPath | string | `"/opt/funnel/plugin-binaries"` |  |
| funnel.volumeMounts[2].name | string | `"plugin-volume"` |  |
| funnel.volumes[0].name | string | `"config-volume"` |  |
| funnel.volumes[0].secret.items[0].key | string | `"funnel.conf"` |  |
| funnel.volumes[0].secret.items[0].path | string | `"funnel-server.yaml"` |  |
| funnel.volumes[0].secret.secretName | string | `"gen3workflow-g3auto"` |  |
| funnel.volumes[1].configMap.name | string | `"funnel-worker-templates"` |  |
| funnel.volumes[1].name | string | `"worker-templates-volume"` |  |
| funnel.volumes[2].emptyDir | object | `{}` |  |
| funnel.volumes[2].name | string | `"plugin-volume"` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null}}` | AWS configuration |
>>>>>>> 5ba4b84a (Update secrets.yaml and add gen3-workflow to umbrella chart)
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
<<<<<<< HEAD
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.clusterName | string | `"default"` | Kubernetes cluster name. |
=======
>>>>>>> dc5ea6b4 (Add Crossplane configuration for gen3-workflow)
| global.crossplane.accountId | string | `""` | AWS Account ID where resources will be created. |
| global.crossplane.enabled | bool | `false` | Whether Crossplane is being used to manage AWS resources. |
| global.crossplane.oidcProviderUrl | string | `""` | OIDC provider URL for the EKS cluster. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.environment | string | `"default"` |  |
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","deploy":false,"separateSecretStore":false}` | External Secrets settings. |
=======
| global.externalSecrets | map | `{"deploy":false,"pushGen3WorkflowSecretsToExternalSecret":false,"separateSecretStore":false}` | External Secrets settings. |
>>>>>>> dc5ea6b4 (Add Crossplane configuration for gen3-workflow)
=======
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","deploy":false,"pushGen3WorkflowSecretsToExternalSecret":false,"separateSecretStore":false}` | External Secrets settings. |
>>>>>>> e4fe116c (Respond to initial PR comments)
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any gen3-workflow secrets you have deployed. |
=======
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","deploy":false,"pushFunnelOidcClientToExternalSecrets":true,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any gen3-workflow secrets you have deployed. |
| global.externalSecrets.pushFunnelOidcClientToExternalSecrets | bool | `true` | Will push secrets to External Secrets Store. |
>>>>>>> 5d63219c (Rename`pushGen3WorkflowSecretsToExternalSecret` to `pushFunnelOidcClientToExternalSecrets`)
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.hostname | string | `""` | Hostname for the deployment. |
| global.netPolicy | map | `{"dbSubnets":[],"enabled":false}` | Network policy settings. |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.topologySpread | map | `{"enabled":false,"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone"}` | Karpenter topology spread configuration. |
| global.topologySpread.enabled | bool | `false` | Whether to enable topology spread constraints for all subcharts that support it. |
| global.topologySpread.maxSkew | int | `1` | The maxSkew to use for topology spread constraints. Defaults to 1. |
| global.topologySpread.topologyKey | string | `"topology.kubernetes.io/zone"` | The topology key to use for spreading. Defaults to "topology.kubernetes.io/zone". |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/gen3-workflow","tag":"master"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.repository | string | `"quay.io/cdis/gen3-workflow"` | The Docker image repository for the gen3workflow service |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| initEnv | list | `{}` | Volumes to attach to the init container. |
| initVolumeMounts | list | `[]` | Volumes to mount to the init container. |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. This can be used to provide a unique name for a chart |
| netPolicy | map | `{"egressApps":["funnel"],"ingressApps":["funnel"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["funnel"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["funnel"]` | List of app labels that require ingress to this service |
| nodeSelector | map | `{}` | Node Selector for the pods |
| partOf | string | `"Workflow_Execution"` | Label to help organize pods and their use. Any value is valid, but use "_" or "-" to divide words. |
| podAnnotations | map | `{}` | Annotations to add to the pod |
| podSecurityContext | map | `{}` | Security context for the pod |
| release | string | `"production"` | Valid options are "production" or "dev". If invalid option is set- the value will default to "dev". |
| replicaCount | int | `1` | Number of desired replicas |
| resources | map | `{}` | Resource requests and limits for the containers in the pod |
| secrets | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null}` | Secret information for External Secrets. |
| secrets.awsAccessKeyId | str | `nil` | AWS access key ID. Overrides global key. |
| secrets.awsSecretAccessKey | str | `nil` | AWS secret access key ID. Overrides global key. |
| securityContext | map | `{}` | Security context for the containers in the pod |
| selectorLabels | map | `nil` | Will completely override the selectorLabels defined in the common chart's _label_setup.tpl |
| service | map | `{"port":80,"type":"ClusterIP"}` | Configuration for the service |
| service.port | int | `80` | Port on which the service is exposed |
| service.type | string | `"ClusterIP"` | Type of service. Valid values are "ClusterIP", "NodePort", "LoadBalancer", "ExternalName". |
<<<<<<< HEAD
<<<<<<< HEAD
| serviceAccount | map | `{"annotations":{},"create":true,"name":"gen3-workflow-sa"}` | Service account to use or create. |
=======
| serviceAccount | map | `{"annotations":{"eks.amazonaws.com/role-arn":"arn:aws:iam::707767160287:role/gen3_service/devplanetv2--qa-midrc--gen3-workflow-sa"},"create":true,"name":"gen3-workflow-sa"}` | Service account to use or create. |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::707767160287:role/gen3_service/devplanetv2--qa-midrc--gen3-workflow-sa"` | The Amazon Resource Name (ARN) of the role to associate with the service account |
>>>>>>> ac9ee302 (Add useryaml, update funnel secrets, add funnel local chart reference)
=======
| serviceAccount | map | `{"annotations":{},"create":true,"name":"gen3-workflow-sa"}` | Service account to use or create. |
>>>>>>> f0a6e9e7 (Re-Add elastic search chart from gen3 Charts, some minor updates)
| serviceAccount.create | bool | `true` | Whether to create a service account |
| serviceAccount.name | string | `"gen3-workflow-sa"` | The name of the service account |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[{"mountPath":"/src/gen3-workflow-config.yaml","name":"config-volume","readOnly":true,"subPath":"gen3-workflow-config.yaml"},{"mountPath":"/gen3-workflow/gen3-workflow-config.yaml","name":"config-volume","readOnly":true,"subPath":"gen3-workflow-config.yaml"}]` | Volumes to mount to the container. |
| volumes | list | `[{"name":"config-volume","secret":{"secretName":"gen3workflow-g3auto"}}]` | Volumes to attach to the container. |
