# Documentation for Building a static Gen3 Portal

## Introduction:

The Gen3 Portal is a highly configurable application, but this can come at a cost in terms of performance. 

The gen3 data-portal has traditionally done WebPack builds at runtime, which can slow down the start-up time and consume a lot of resources. 

In order to address this issue, we can pre-run the WebPack build and create the static files, and then serve them using nginx. 

This documentation will provide instructions on how to set up a static Gen3 Portal Dockerfile to improve the performance of the Gen3 Portal, especially in resource constrained environments.


## Instructions:

Setup the configuration locally on your machine.

The dockerfile expects your portal configuration under the configurations folder. See example for `dev.planx-pla.net` 

```
configurations
  dev.planx-pla.net
    gitops.json
    gitops.css
    ....
```

Once you have set up the configuration, make sure these endpoints are available, as the portal build will query them: 

```
https://<hostname>/api/v0/submission/getschema
https://<hostname>/api/v0/submission/_dictionary/_all 
```

<!-- TODO: Verify -->
**Hint:** both of these are served via sheepdog service


Use the provided Dockerfile as a template for building your container. Update:
```
ARG PORTAL_HOSTNAME=<hostname>
```

Build your container using the following command inside the same folder as the Dockerfile: 

```
docker build -t <image_name>:<image_tag> .
```

If you are using localhost, you will need to add the `--network="host"` option in the above command, e.g:
```
docker build -t <image_name>:<image_tag> . --network="host"
```
Push the container to your repository using the command: 

```
docker push <image_name>:<image_tag>
```

Update the image and tag in the Gen3 Portal configuration to use the new container.

Note: Make sure to replace the <image_name> with the actual name you want to give to your image.

Update or create the `values.yaml`, for example:
```
global:
  dev: true
  hostname: localhost

portal:
  image: 
    repository: <image_name> 
    tag: <image_tag>
  resources:
    requests:
      cpu: 0.2
      memory: 500Mi
```

Update helm charts
```
helm upgrade --install dev gen3/gen3  -f values.yaml
```
# Conclusion:
Using a static Gen3 Data Portal can significantly improve the performance of the Gen3 Portal by pre-running the WebPack build and creating static files, which are then served using nginx.


