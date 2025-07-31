# Pre-Requisites

Before deploying the Gen3 application using Helm, ensure that the following prerequisites are met:

- Kubernetes cluster with minimum version 1.21. We use [Amazon EKS](#) for our production deployments

- 

- Postgres 13.

  - We use Amazon aurora serverless v2 for our production deployments. 
  - **Note:** Managing a database on Kubernetes can be a complex topic, and may result in data loss. We recommend using a managed database service outside of Kubernetes. In production, we use Amazon Aurora Serverless V2 or RDS for Postgres.
  - It is possible for development purposes to run Postgres on kubernetes, if you set `global.dev=true` in your `Values.yaml` file, the postgres will be deployed. See [this document](docs/databases.md) for more information on running postgres on kubernetes



- Elasticsearch version 7.10 
  - **Note:** Managing elasticsearch on Kubernetes can be a complex topic, and may result in data loss. We recommend using a managed elasticsearch service outside of Kubernetes. In production, we use Amazon Opensearch service for Elasticsearch. 




## Prerequisites

### Kubernetes cluster
Any kubernetes cluster _should_ work. We are testing with EKS, AKS, GKE.


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

This will create a [PVC]() for the postgres container. Unfortunately, helm [does not delete PVC on uninstall](https://github.com/helm/helm/issues/5156), so if you enable persistence you might have to manually clean this up between installs by running the following command: 

```bash
kubectl delete pvc data-<release-name>-postgresql-0
```


**NOTE**: Gen3 will autogenerate the secrets for postgres if you delete and re-install, unless the credentials for each service are supplied via the values.yaml

In cases where you are using persistent postgres, provide the postgres username and password explicitely using the values.yaml file, so the gen3 deployments will skip generating those credentials. 

Example: 

```
arborist:
  postgres:
    dbCreate: true
    username: gen3_arborist
    password: <password>

(Repeat for all services)
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
