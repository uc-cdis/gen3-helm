# Databases in gen3 helm charts
This document will describe how databases are provisioned, and used in gen3 when deploying gen3 with helm charts. 

We highly recommend the use of a managed postgres service such as AWS RDS/Aurora, or manage postgres outside of the helm deployment, when deploying gen3 to production environments. 

The bundled version of postgres, that is used for development purposes, is deployed using this helm chart https://bitnami.com/stack/postgresql/helm

## Database credentials

Every service that requires a postgres database, has its credentials stored in a kubernetes secret.

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


## Schema migrations

Creating the database is separate from migrating its schema. The creation job provisions the
database, role and extensions, then signals completion by patching a `dbcreated` key into
`<service>-dbcreds`; applying migrations on top of that is the service's own step.

Charts using [dbmate](https://github.com/amacneil/dbmate) get a shared migration Job from
`helm/common`, with the service's pods waiting for it rather than migrating themselves. See
[database-migrations.md](database-migrations.md). Fence uses `fence-create migrate` instead, in
[fence-db-migration.md](fence-db-migration.md).


## Database restoration. (BETA)
There is a job to restore dummy data for Postgres and Elasticsearch to speed up setting up ephemeral enviornments for testing purposes, and to avoid running expensive ETL jobs in CI to have a fully featured gen3 environment

In the future this job may be used to set up fully tested production environments, negating the need to run ETL in production, and have all your databases tested before doing a data-release.

## Bootstrapping Databases with External Secrets & AWS Secrets Manager

Gen3 can create database credentials, keep them as **local Kubernetes Secrets**, or **push them to AWS Secrets Manager and sync back via External Secrets**.

### TL;DR behavior

- **Local only**: If **both** `global.externalSecrets.deploy` and `global.externalSecrets.createLocalK8sSecret` are `true` **and no push flag is set**, the DB create job runs and writes a **local K8s Secret only**.
- **Push to Secrets Manager**: If `global.externalSecrets.deploy` is `true` **and** `global.externalSecrets.createLocalK8sSecret` is `false` **and** either:
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
    createLocalK8sSecret: false     # create DB + credentials (set true if you want to create the local k8s secret and not use Secrets Manager for the database secrets.)
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

### How the pushSecret bootstrap works

With `pushSecret` enabled for a service, `<service>-dbcreds` is an ExternalSecret that pulls
`<externalSecrets.dbcreds>` from Secrets Manager. For a new service that remote secret does not
exist yet, so the `<service>-dbcreate` Job creates it:

1. Helm renders `<service>-dbcreds-bootstrap`, a local Secret with generated credentials.
2. The `<service>-dbcreate` Job starts from the bootstrap credentials. If `<service>-dbcreds`
   already exists (synced from Secrets Manager), the Job uses those instead: Secrets Manager is
   the source of truth once populated.
3. The Job creates the role (or resets its password to match) and the database, using the master
   credentials from `global.postgres.externalSecret`.
4. The Job copies the resolved credentials and host into the bootstrap Secret and applies a
   `PushSecret` (`updatePolicy: IfNotExists`), then waits for it to be Ready.
5. External Secrets syncs the remote secret back into `<service>-dbcreds`, and the service starts.

Re-running the Job is safe: an existing remote secret is never overwritten, and the role password
is reset to the value in Secrets Manager.

### Adding a new service to an environment that uses External Secrets

Keep External Secrets on globally and enable the push only for the new service:

```yaml
global:
  externalSecrets:
    deploy: true
    createLocalK8sSecret: false
  postgres:
    dbCreate: true
    externalSecret: "<master Postgres secret in Secrets Manager>"

<service-name>:
  externalSecrets:
    dbcreds: "<remote secret name>"   # defaults to <global.environment>-<service>-creds
    pushSecret: true
```

Existing services keep pulling their credentials from Secrets Manager; only `<service-name>` is
bootstrapped.

To verify:

```bash
kubectl logs job/<service>-dbcreate          # ends with "PushSecret is Ready"
kubectl get pushsecret <service>-dbcreds      # Ready=True
kubectl get externalsecret <service>-dbcreds  # SecretSynced
```

### Pitfalls

- **Do not set `global.externalSecrets.createLocalK8sSecret: true` to bootstrap one service.** It is
  global: every service switches from its Secrets Manager credentials to locally rendered ones
  with default names (`<service>_<release>`), and the dbcreate Jobs create new, empty databases
  for them. Running pods keep working until they restart.
- **Locally rendered passwords are not stable under ArgoCD.** The charts use `lookup` to keep an
  existing password, and `lookup` returns nothing under ArgoCD, so a new random password is
  generated on every render. Prefer `pushSecret`, which stores the password once in Secrets
  Manager.
- **The dbcreate Job has a fixed name and an immutable spec.** If a chart change modifies the Job,
  delete the existing `<service>-dbcreate` Job so it can be recreated (completed Jobs are also
  removed automatically after `ttlSecondsAfterFinished`).
- **Recovering a broken bootstrap for a service with no data:** drop the service's database and role,
  then delete `<service>-dbcreate` so it runs again. The Job recreates both with the credentials
  already in Secrets Manager.
