# heal-cronjobs

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for HEAL cronjobs (e.g. CEDAR ingestion)

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
| affinity | map | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["on-demand"]}]},"weight":100},{"preference":{"matchExpressions":[{"key":"eks.amazonaws.com/capacityType","operator":"In","values":["ONDEMAND"]}]},"weight":99}]}}` | Node affinity applied to every job pod unless the job sets its own `affinity`. Prefers on-demand capacity, so long jobs are not interrupted by spot reclaims. |
| cronjobs | map | see values.yaml | Cronjobs to deploy, keyed by name. The key is used as the CronJob name. Each job runs `script` in an init container. Exit code 0 = SUCCESS, anything else = FAILED. If `slackNotify` is true, a notifier container then reports the result to Slack.  Supported keys per job:   enabled, schedule, suspend, concurrencyPolicy, successfulJobsHistoryLimit,   failedJobsHistoryLimit, backoffLimit, image {repository, tag, pullPolicy},   serviceAccountName, resources, env (list of k8s EnvVar), vars (map of plain env vars),   volumes, volumeMounts, affinity, slackNotify, script. Prefer `vars` for settings an environment may override: maps are deep-merged across values files, while lists like `env` are replaced wholesale. |
| enabled | bool | `true` | Whether to deploy the heal-cronjobs chart. |
| extraLabels | map | `{}` | Extra labels added to every job pod. |
| global.awshelper_container_image | string | `""` | Optional global override for the awshelper image. Used by every job that does not set its own `image`. |
| global.hostname | string | `""` | Hostname of the deployment. Used for the `hostname` label on job pods. |
| image | map | `{"pullPolicy":"Always","repository":"quay.io/cdis/awshelper","tag":"master"}` | Default image for every cronjob. Each job can override it with its own `image` block. |
| image.pullPolicy | string | `"Always"` | Docker pull policy. |
| image.repository | string | `"quay.io/cdis/awshelper"` | Docker repository. |
| image.tag | string | `"master"` | Docker image tag. |
| nodeSelector | map | `{}` | Node selector applied to every job pod. |
| podAnnotations | map | `{}` | Annotations added to every job pod. |
| slack | map | `{"secretKey":"slack_webhook","secretName":"slack-webhook"}` | Slack notification settings. When a job has `slackNotify: true`, a notifier container posts SUCCESS/FAILED to Slack after the job script finishes. |
| slack.secretKey | string | `"slack_webhook"` | Key in the secret that holds the Slack webhook URL. |
| slack.secretName | string | `"slack-webhook"` | Name of the secret that holds the Slack webhook URL. Missing secret or key is tolerated (no message is sent). |
| tolerations | list | `[]` | Tolerations applied to every job pod. |
