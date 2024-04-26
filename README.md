# Updated version of the Gen3 Helm chart for Openstack

updated version of the Gen3 Helm chart, which was utilized to deploy the application on the OpenStack platform.

## Notes:

The purpose of this example is to deploy Gen3 on the OpenStack platform using services native to OpenStack. Currently, the deployment of the Helm chart on OpenStack is in the evolutionary phase. We will share any changes in the evolution as they occur.

The example  openstack deployment is using:  
- External Database ( i.e dbCreate = false)
- elasticsearch sub-chart gen3-helm/helm/elasticsearch at feat/es-6.8.23 · uc-cdis/gen3-helm  
- Internal NeSI metadata service ( not using Gen3 Helm service)
- Ambassador Edge Stack as Ingress ( not using nginx ingress and not using Ambassador available in Gen3 community helm chart)

Providing openstack_dev_values.yaml file in the example folder, also updated values.yaml in sub chart where ever some customisations are needed, while submitting example all the customisation (as masked password, urls,…) are removed from the files  ( e.g etlmappings, gitops.json, guppy.json… ) are required by the deployment

## Changes to Gen3 chart

Some of the minor updates to Gen3 chart before proceeding with the deployments

- The _db_setup_job.tpl is {{- if or $.Values.global.postgres.dbCreate $.Values.postgres.dbCreate }} looks not considering dbCreate = false, to have  dbcreated: true condition in k8s secrets,  therefore excluded the condition 
- Using "helm-test" for sheepdog : with the latest images , we are getting below errors ,  then the chart is supporting "helm-test" instead.

Error: failed to start container "sheepdog": Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting "/var/lib/kubelet/pods/d09e604a-26ab-4de0-b6b1-6093dc3597a8/volume-subpaths/config-volume/sheepdog/0" to rootfs at "/var/www/sheepdog/settings.py" 

Therefore using  "helm-test"  sheepdog image with following  volumeMounts

```
volumeMounts:
  - name: "config-volume"
    readOnly: true
    mountPath: "/var/www/sheepdog/wsgi.py"
    subPath: "wsgi.py"
```


