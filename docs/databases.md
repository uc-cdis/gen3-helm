# Databases in gen3 helm charts
This document will describe how databases are provisioned, and used in gen3 when deploying gen3 with helm charts. 

We hihgly recommend the use of a managed postgres service such as AWS RDS/Aurora, or manage postgres outside of the helm deployment, when deploying gen3 to production environments. 

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

