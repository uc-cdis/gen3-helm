#!/bin/bash

# TODO
## Intelligently query the resources in the cluster that don't have the requisite annotations for helm

k annotate --overwrite namespace jupyter-pods-burtonk meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label namespace jupyter-pods-burtonk   app.kubernetes.io/managed-by=Helm
k annotate --overwrite sa fence-sa meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label sa fence-sa   app.kubernetes.io/managed-by=Helm
k annotate --overwrite sa sower-service-account meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label sa sower-service-account   app.kubernetes.io/managed-by=Helm
k annotate --overwrite sa workspace-token-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label sa workspace-token-service   app.kubernetes.io/managed-by=Helm
k annotate --overwrite serviceaccount/access-backend-sa meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/default meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/fence-sa meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/gen3-discovery-ai-sa meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/gitops-sa meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/jenkins-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/sower-service-account meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/useryaml-job meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite serviceaccount/workspace-token-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label serviceaccount/access-backend-sa app.kubernetes.io/managed-by=Helm
k label serviceaccount/default app.kubernetes.io/managed-by=Helm
k label serviceaccount/fence-sa app.kubernetes.io/managed-by=Helm
k label serviceaccount/gen3-discovery-ai-sa app.kubernetes.io/managed-by=Helm
k label serviceaccount/gitops-sa app.kubernetes.io/managed-by=Helm
k label serviceaccount/jenkins-service app.kubernetes.io/managed-by=Helm
k label serviceaccount/sower-service-account app.kubernetes.io/managed-by=Helm
k label serviceaccount/useryaml-job app.kubernetes.io/managed-by=Helm
k label serviceaccount/workspace-token-service app.kubernetes.io/managed-by=Helm
k annotate --overwrite secret/access-backend-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/arborist-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/audit-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/aws-es-proxy meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-access-backend-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ambassador-gen3-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ambassador-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ambtest-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-arborist-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-argo-wrapper-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-arranger-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-audit-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-audit-service-pdb meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-auspice-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-cedar-wrapper-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-cogwheel-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-cohort-middleware-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-devbot-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-dicom-server-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-dicom-viewer-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-esproxy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-external meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-fence-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-fence-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-fenceshib-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-fenceshib-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-frontend-framework-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-gdcapi-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-gen3-discovery-ai-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-google-sa-validation-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-guacamole-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-guacd-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-guppy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-hatchery-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-indexd-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-indexd-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-jenkins-agent-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-jenkins-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-jupyterhub-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-kayako-wrapper-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-kubecost-cost-analyzer-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-manifestservice-pdb meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-manifestservice-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-mariner-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-metadata-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ohdsi-atlas-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ohdsi-webapi-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ohif-viewer-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-orthanc-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-peregrine-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-peregrine-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-pidgin-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-portal-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-presigned-url-fence-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-qa-dashboard-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-requestor-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-revproxy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-sftp-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-sheepdog-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-sheepdog-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-shiny-nb2-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-shiny-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-sower-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-spark-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-ssjdispatcher-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-status-api-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-thor-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/cert-workspace-token-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/dashboard-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/dbfarm-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/es-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-config meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-google-app-creds-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-google-storage-creds-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-json-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-jwt-keys meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/fence-ssh-keys meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/gateway-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/gen3-discovery-ai-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/grafana-admin meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/indexd-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/indexd-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/mailgun-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/manifestservice-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/metadata-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/pelicanservice-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/peregrine-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/peregrine-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/portal-config meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/portal-sponsor-config meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/requestor-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/service-ca meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/sheepdog-creds meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/sheepdog-secret meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite secret/wts-g3auto meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonkk annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk

k label secret/access-backend-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/arborist-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/audit-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/aws-es-proxy  app.kubernetes.io/managed-by=Helm
k label secret/cert-access-backend-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ambassador-gen3-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ambassador-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ambtest-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-arborist-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-argo-wrapper-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-arranger-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-audit-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-audit-service-pdb  app.kubernetes.io/managed-by=Helm
k label secret/cert-auspice-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-cedar-wrapper-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-cogwheel-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-cohort-middleware-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-devbot-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-dicom-server-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-dicom-viewer-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-esproxy-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-external  app.kubernetes.io/managed-by=Helm
k label secret/cert-fence-canary-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-fence-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-fenceshib-canary-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-fenceshib-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-frontend-framework-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-gdcapi-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-gen3-discovery-ai-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-google-sa-validation-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-guacamole-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-guacd-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-guppy-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-hatchery-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-indexd-canary-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-indexd-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-jenkins-agent-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-jenkins-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-jupyterhub-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-kayako-wrapper-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-kubecost-cost-analyzer-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-manifestservice-pdb  app.kubernetes.io/managed-by=Helm
k label secret/cert-manifestservice-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-mariner-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-metadata-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ohdsi-atlas-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ohdsi-webapi-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ohif-viewer-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-orthanc-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-peregrine-canary-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-peregrine-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-pidgin-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-portal-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-presigned-url-fence-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-qa-dashboard-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-requestor-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-revproxy-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-sftp-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-sheepdog-canary-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-sheepdog-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-shiny-nb2-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-shiny-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-sower-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-spark-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-ssjdispatcher-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-status-api-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-thor-service  app.kubernetes.io/managed-by=Helm
k label secret/cert-workspace-token-service  app.kubernetes.io/managed-by=Helm
k label secret/dashboard-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/dbfarm-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/es-creds  app.kubernetes.io/managed-by=Helm
k label secret/fence-config  app.kubernetes.io/managed-by=Helm
k label secret/fence-creds  app.kubernetes.io/managed-by=Helm
k label secret/fence-google-app-creds-secret  app.kubernetes.io/managed-by=Helm
k label secret/fence-google-storage-creds-secret  app.kubernetes.io/managed-by=Helm
k label secret/fence-json-secret  app.kubernetes.io/managed-by=Helm
k label secret/fence-jwt-keys  app.kubernetes.io/managed-by=Helm
k label secret/fence-secret  app.kubernetes.io/managed-by=Helm
k label secret/fence-ssh-keys  app.kubernetes.io/managed-by=Helm
k label secret/gateway-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/gen3-discovery-ai-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/grafana-admin  app.kubernetes.io/managed-by=Helm
k label secret/indexd-creds  app.kubernetes.io/managed-by=Helm
k label secret/indexd-secret  app.kubernetes.io/managed-by=Helm
k label secret/mailgun-creds  app.kubernetes.io/managed-by=Helm
k label secret/manifestservice-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/metadata-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/pelicanservice-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/peregrine-creds  app.kubernetes.io/managed-by=Helm
k label secret/peregrine-secret  app.kubernetes.io/managed-by=Helm
k label secret/portal-config  app.kubernetes.io/managed-by=Helm
k label secret/portal-sponsor-config  app.kubernetes.io/managed-by=Helm
k label secret/requestor-g3auto  app.kubernetes.io/managed-by=Helm
k label secret/service-ca  app.kubernetes.io/managed-by=Helm
k label secret/sheepdog-creds  app.kubernetes.io/managed-by=Helm
k label secret/sheepdog-secret  app.kubernetes.io/managed-by=Helm
k label secret/wts-g3auto  app.kubernetes.io/managed-by=Helm
k annotate --overwrite  meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/config-helper meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/etl-mapping meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/fence meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/fence-config meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/fence-sshconfig meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/fence-yaml-merge meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/global meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/kube-root-ca.crt meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/locks meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/logo-config meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/logrotate-nginx-conf meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-all meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-arborist meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-arranger meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-canary meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-fence meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-global meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-guppy meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-hatchery meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-indexd meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-jenkins meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-jupyterhub meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-modsec meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-revproxy meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-scaling meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-sower meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/manifest-versions meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/privacy-policy meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/projects meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/revproxy-helper-js meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/revproxy-nginx-conf meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k annotate --overwrite configmap/revproxy-nginx-subconf meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk

k label configmap/config-helper  app.kubernetes.io/managed-by=Helm
k label configmap/etl-mapping  app.kubernetes.io/managed-by=Helm
k label configmap/fence  app.kubernetes.io/managed-by=Helm
k label configmap/fence-config  app.kubernetes.io/managed-by=Helm
k label configmap/fence-sshconfig  app.kubernetes.io/managed-by=Helm
k label configmap/fence-yaml-merge  app.kubernetes.io/managed-by=Helm
k label configmap/global  app.kubernetes.io/managed-by=Helm
k label configmap/kube-root-ca.crt  app.kubernetes.io/managed-by=Helm
k label configmap/locks  app.kubernetes.io/managed-by=Helm
k label configmap/logo-config  app.kubernetes.io/managed-by=Helm
k label configmap/logrotate-nginx-conf  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-all  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-arborist  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-arranger  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-canary  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-fence  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-global  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-guppy  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-hatchery  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-indexd  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-jenkins  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-jupyterhub  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-modsec  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-revproxy  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-scaling  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-sower  app.kubernetes.io/managed-by=Helm
k label configmap/manifest-versions  app.kubernetes.io/managed-by=Helm
k label configmap/privacy-policy  app.kubernetes.io/managed-by=Helm
k label configmap/projects  app.kubernetes.io/managed-by=Helm
k label configmap/revproxy-helper-js  app.kubernetes.io/managed-by=Helm
k label configmap/revproxy-nginx-conf  app.kubernetes.io/managed-by=Helm
k label configmap/revproxy-nginx-subconf app.kubernetes.io/managed-by=Helm

k annotate --overwrite rolebinding.rbac.authorization.k8s.io/devops-binding meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label rolebinding.rbac.authorization.k8s.io/devops-binding  app.kubernetes.io/managed-by=Helm
k annotate --overwrite rolebinding.rbac.authorization.k8s.io/sower-binding meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label rolebinding.rbac.authorization.k8s.io/sower-binding  app.kubernetes.io/managed-by=Helm
k annotate --overwrite rolebinding.rbac.authorization.k8s.io/useryaml-binding meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label rolebinding.rbac.authorization.k8s.io/useryaml-binding  app.kubernetes.io/managed-by=Helm

k annotate --overwrite service/access-backend-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/access-backend-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/arborist-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/arborist-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/esproxy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/esproxy-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/fence-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/fence-canary-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/fence-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/fence-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/gen3-discovery-ai-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/gen3-discovery-ai-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/guppy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/guppy-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/indexd-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/indexd-canary-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/indexd-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/indexd-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/metadata-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/metadata-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/peregrine-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/peregrine-canary-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/peregrine-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/peregrine-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/portal-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/portal-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/presigned-url-fence-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/presigned-url-fence-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/revproxy-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/revproxy-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/sheepdog-canary-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/sheepdog-canary-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/sheepdog-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/sheepdog-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/sower-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/sower-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/spark-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/spark-service  app.kubernetes.io/managed-by=Helm
k annotate --overwrite service/workspace-token-service meta.helm.sh/release-namespace=burtonk meta.helm.sh/release-name=burtonk
k label service/workspace-token-service  app.kubernetes.io/managed-by=Helm
