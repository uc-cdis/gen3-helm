# karpenter-templates

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

A Helm chart for managing karpenter templates

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ami.familiy | string | `"AL2"` |  |
| ami.id | string | `"ami-0d3eabf74e1e2258b"` |  |
| cluster.name | string | `"my-cluster"` |  |
| ebs.deleteOnTermination | bool | `true` |  |
| ebs.deviceName | string | `"/dev/xvda"` |  |
| ebs.encrypted | bool | `true` |  |
| ebs.volumeSize | string | `"50Gi"` |  |
| ebs.volumeType | string | `"gp3"` |  |
| userdata | string | `"MIME-Version: 1.0\nContent-Type: multipart/mixed; boundary=\"BOUNDARY\"\n\n--BOUNDARY\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\n\n#!/bin/bash -x\ninstanceId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId)\ncurl https://raw.githubusercontent.com/uc-cdis/cloud-automation/master/files/authorized_keys/ops_team >> /home/ec2-user/.ssh/authorized_keys\necho \"$(jq '.registryPullQPS=0' /etc/kubernetes/kubelet/kubelet-config.json)\" > /etc/kubernetes/kubelet/kubelet-config.json\nsysctl -w fs.inotify.max_user_watches=12000\n\nsudo yum update -y\n\n--BOUNDARY--\n"` |  |

