
# gen3-helm
<img src="docs/images/gen3-blue-dark.png" width=250px>


Helm charts for deploying [Gen3](https://gen3.org) on any kubernetes cluster.

# Deployment instructions
For a full set of configuration options see the [README.md for gen3](./helm/gen3/README.md)

## TL;DR 
```
helm repo add gen3 http://helm.gen3.org
helm upgrade --install gen3 gen3/gen3 -f ./values.yaml 
```

Use the following as a template for your `values.yaml` file for a minimum deployment of gen3 using these helm charts.



```
global:
  hostname: example-commons.com

fence: 
  FENCE_CONFIG:
    OPENID_CONNECT:
      google:
        client_id: "insert.google.client_id.here"
        client_secret: "insert.google.client_secret.here"
```

This is to have a gen3 deployment with google login. You may also use MOCK_AUTH using the following config. NB! This will bypass any login and is only recommended for testing environments


```
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
To enable or disable a service you can add this pattern to your values.yaml

```
fence:
  enable: true

wts:
  enable: false
```


## Prerequisites

### Kubernetes cluster
Any kubernetes cluster _should_ work. We are testing with EKS, AKS, GKE and Rancher Desktop. 

It is suggested to use [Rancher Desktop](https://rancherdesktop.io/) as Kubernetes on your laptop, especially on M1 Mac's. You also get ingress and other benefits out of the box. 

### Postgres 
We need a postgres database. For development/CI clusters an instance of postgres is deployed and automatically configured for you.

For production environments please fill out these values and provide a master password for postgres

```
global:
  postgres:
    db_create: true
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
