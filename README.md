
# gen3-helm
<img src="docs/images/gen3-blue-dark.png" width=250px>


Helm charts for deploying [Gen3](https://gen3.org) on any kubernetes cluster.

# Deploying gen3 with helm

## TL;DR 
```
helm repo add gen3 https://helm.gen3.org
helm repo update
helm upgrade --install gen3 gen3/gen3 -f ./values.yaml 
```

Assuming you already have the [prerequisites](./docs/PREREQUISITES.md) installed and configured, you can deploy Gen3 with the helm command.


> **Warning**
> The default Helm chart configuration is not intended for production. The default chart creates a proof of concept (PoC) implementation where all Gen3 services are deployed in the cluster, including postgres and elasticsearch. For production deployments, you must follow the [Production/Cloud Native/Hybrid architecture](./docs/PRODUCTION.md)


For a production deployment, you should have strong working knowledge of Kubernetes. This method of deployment has different management, observability, and concepts than traditional deployments.

In a production deployment:

- The stateful components, like PostgreSQL or Elasticsearch, must run outside the cluster on PaaS or compute instances. This configuration is required to scale and reliably service the variety of workloads found in production Gen3 environments.

- You should use Cloud PaaS for PostgreSQL, Elasticsearch, and object storage.


## Configuration

For a full set of configuration options see the [CONFIGURATION.md](./docs/CONFIGURATION.md) for a more in depth instructions on how to configure each service. 

There's also an auto-generated table of basic configuration options here: 

[README.md for gen3 chart](./helm/gen3/README.md) (auto-generated documentation) or 


To see documentation around setting up gen3 developer environments see [gen3_developer_environments.md](./docs/gen3_developer_environments.md)


Use the following as a template for your `values.yaml` file for a minimum deployment of gen3 using these helm charts.



```yaml
global:
  hostname: example-commons.com

fence: 
  FENCE_CONFIG:
    # Any fence-config overrides here. 
```



## Selective deployments 
All gen3 services are sub-charts of the gen3 chart (which acts as an umbrella chart). 

For your specific installation of gen3, you may not require all our services.


To enable or disable a service you can use this pattern in your `values.yaml`

```yaml
fence:
  enabled: true

wts:
  enabled: false
```

## Gen3 Login Options
Gen3 does not have any IDP, but can integrate with many. We will cover Google login here, but refer to the fence documentation for additional options. 

TL/DR: At minimum to have google logins working you need to set these settings in your `values.yaml` file

```
fence: 
  FENCE_CONFIG:
    OPENID_CONNECT:
      google:
        client_id: "insert.google.client_id.here"
        client_secret: "insert.google.client_secret.here"
```


#### Google login generation

You need to set up a google credential for google login as that's the default enabled option in fence. 


The following steps explain how to create credentials for your gen3

Go to the [Credentials page](https://console.developers.google.com/apis/credentials).

Click Create credentials > OAuth client ID.

Select the Web application application type.
Name your OAuth 2.0 client and click Create.

For `Authorized Javascript Origins` add `https://<hostname>`

For `"Authorized redirect URIs"` add  `https://<hostname>/user/login/google/login/` 

After configuration is complete, take note of the client ID that was created. You will need the client ID and client secret to complete the next steps. 

# Production deployments
Please read [this](./docs/PRODUCTION.md) for more details on production deployments. 

NOTE: Gen3 helm charts are currently not used in production by CTDS, but we are aiming to do that soon and will have additional documentation on that.

# Local Development

For local development you must be connected to a kubernetes cluster. As referenced above in the section `Kubernetes cluster` we recommend using [Rancher Desktop](https://rancherdesktop.io/) as Kubernetes on your local machine, especially on M1 Mac's. You also get ingress and other benefits out of the box.

For MacOS users, [Minikube](https://minikube.sigs.k8s.io/docs/start/) equipped with the ingress addon serves as a viable alternative to Rancher Desktop. On Linux, we've observed that using [Kind](https://kind.sigs.k8s.io/) with an NGINX ingress installed often provides a more seamless experience compared to both Rancher Desktop and Minikube. Essentially, Helm requires access to a Kubernetes cluster with ingress capabilities, facilitating the loading of the portal in your browser for an optimal development workflow.

> **Warning**
> If you are using Rancher Desktop you need to increase the vm.max_map_count as outlined [here](https://docs.rancherdesktop.io/how-to-guides/increasing-open-file-limit/)
> If you are using Minikube you will need to enabled the ingress addon as outlined [here](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

1. Clone the repository
2. Navigate to the `gen3-helm/helm/gen3` directory and run `helm dependency update`
3. Navigate to the back to the `gen3-helm` directory and create your values.yaml file. See the `TL;DR` section for a minimal example.
4. Run `helm upgrade --install gen3 ./helm/gen3 -f ./values.yaml`

## Using Skaffold

Skaffold is a tool for local development that can be used to automatically rebuild and redeploy your application when changes are detected. A minimal skaffold.yaml configuration file has been provided in the gen3-helm directory. Update the values of this file to match your needs.

Follow the steps above, but instead of doing the helm upgrade --install step, use `skaffold dev` to start the development process. Skaffold will automatically build and deploy your application to your kubernetes cluster. 

# Troubleshooting

## Sanity checks

* If deploying from the local repo, make sure you followed the steps for `helm dependency update`. If you make any changes, this must be repeated for those changes to propagate.

## Debugging helm chart issues

* Sometimes there are cryptic errors that occur during use of the helm chart, such as duplicate env vars or other items. Try rendering the resources to a file, in debug mode, and it will help determine where the issues may be taking place

`helm template --debug gen3 ./helm/gen3 -f ./values.yaml > test.yaml`
