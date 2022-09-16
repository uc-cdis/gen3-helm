# gen3-helm
Helm charts for Gen3 Deployments


# Local deployment

## Prerequisites

### Kubernetes
It is suggested to use [Rancher Desktop](rancherdesktop.io/) as Kubernetes on your laptop, especially on M1 Mac's

### Postgres 
We need a postgres deployment, for databases and stuff. 

Our helm charts expects this postgres installation in a namespace called `postgres` 



```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql -n postgres --create-namespace
```


After deployment we also need to create databases for our services (This is going to be automated in future versions)

To create databases run this 

```
export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgres postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

kubectl run postgres-postgresql-client --rm --tty -i --restart='Never' --namespace postgres --image docker.io/bitnami/postgresql:14.5.0-debian-11-r6 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgres-postgresql -U postgres -d postgres -p 5432

```

Once you get a PSQL shell into postgres create databses by running the following
```
CREATE DATBASE arborist;
CREATE DATBASE audit;
CREATE DATBASE fence;
CREATE DATBASE indexd;
CREATE DATBASE metadata;
CREATE DATBASE peregrine;
CREATE DATBASE sheepdog;
```


You should now be ready to deploy the helm charts from this repository. 


# Google login

You need to set up a google credential for google login as that's the default enabled option in fence. 


The following steps explain how to create credentials for your gen3

Go to the [Credentials page](https://console.developers.google.com/apis/credentials).

Click Create credentials > OAuth client ID.

Select the Web application application type.
Name your OAuth 2.0 client and click Create.

For `Authorized Javascript Origins` add `https://localhost`

For `"Authorized redirect URIs"` add  `https://localhost/user/login/google/login/` 

After configuration is complete, take note of the client ID that was created. You will need the client ID and client secret to complete the next steps. 


## Helm chart deployment

### Install all charts
```
cd ./helm
for i in $(ls); do helm upgrade --install $i ./$i; done
```

### Install fence with google login secrets

```
helm upgrade fence ./fence --set FENCE_CONFIG.OPENID_CONNECT.google.client_id="xxx" --set FENCE_CONFIG.OPENID_CONNECT.google.client_secret="YYYYY"

```

To restart fence to pick up these changes run 

```
kubectl rollout restart deployment fence-deployment
```

### Install WTS 

WTS is a service that needs a fence client. We need to manually create this client and populate the values for WTS using the following steps

1. Make sure fence is running and is healthy
2. Exec into a running fence pod and generate a fence client for WTS by runningthe following commands
```
kubectl exec -it <FENCE-POD> bash
fence-create client-create --client wts --urls https://localhost/wts/oauth2/authorize --username wts
```

Note down the client_id and secret and install wts again by running this command

```
helm upgrade wts . --set oidc_client_id=<CLIENT_ID> --set oidc_client_secret=<CLIENT_SECRET>
```

# Production Deployment
These helm charts are not yet ready for production, but check back again soon. 