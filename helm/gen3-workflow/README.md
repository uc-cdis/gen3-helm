# gen3-workflow

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.25 |
| https://ohsu-comp-bio.github.io/helm-charts | funnel | 0.1.58 |

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
| externalSecrets | map | `{"createFunnelOidcClientSecret":true,"createK8sGen3WorkflowSecret":true,"funnelOidcClient":null,"gen3workflowG3auto":""}` | External Secrets settings. |
| externalSecrets.createFunnelOidcClientSecret | bool | `true` | Whether to create the Funnel OIDC client secret using the oidc job. |
| externalSecrets.createK8sGen3WorkflowSecret | string | `true` | Will create the Helm "gen3workflow-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets. |
| externalSecrets.funnelOidcClient | string | `nil` | Will override the name of the aws secrets manager secret. Default is "funnel-oidc-client". |
| externalSecrets.gen3workflowG3auto | string | `""` | Will override the name of the aws secrets manager secret. Default is "gen3workflow-g3auto" |
| extraLabels | map | `{"dbgen3workflow":"yes","netnolimit":"yes","public":"yes"}` | Will completely override the extraLabels defined in the common chart's _label_setup.tpl |
| fullnameOverride | string | `""` | Override the full name of the chart, which is used as the name of resources created by the chart |
| funnel.Kubernetes.ExecutorTemplate | string | `"# Task Executor\napiVersion: batch/v1\nkind: Job\nmetadata:\n  name: {{.TaskId}}-{{.JobId}}\n  namespace: {{.JobsNamespace}}\n  labels:\n    app: funnel-executor\n    job-name: {{.TaskId}}-{{.JobId}}\nspec:\n  backoffLimit: 1\n  completions: 1\n  template:\n    spec:\n      restartPolicy: OnFailure\n      serviceAccountName: funnel-sa-{{.Namespace}}\n      containers:\n      - name: funnel-worker-{{.TaskId}}\n        image: {{.Image}}\n        imagePullPolicy: Always\n        command: [\"/bin/sh\", \"-c\"]\n        args: {{.Command}}\n        workingDir: {{.Workdir}}\n        resources:\n          requests:\n            cpu: {{if ne .Cpus 0 -}}{{.Cpus}}{{ else }}{{\"100m\"}}{{end}}\n            memory: '{{if ne .RamGb 0.0 -}}{{printf \"%.0fG\" .RamGb}}{{else}}{{\"4G\"}}{{end}}'\n            ephemeral-storage: '{{if ne .DiskGb 0.0 -}}{{printf \"%.0fG\" .DiskGb}}{{else}}{{\"2G\"}}{{end}}'\n\n        volumeMounts:\n        ### DO NOT CHANGE THIS\n        {{- if .NeedsPVC }}\n          {{range $idx, $item := .Volumes}}\n          - name: funnel-storage-{{$.TaskId}}\n            mountPath: {{$item.ContainerPath}}\n            subPath: {{$.TaskId}}{{$item.ContainerPath}}\n          {{end}}\n        {{- end }}\n\n      volumes:\n      {{- if .NeedsPVC }}\n      - name: funnel-storage-{{.TaskId}}\n        persistentVolumeClaim:\n          claimName: funnel-worker-pvc-{{.TaskId}}\n      {{- end }}\n"` |  |
| funnel.Kubernetes.PVTemplate | string | `"apiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: funnel-worker-pv-{{.TaskId}}\n  labels:\n    app: funnel\n    taskId: {{.TaskId}}\nspec:\n  storageClassName: \"\" # Required for static provisioning\n  capacity:\n    storage: \"10Mi\"\n  accessModes:\n    - ReadWriteMany\n  persistentVolumeReclaimPolicy: Retain\n  mountOptions:\n    - allow-delete\n    - allow-overwrite\n    - region={{.Region}}\n    - file-mode=0755\n    {{- if .KmsKeyID }}\n    - sse aws:kms\n    - sse-kms-key-id={{.KmsKeyID}}\n    {{- end }}\n  csi:\n    driver: s3.csi.aws.com\n    volumeHandle: s3-csi-{{.TaskId}}\n    volumeAttributes:\n      bucketName: {{.Bucket}}\n  claimRef:\n    namespace: {{.Namespace}}\n    name: funnel-worker-pvc-{{.TaskId}}\n"` |  |
| funnel.image | map | `{"initContainers":[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"debug-logging","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","echo \"Priting FUNNEL_OIDC_CLIENT_ID: $FUNNEL_OIDC_CLIENT_ID\"\n\necho \"Patching values...\"\n\n# Assuming we don't have any other occurence of OidcClientId in the config file\nsed -E \"s|(OidcClientId:).*|\\1 ${FUNNEL_OIDC_CLIENT_ID}|\" /etc/config/funnel.conf \\\n| sed -E \"s|(OidcClientSecret:).*|\\1 ${FUNNEL_OIDC_CLIENT_SECRET}|\" > /tmp/funnel-patched.conf\n\nif [[ ! -s /tmp/funnel-patched.conf ]]; then\n  echo \"ERROR: Patched config is empty. Aborting.\"\n  exit 1\nfi\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"secrets-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"}]}],"pullPolicy":"Always","repository":"quay.io/ohsu-comp-bio/funnel","tag":"2025-07-09"}` | Configuration for the Funnel container image. |
| funnel.image.initContainers | map | `[{"command":["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"],"image":"quay.io/cdis/funnel-gen3-plugin","name":"plugin","pullPolicy":"Always","tag":"debug-logging","volumeMounts":[{"mountPath":"/opt/funnel/plugin-binaries","name":"plugin-volume"}]},{"args":["-c","echo \"Priting FUNNEL_OIDC_CLIENT_ID: $FUNNEL_OIDC_CLIENT_ID\"\n\necho \"Patching values...\"\n\n# Assuming we don't have any other occurence of OidcClientId in the config file\nsed -E \"s|(OidcClientId:).*|\\1 ${FUNNEL_OIDC_CLIENT_ID}|\" /etc/config/funnel.conf \\\n| sed -E \"s|(OidcClientSecret:).*|\\1 ${FUNNEL_OIDC_CLIENT_SECRET}|\" > /tmp/funnel-patched.conf\n\nif [[ ! -s /tmp/funnel-patched.conf ]]; then\n  echo \"ERROR: Patched config is empty. Aborting.\"\n  exit 1\nfi\n"],"command":["/bin/bash"],"env":[{"name":"FUNNEL_OIDC_CLIENT_ID","valueFrom":{"secretKeyRef":{"key":"client_id","name":"funnel-oidc-client","optional":false}}},{"name":"FUNNEL_OIDC_CLIENT_SECRET","valueFrom":{"secretKeyRef":{"key":"client_secret","name":"funnel-oidc-client","optional":false}}}],"image":"quay.io/cdis/awshelper","name":"secrets-updater","tag":"master","volumeMounts":[{"mountPath":"/tmp","name":"funnel-patched-config-volume"}]}]` | Configuration for the Funnel init container. |
| funnel.image.initContainers[0].command | list | `["cp","/app/build/plugins/authorizer","/opt/funnel/plugin-binaries/auth-plugin"]` | Arguments to pass to the init container. |
| funnel.image.initContainers[0].image | string | `"quay.io/cdis/funnel-gen3-plugin"` | The Docker image repository for the Funnel init/plugin container. |
| funnel.image.initContainers[0].pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.initContainers[0].tag | string | `"debug-logging"` | The Docker image tag for the Funnel init/plugin container. |
| funnel.image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| funnel.image.repository | string | `"quay.io/ohsu-comp-bio/funnel"` | The Docker image repository for the Funnel service. |
| funnel.image.tag | string | `"2025-07-09"` | The Docker image tag for the Funnel service. |
| funnel.mongodb.Plugins.Params.OidcClientId | string | `"<redacted>"` |  |
| funnel.mongodb.Plugins.Params.OidcClientSecret | string | `"<redacted>"` |  |
| funnel.mongodb.Plugins.Params.OidcTokenUrl | string | `"https://{{ .Values.workflowConfig.hostname }}/user"` | OIDC token URL for the Funnel service to use for authentication. Replace {{ .Values.workflowConfig.hostname }} with the actual hostname where gen3-workflow is deployed. |
| funnel.mongodb.Plugins.Params.S3Url | string | `"gen3-workflow-service.{{ .Release.Namespace }}.svc.cluster.local"` |  |
| funnel.mongodb.Plugins.Path | string | `"plugin-binaries/auth-plugin"` |  |
| funnel.mongodb.readinessProbe.enabled | bool | `true` |  |
| funnel.mongodb.readinessProbe.failureThreshold | int | `10` |  |
| funnel.mongodb.readinessProbe.initialDelaySeconds | int | `20` |  |
| funnel.mongodb.readinessProbe.periodSeconds | int | `10` |  |
| funnel.mongodb.readinessProbe.timeoutSeconds | int | `10` |  |
| funnel.volumeMounts[0].mountPath | string | `"/etc/config/funnel-server.yaml"` |  |
| funnel.volumeMounts[0].name | string | `"funnel-patched-config-volume"` |  |
| funnel.volumeMounts[0].subPath | string | `"funnel-patched.conf"` |  |
| funnel.volumeMounts[1].mountPath | string | `"/etc/config/oidc"` |  |
| funnel.volumeMounts[1].name | string | `"funnel-oidc-volume"` |  |
| funnel.volumeMounts[1].readOnly | bool | `true` |  |
| funnel.volumeMounts[2].mountPath | string | `"/etc/funnel/templates"` |  |
| funnel.volumeMounts[2].name | string | `"worker-templates-volume"` |  |
| funnel.volumeMounts[3].mountPath | string | `"/opt/funnel/plugin-binaries"` |  |
| funnel.volumeMounts[3].name | string | `"plugin-volume"` |  |
| funnel.volumes[0].configMap.name | string | `"funnel-server-config"` |  |
| funnel.volumes[0].name | string | `"funnel-config-volume"` |  |
| funnel.volumes[1].name | string | `"funnel-oidc-volume"` |  |
| funnel.volumes[1].secret.items[0].key | string | `"client_id"` |  |
| funnel.volumes[1].secret.items[0].path | string | `"client_id"` |  |
| funnel.volumes[1].secret.items[1].key | string | `"client_secret"` |  |
| funnel.volumes[1].secret.items[1].path | string | `"client_secret"` |  |
| funnel.volumes[1].secret.secretName | string | `"funnel-oidc-client"` |  |
| funnel.volumes[2].configMap.name | string | `"funnel-worker-templates"` |  |
| funnel.volumes[2].name | string | `"worker-templates-volume"` |  |
| funnel.volumes[3].emptyDir | object | `{}` |  |
| funnel.volumes[3].name | string | `"plugin-volume"` |  |
| funnel.volumes[4].emptyDir | object | `{}` |  |
| funnel.volumes[4].name | string | `"funnel-patched-config-volume"` |  |
| global.aws | map | `{"awsAccessKeyId":null,"awsSecretAccessKey":null,"enabled":false,"externalSecrets":{"enabled":false,"externalSecretAwsCreds":null},"region":"us-east-1"}` | AWS configuration |
| global.aws.awsAccessKeyId | string | `nil` | Credentials for AWS stuff. |
| global.aws.awsSecretAccessKey | string | `nil` | Credentials for AWS stuff. |
| global.aws.enabled | bool | `false` | Set to true if deploying to AWS. Controls ingress annotations. |
| global.aws.externalSecrets.enabled | bool | `false` | Whether to use External Secrets for aws config. |
| global.aws.externalSecrets.externalSecretAwsCreds | String | `nil` | Name of Secrets Manager secret. |
| global.aws.region | string | `"us-east-1"` | AWS region for this deployment |
| global.clusterName | string | `"default"` | Kubernetes cluster name. |
| global.crossplane.accountId | string | `""` | AWS Account ID where resources will be created. |
| global.crossplane.enabled | bool | `false` | Whether Crossplane is being used to manage AWS resources. |
| global.crossplane.oidcProviderUrl | string | `""` | OIDC provider URL for the EKS cluster. |
| global.dev | bool | `true` | Whether the deployment is for development purposes. |
| global.environment | string | `"default"` |  |
| global.externalSecrets | map | `{"clusterSecretStoreRef":"","deploy":false,"pushFunnelOidcClientToExternalSecrets":true,"separateSecretStore":false}` | External Secrets settings. |
| global.externalSecrets.deploy | bool | `false` | Will use ExternalSecret resources to pull secrets from Secrets Manager instead of creating them locally. Be cautious as this will override any gen3-workflow secrets you have deployed. |
| global.externalSecrets.pushFunnelOidcClientToExternalSecrets | bool | `true` | Will push secrets to External Secrets Store. |
| global.externalSecrets.separateSecretStore | string | `false` | Will deploy a separate External Secret Store for this service. |
| global.netPolicy | map | `{"enabled":false}` | Network policy settings. |
| global.netPolicy.enabled | bool | `false` | Whether network policies are enabled |
| global.postgres.dbCreate | bool | `false` | Whether the database should be created. |
| global.postgres.externalSecret | string | `""` | Name of external secret. Disabled if empty |
| global.postgres.master | map | `{"host":null,"password":null,"port":"5432","username":"postgres"}` | Master credentials to postgres. This is going to be the default postgres server being used for each service, unless each service specifies their own postgres |
| global.postgres.master.host | string | `nil` | hostname of postgres server |
| global.postgres.master.password | string | `nil` | password for superuser in postgres. This is used to create or restore databases |
| global.postgres.master.port | string | `"5432"` | Port for Postgres. |
| global.postgres.master.username | string | `"postgres"` | username of superuser in postgres. This is used to create or restore databases |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/gen3-workflow","tag":"master"}` | Docker image information. |
| image.pullPolicy | string | `"Always"` | When to pull the image. This value should be "Always" to ensure the latest image is used. |
| image.repository | string | `"quay.io/cdis/gen3-workflow"` | The Docker image repository for the gen3workflow service |
| image.tag | string | `"master"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker image pull secrets. |
| initEnv | list | `{}` | Volumes to attach to the init container. |
| initVolumeMounts | list | `[]` | Volumes to mount to the init container. |
| karpenter."nodeclass.yaml" | string | `"apiVersion: karpenter.k8s.aws/v1\nkind: EC2NodeClass\nmetadata:\n  name: gen3-workflow-user-USER_ID\nspec:\n  amiFamily: AL2\n  amiSelectorTerms:\n  - name: 1-31-EKS-FIPS*\n    owner: \"143731057154\"\n  blockDeviceMappings:\n  - deviceName: /dev/xvda\n    ebs:\n      deleteOnTermination: true\n      encrypted: true\n      volumeSize: 100Gi\n      volumeType: gp2\n  metadataOptions:\n    httpEndpoint: enabled\n    httpProtocolIPv6: disabled\n    httpPutResponseHopLimit: 2\n    httpTokens: optional\n  role: eks_ENVIRONMENT_workers_role\n  securityGroupSelectorTerms:\n  - tags:\n      karpenter.sh/discovery: ENVIRONMENT-workflow\n  subnetSelectorTerms:\n  - tags:\n      karpenter.sh/discovery: ENVIRONMENT\n  tags:\n    Environment: ENVIRONMENT\n    Name: eks-ENVIRONMENT-workflow-karpenter\n    gen3service: argo-workflows\n    gen3username: GEN3_USERNAME\n    gen3teamproject: \"GEN3_TEAMNAME\"\n    karpenter.sh/discovery: ENVIRONMENT\n    purpose: gen3-workflow-task\n    \"vadc:cost-type\": user-based-variable\n    \"vadc:usage-type\": user-infrastructure\n    \"vadc:environment-type\": \"ENVIRONMENT_TYPE_CODE\"\n  userData: |\n    MIME-Version: 1.0\n    Content-Type: multipart/mixed; boundary=\"BOUNDARY\"\n\n    --BOUNDARY\n    Content-Type: text/x-shellscript; charset=\"us-ascii\"\n\n    #!/bin/bash -x\n    instanceId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId)\n    curl https://raw.githubusercontent.com/uc-cdis/cloud-automation/master/files/authorized_keys/ops_team >> /home/ec2-user/.ssh/authorized_keys\n\n    echo \"$(jq '.registryPullQPS=0' /etc/kubernetes/kubelet/kubelet-config.json)\" > /etc/kubernetes/kubelet/kubelet-config.json\n\n    sysctl -w fs.inotify.max_user_watches=12000\n\n    --BOUNDARY--\n"` |  |
| karpenter."nodepool.yaml" | string | `"apiVersion: karpenter.sh/v1\nkind: NodePool\nmetadata:\n  name: gen3-workflow-USER_ID\nspec:\n  disruption:\n    consolidateAfter: 10s\n    consolidationPolicy: WhenEmpty\n  limits:\n    cpu: 4k\n  template:\n    metadata:\n      labels:\n        purpose: workflow\n        role: WORKFLOW_NAME\n    spec:\n      nodeClassRef:\n        group: karpenter.k8s.aws\n        kind: EC2NodeClass\n        name: gen3-workflow-USER_ID\n      requirements:\n      - key: karpenter.sh/capacity-type\n        operator: In\n        values:\n        - on-demand\n      - key: kubernetes.io/arch\n        operator: In\n        values:\n        - amd64\n      - key: node.kubernetes.io/instance-type\n        operator: In\n        values:\n        - c6a.large\n        - c6a.xlarge\n        - c6a.2xlarge\n        - c6a.4xlarge\n        - c6a.8xlarge\n        - c6a.12xlarge\n        - c7a.large\n        - c7a.xlarge\n        - c7a.2xlarge\n        - c7a.4xlarge\n        - c7a.8xlarge\n        - c7a.12xlarge\n        - c6i.large\n        - c6i.xlarge\n        - c6i.2xlarge\n        - c6i.4xlarge\n        - c6i.8xlarge\n        - c6i.12xlarge\n        - c7i.large\n        - c7i.xlarge\n        - c7i.2xlarge\n        - c7i.4xlarge\n        - c7i.8xlarge\n        - c7i.12xlarge\n        - m6a.2xlarge\n        - m6a.4xlarge\n        - m6a.8xlarge\n        - m6a.12xlarge\n        - m6a.16xlarge\n        - m6a.24xlarge\n        - m7a.2xlarge\n        - m7a.4xlarge\n        - m7a.8xlarge\n        - m7a.12xlarge\n        - m7a.16xlarge\n        - m7a.24xlarge\n        - m6i.2xlarge\n        - m6i.4xlarge\n        - m6i.8xlarge\n        - m6i.12xlarge\n        - m6i.16xlarge\n        - m6i.24xlarge\n        - m7i.2xlarge\n        - m7i.4xlarge\n        - m7i.8xlarge\n        - m7i.12xlarge\n        - m7i.16xlarge\n        - m7i.24xlarge\n        - r7iz.2xlarge\n        - r7iz.4xlarge\n        - r7iz.8xlarge\n        - r7iz.12xlarge\n        - r7iz.16xlarge\n        - r7iz.24xlarge\n      - key: kubernetes.io/os\n        operator: In\n        values:\n        - linux\n      taints:\n      - effect: NoSchedule\n        key: role\n        value: WORKFLOW_NAME\n"` |  |
| metricsEnabled | bool | `false` | Whether Metrics are enabled. |
| nameOverride | string | `""` | Override the name of the chart. This can be used to provide a unique name for a chart |
| netPolicy | map | `{"egressApps":["funnel"],"ingressApps":["funnel"]}` | Configuration for network policies created by this chart. Only relevant if "global.netPolicy.enabled" is set to true |
| netPolicy.egressApps | array | `["funnel"]` | List of apps that this app requires egress to |
| netPolicy.ingressApps | array | `["funnel"]` | List of app labels that require ingress to this service |
| nodeSelector | map | `{}` | Node Selector for the pods |
| oidc_job_enabled | bool | `true` | Whether to create a job to generate the OIDC client for Funnel. |
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
| serviceAccount | map | `{"annotations":{},"create":true,"name":"gen3-workflow-sa"}` | Service account to use or create. |
| serviceAccount.create | bool | `true` | Whether to create a service account |
| serviceAccount.name | string | `"gen3-workflow-sa"` | The name of the service account |
| strategy | map | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Rolling update deployment strategy |
| strategy.rollingUpdate.maxSurge | int | `1` | Number of additional replicas to add during rollout. |
| strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum amount of pods that can be unavailable during the update. |
| tolerations | list | `[]` | Tolerations for the pods |
| volumeMounts | list | `[{"mountPath":"/src/gen3-workflow-config.yaml","name":"config-volume","readOnly":true,"subPath":"gen3-workflow-config.yaml"},{"mountPath":"/gen3-workflow/gen3-workflow-config.yaml","name":"config-volume","readOnly":true,"subPath":"gen3-workflow-config.yaml"}]` | Volumes to mount to the container. |
| volumes | list | `[{"name":"config-volume","secret":{"secretName":"gen3workflow-g3auto"}}]` | Volumes to attach to the container. |
| workflowConfig.arboristUrl | string | `""` | Custom Arborist URL. Ignored if already set via environment variable. |
| workflowConfig.db.database | string | `"gen3workflow_test"` | Name of the database to connect to. |
| workflowConfig.db.driver | string | `"postgresql+asyncpg"` | SQLAlchemy-compatible database driver. |
| workflowConfig.db.host | string | `"localhost"` | Hostname of the database server. |
| workflowConfig.db.password | string | `"postgres"` | Password used to authenticate with the database. |
| workflowConfig.db.port | int | `5432` | Port number on which the database listens. |
| workflowConfig.db.user | string | `"postgres"` | Username used to authenticate with the database. |
| workflowConfig.debug | bool | `false` | Enables debug mode for the application. |
| workflowConfig.docsUrlPrefix | string | `"/gen3workflow"` | URL prefix used for serving OpenAPI documentation. |
| workflowConfig.enablePrometheusMetrics | bool | `false` | Enables Prometheus metrics for the workflow service. |
| workflowConfig.hostname | string | `"localhost"` | Hostname where the workflow service runs. |
| workflowConfig.httpxDebug | bool | `false` | Enables verbose logging specifically for httpx requests. |
| workflowConfig.kmsEncryptionEnabled | bool | `true` | Enables KMS encryption for S3 uploads. |
| workflowConfig.mockAuth | bool | `false` | Enables mock authentication, bypassing Arborist. Use only for development. |
| workflowConfig.prometheusMultiprocDir | string | `"/var/tmp/prometheus_metrics"` | Filesystem directory used for Prometheus multi-process metrics collection. |
| workflowConfig.s3AccessKeyId | string | `""` | AWS Access Key ID used to make S3 requests on behalf of users.    Leave empty to use credentials from an existing STS session. |
| workflowConfig.s3ObjectsExpirationDays | int | `30` | Number of days after which workflow-generated S3 objects are deleted. |
| workflowConfig.s3SecretAccessKey | string | `""` | AWS Secret Access Key used to make S3 requests on behalf of users.    Leave empty to use credentials from an existing STS session. |
| workflowConfig.taskImageWhitelist | list | `[]` | Whitelist of container image patterns allowed for workflow tasks.    Supports wildcards `*` and `{username}` placeholders. |
| workflowConfig.tesServerUrl | string | `"http://funnel:8000"` | TES server URL to which workflow tasks are forwarded. |
| workflowConfig.userBucketsRegion | string | `"us-east-1"` | AWS region used for creating user S3 buckets. |
