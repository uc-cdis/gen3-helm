# gen3-network-policies

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.2](https://img.shields.io/badge/AppVersion-0.1.2-informational?style=flat-square)

A Helm chart that holds network policies needed to run Gen3

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-workflows.enabled | bool | `true` |  |
| argocd.enabled | bool | `true` |  |
| s3CidrRanges[0].ipBlock.cidr | string | `"18.34.0.0/19"` |  |
| s3CidrRanges[1].ipBlock.cidr | string | `"16.15.192.0/18"` |  |
| s3CidrRanges[2].ipBlock.cidr | string | `"54.231.0.0/16"` |  |
| s3CidrRanges[3].ipBlock.cidr | string | `"52.216.0.0/15"` |  |
| s3CidrRanges[4].ipBlock.cidr | string | `"18.34.232.0/21"` |  |
| s3CidrRanges[5].ipBlock.cidr | string | `"16.15.176.0/20"` |  |
| s3CidrRanges[6].ipBlock.cidr | string | `"16.182.0.0/16"` |  |
| s3CidrRanges[7].ipBlock.cidr | string | `"3.5.0.0/19"` |  |
| s3CidrRanges[8].ipBlock.cidr | string | `"44.192.134.240/28"` |  |
| s3CidrRanges[9].ipBlock.cidr | string | `"44.192.140.64/28"` |  |
