# Database Migrations with dbmate (gen3-helm)

How service charts run [dbmate](https://github.com/amacneil/dbmate) schema migrations (Gen3 AI services and eventually more - as this is our preferred way). Other services relying on older alembic migrations have a different strategy, for example see
[fence-db-migration.md](fence-db-migration.md).

# Overview

Migrations run **once per deploy, in a single Job**, and the service's pods wait for them before
serving. Two shared templates in `helm/common` provide this, so a chart adopting dbmate does not
need to write its own Job:

| Template                    | Emits                                          | Purpose              |
| --------------------------- | ---------------------------------------------- | -------------------- |
| `common.db_migrate_job`     | `<chart>-dbmigrate-<hash>` Job                 | Runs on every deploy |
| `common.db_migrate_cronjob` | `<chart>-dbmigrate-cronjob` CronJob, suspended | Manual re-runs       |

## Why a Job rather than an initContainer

dbmate does not lock while migrating. `Migrate()` reads the set of applied versions once, before
applying anything, and never re-checks it inside the loop. Two concurrent processes therefore
compute the same pending list and both try to apply it.

Running migrations from a Deployment initContainer starts one process per replica, so the race
appears as soon as `replicaCount` exceeds 1. A Job with `parallelism: 1` has exactly one writer.

# Configuring a chart

```yaml
postgres:
  migrations:
    # Run migrations as a Job, and make the deployment wait for them.
    enabled: true
    # Directory inside the service image holding dbmate migrations.
    dir: /services/gen3_embeddings/db/migrations
    # sslmode for the migration connection.
    sslmode: disable
```

`dir` is image-specific and has no default worth guessing - `SOMETHING/db/migrations`
is a common pattern for dbmate, but what SOMETHING is depends on the service itself and how it adds these during image build. There is also a `global.postgres.migrations` block with the same keys, which
acts as a cluster-wide default in case we align; but the per-chart value wins.

In addition to the above config, for new services adopting dbmate migration: include both templates from the chart's `templates/db-init.yaml`:

```
{{ include "common.db_migrate_job" . }}
---
{{ include "common.db_migrate_cronjob" . }}
```

Both are gated internally on `enabled`, so an unadopted chart can include them safely.

## How the deployment waits

The Deployment's initContainer should poll `dbmate status --quiet` and starts the app once nothing is
pending. It deliberately polls the **database**, not the Job: `ttlSecondsAfterFinished` reaps the
Job an hour after it completes, so a replica starting later - a scale-up, an eviction, a crash
restart - would otherwise wait on an object that no longer exists.

`dbmate status --quiet` exits 0 with nothing pending, 1 with migrations pending, and 2 on any
other error. The wait loop should treat 1 as expected and give 2 a bounded retry, so a bad DSN fails
the pod after roughly 150 seconds instead of hanging in `Init` indefinitely.

With `enabled: false` there is no Job, so the initContainer is not rendered at all.

# Ordering, and the DBREADY gate

The migration Job must not run before the database exists. That ordering is not expressed with
Helm or ArgoCD hooks - it comes from the same mechanism the Deployments already use.

`common.db_setup_job` creates the database, role and extensions, then patches a `dbcreated` key
into `<chart>-dbcreds`. `common.db-secret` does not create that key. The migration Job references
it as `DBREADY` with `optional: false`, so the pod sits in `CreateContainerConfigError` and
retries until the key appears. Nothing reads the value; it is purely a sentinel.

A Helm `pre-install`/`pre-upgrade` hook won't work here. ArgoCD maps those to `PreSync`, which must complete before the Sync phase - but
`<chart>-dbcreate` runs *in* Sync, so a PreSync migration hook would wait on a database queued
behind it. Both Jobs belong in the same phase.

# Manual migrations

The CronJob is suspended and scheduled for February 31st, so it never fires on its own. It exists
as a template to trigger by hand, following the same idiom as `fence-db-migrate-cronjob`:

```bash
kubectl create job \
  --from=cronjob/gen3-embeddings-dbmigrate-cronjob \
  gen3-embeddings-dbmigrate-manual

kubectl logs -f job/gen3-embeddings-dbmigrate-manual
```

Use it for backfills, for re-running after a failed deploy, or to migrate without a full release.

# Operational notes

**The Job name contains a hash** of the image tag, migrations directory and sslmode. An unchanged
deploy re-applies an identical spec, which is a no-op, so the Job never needs deleting first.
A new image tag produces a new Job that runs. Editing the Job spec in
`_db_migrate_job.tpl` without changing any hashed input requires deleting the old Job once.

**Pods carry `app: gen3job`.** `common.db_netpolicy` grants
database egress to `app in (<chart>, gen3job)`, so a migration pod without that label cannot reach
Postgres wherever network policies are enabled. It is also how the observability stack finds Gen3
job logs in Loki.

**Migrations connect as the Postgres master user**, not the service user, because some migrations
need privileges the service role lacks. `activeDeadlineSeconds` is deliberately unset - a
container-create failure does not consume `backoffLimit`, so waiting on `dbcreated` is safe, but a
deadline would kill the Job while it waits.