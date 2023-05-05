# Gen3 using helm in production


The postgres and helm charts are included as conditionals in the Gen3 [umbrella chart](https://helm.sh/docs/howto/charts_tips_and_tricks/#complex-charts-with-many-dependencies)

```
- name: elasticsearch
  version: "0.1.3"
  repository: "file://../elasticsearch"
  condition: global.dev
- name: postgresql
  version: 11.9.13
  repository: "https://charts.bitnami.com/bitnami"
  condition: global.dev
  ```
