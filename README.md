
# gen3-helm
<img src="docs/images/gen3-blue-dark.png" width=250px>


Helm charts for deploying [Gen3](https://gen3.org) on any kubernetes cluster.

# Scope of Helm charts
Helm is a package manager for Kubernetes that simplifies the deployment and management of complex applications. Helm manages Kubernetes manifests as "charts" that can be installed, upgraded, and deleted with a single command. Helm enables versioned releases, templated configuration, and dependency management of Kubernetes resources.

Helm is responsible for managing Kubernetes applications and resources, but not the underlying infrastructure. Helm can deploy and manage Kubernetes applications such as deployments, services, and ingress resources. 

The Gen3-helm charts contain both Postgres and Elasticsearch, and although we make "best efforts" to ensure they work together seamlessly, we strongly advise managing these components separately from the Gen3 helm charts. Please note that these components are only included in the charts for testing purposes.



# Pre-Requisites



Before deploying the Gen3 application using Helm, ensure that the following prerequisites are met:

- Kubernetes with minimum version 1.21. We use [Amazon EKS](#) for our production deployments

- Postgres 13.

  - We use Amazon aurora serverless v2 for our production deployments. 
  - **Note:** Managing a database on Kubernetes can be a complex topic, and may result in data loss. We recommend using a managed database service outside of Kubernetes. In production, we use Amazon Aurora Serverless V2 or RDS for Postgres.
  - It is possible for development purposes to run Postgres on kubernetes, if you set `global.dev=true` in your `Values.yaml` file, the postgres will be deployed. See [this document](docs/databases.md) for more information on running postgres on kubernetes



- Elasticsearch version 6.8
  - **Note:** Managing elasticsearch on Kubernetes can be a complex topic, and may result in data loss. We recommend using a managed elasticsearch service outside of Kubernetes. In production, we use Amazon Opensearch service for Elasticsearch. 
  - We are working on supporting newer versions of elasticsearch in gen3, and should soon support ES7/8, but as of now we require version 6.8


# Deployment instructions
For a full set of configuration options see the [README.md for gen3](./helm/gen3/README.md) (auto-generated documentation) or [CONFIGURATION.md](./docs/CONFIGURATION.md) for a more in depth instructions on how to configure each service. 

To see documentation around setting up gen3 developer environments see [gen3_developer_environments.md](./docs/gen3_developer_environments.md)

## TL;DR 
```
helm repo add gen3 https://helm.gen3.org
helm repo update
helm upgrade --install gen3 gen3/gen3 -f ./values.yaml 
```

Use the following as a template for your `values.yaml` file for a minimum deployment of gen3 using these helm charts.



```yaml
global:
  # Do not deploy postgres and elasticsearch
  dev: false
  hostname: example-commons.com
  postgres:
    master:
      host: <postgres-hostname>
      username: <postgres-username>
      password: <postgres-password>

fence: 
  FENCE_CONFIG:
    OPENID_CONNECT:
      google:
        client_id: "insert.google.client_id.here"
        client_secret: "insert.google.client_secret.here"
```

This is to have a gen3 deployment with google login. You may also use MOCK_AUTH using the following config. NB! This will bypass any login and is only recommended for testing environments


```yaml
global:
  hostname: example-commons.com

fence: 
  FENCE_CONFIG:
    # if true, will automatically login a user with username "test"
    # WARNING: DO NOT ENABLE IN PRODUCTION (for testing purposes only)
    MOCK_AUTH: true
```


## Selective deployments 
All service helm charts are sub-charts of the gen3 chart (which acts as an umbrella chart)
To enable or disable a service you can add this pattern to your `values.yaml`

```yaml
fence:
  enabled: true

wts:
  enabled: false
```


## Prerequisites

### Kubernetes cluster
Any kubernetes cluster _should_ work. We are testing with EKS, AKS, GKE and Rancher Desktop. 

It is suggested to use [Rancher Desktop](https://rancherdesktop.io/) as Kubernetes on your laptop, especially on M1 Mac's. You also get ingress and other benefits out of the box. 


### Postgres 

We recommend managing postgres outside of Gen3 deployments, so your deployments are stateless, and the state of gen3 is managed outside of the helm deployments. This way you may upgrade, or take down the helm deployments, and can restore the state of your gen3 deployment. 

However, there is a possibility to run postgres on kubernetes, alongside gen3 for development purposes. 

To deploy `postgres` and `elasticsearch` that is bundled with gen3 helm charts set the `global.dev` to true.  By default these will run with no persistence storage enabled, and are mostly for CI/Development environments. 

If you want to enable persistence for postgres add the following to your values.yaml file for the gen3 chart

```
postgresql:
  primary:
    persistence:
      enabled: true
```

This will create a [PVC]() for the postgres container. Unfortunately, helm [does not delete PVC on uninstall](https://github.com/helm/helm/issues/5156), so if you enable persistence you might have to manually clean this up between installs.  


**NOTE**: Gen3 will autogenerate the secrets for postgres if you delete and re-install, unless the credentials for each service are supplied via the values.yaml

In cases where you are using persistent postgres, provide the postgres username and password explicitely using the values.yaml file, so the gen3 deployments will skip generating those credentials. 

Also provide the password for a user with permissions to create databases and roles in postgres. Normally the `postgres` user. This should be set in the `global.postgres.master` section of the configuration. 

Example: 

```

global:
  # Postgres and elasticsearch should not be deployed in k8s. 
  dev: false
  # 
  postgres:
    master: 
      host: <Hostname for Postgres>
      username: postgres
      password: <Password>
      port: "5432"

arborist:
  postgres:
      # -- (bool) Whether the database should be created using the dbcreate jobs.
    dbCreate: true
    username: gen3_arborist
    password: <password>

(Repeat for all services)
```

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






For a detailed description of each service and it's configuration options see [CONFIGURATION.md](./docs/CONFIGURATION.md) for more information. 


 
We need a postgres database. 

For development/CI clusters an instance of postgres is deployed and automatically configured for you.

For production environments please provision postgres outside of helm, and fill out these values to provide a master password for postgres.

```
global:
  postgres:
    dbCreate: true
    master:
      host: insert.postgres.hostname.here
      username: postgres
      password: <Insert.Password.Here>
      port: "5432"
```


### Login Options
Gen3 does not have any IDP, but can integrate with many. We will cover Google login here, but refer to the fence documentation for additional options. 

TL/DR: At minimum to have google logins working you need to set these settings in your `values.yaml` file

```
global:
  aws:
    # If you're deploying to an EKS set this to true. This will annotate ingress/service accounts appropriately. 
    # In the future we will be adding support for GKE/AKS using same method.
    enabled: true
      aws_access_key_id: 
      aws_secret_access_key:
  postgres:
    master:
      host: "rds.host.com"
      username: "postgres"
      password: "test"
      port: "5432"
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
For production deployments you have to use an external postgres server and elasticsearch server.

NOTE: Gen3 helm charts are currently not used in production by CTDS, but we are aiming to do that soon and will have additional documentation on that.

# Local Development

For local development you must be connected to a kubernetes cluster. As referenced above in the section `Kubernetes cluster` we recommend using [Rancher Desktop](https://rancherdesktop.io/) as Kubernetes on your local machine, especially on M1 Mac's. You also get ingress and other benefits out of the box.

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
