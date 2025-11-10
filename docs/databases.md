# Databases in gen3 helm charts
This document will describe how databases are provisioned, and used in gen3 when deploying gen3 with helm charts. 

We highly recommend the use of a managed postgres service such as AWS RDS/Aurora, or manage postgres outside of the helm deployment, when deploying gen3 to production environments. 

The bundled version of postgres, that is used for development purposes, is deployed using this helm chart https://bitnami.com/stack/postgresql/helm

## Database credentials

Every service that requires a postgres database, has the it's credentials stored in a kubernetes secret. 

Example (The secret values have been base64 decoded for documentation purposes): 

```yaml
kubectl get secret fence-dbcreds -o yaml
apiVersion: v1
kind: Secret
data:
  database: fence_gen3             # The default value of this is <service_name>_<release_name>
  dbcreated: true                  # This is updated by the dbCreate job, when a database is created, and configured. 
  host: gen3-postgresql            # Default depends on whether or not `global.dev` is true or false. If it's true this will default to <release_name>-postgresql. If this is a production deployment, it will look for either `global.postgres.master.host` or `postgres.host` in the Values.yaml
  password: example_pass           # If not explicitely provided via the values, this is auto-generated.   
  port: 5432                       # Defaults to 5432, will read from `global.postgres.master.port` or `postgres.port` for ovverrides.
  username: fence_gen3             # Defaults to <service_name>_<release_name>. Will look for overrides in `postgres.username`.
```

Each service then consumes this same secret and mounts them as ENV vars to access databases. 

For production deployments you must at minimum provide the master credentials for a postgres server through these values. 

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

These values can then be used to provision and configure databases for the gen3 environment.

## Automatic database creation through jobs


If you set the `global.postgres.dbCreate` value to true, then a job is kicked off for each service that relies on postgres to provision databases. 

This will kick off a [database creation job](../helm/common/templates/_db_setup_job.tpl)


<!-- Describe the database creation job -->


## Database restoration. (BETA)
There is a job to restore dummy data for Postgres and Elasticsearch to speed up setting up ephemeral enviornments for testing purposes, and to avoid running expensive ETL jobs in CI to have a fully featured gen3 environment

In the future this job may be used to set up fully tested production environments, negating the need to run ETL in production, and have all your databases tested before doing a data-release.

## Bootstrapping Databases with External Secrets & AWS Secrets Manager

Gen3 can create database credentials, keep them as **local Kubernetes Secrets**, or **push them to AWS Secrets Manager and sync back via External Secrets**.

### TL;DR behavior

- **Local only**: If **both** `global.externalSecrets.deploy` and `global.externalSecrets.dbCreate` are `true` **and no push flag is set**, the DB create job runs and writes a **local K8s Secret only**.
- **Push to Secrets Manager**: If `global.externalSecrets.deploy` is `true` **and** `global.externalSecrets.dbCreate` is `false` **and** either:
  - `global.externalSecrets.pushSecret` is `true`, **or**
  - `<service>.externalSecrets.pushSecret` is `true` (per-service),
  
  then the secret is **pushed to AWS Secrets Manager**, and **External Secrets** syncs it back to Kubernetes.  

---

### Values for enabling pushSecret Bootstrap

**Global:**
```yaml
global:
  externalSecrets:
    deploy: true        # required to enable any of this flow
    dbCreate: false     # create DB + credentials (set true if you want to create the local k8s secret and not use Secrets Manager for the database secrets.)
    pushSecret: true    # Will create the database and push the secret to Secrets Manager to then be used by External Secrets.
  postgres:
    externalSecret: "<name of master Postgres secret in Secrets Manager>" # This value is required for the db create job unless you are using a local Postgres.
```

**Per service:**
```yaml
<service-name>:
  postgres:
    dbCreate: true      # enable DB creation for this service (optional if handled globally)
  externalSecrets:
    dbcreds: "<name of the secret that will be created in secrets manager>" # Name for the service-specific DB secret
    # pushSecret: true  # optional per-service override to push
```

**Notes**
- pushSecret configuration will ensure database credentials are generated, stored in your Secrets Manager, and made available for automated deployments and recovery.
- Pushsecret resource will never overide or replace your Secrets Manager Secret unless the AWS resource is deleted.