# Databases in gen3 helm charts
This document will describe how databases are provisioned in gen3 when deploying with helm charts

## Database credentials
The detault behaviour of gen3 helm charts is to auto-generate database credentials and save them as kubernetes secrets. 

Each service then consumes this same secret and mounts them as ENV vars to access databases. 

You can override this default behaviour by providing postgres credentials through Values.yaml files.

If you are deploying a dev/CI environment, a postgres server is deployed alongside gen3, and that is used to hold databases for testing. 

For production deployments you need to provide the master credentials for a postgres server through these values. 

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

These values will then be used to provision databases for the environment.

## Automatic database creation through jobs
When deploying gen3 helm charts you need to specifiy a postgres server. For dev/CI environments an installation of postgres is included, and is not intended for use in production. 

We hihgly recommend the use of a managed postgres service such as RDS when deploying gen3 to cloud environments. 

The dev/ci postgres is deployed using this helm chart https://bitnami.com/stack/postgresql/helm

If you set the `global.postgres.db_create` value to true, then a job is kicked off for each service that relies on postgres to provision databases. 

This will kick off a [database creation job](../helm/common/templates/_db_setup_job.tpl)




## Database restoration.
There is a job to restore dummy data for Postgres and Elasticsearch to speed up setting up ephemeral enviornments for testing purposes, and to avoid running expensive ETL jobs in CI to have a fully featured gen3 environment

In the future this job may be used to set up fully tested production environments, negating the need to run ETL in production, and have all your databases tested before doing a data-release.

