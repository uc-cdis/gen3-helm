# Database Migrations with dbmate (gen3-helm)

How service charts run [dbmate](https://github.com/amacneil/dbmate) schema migrations (Gen3 AI services and eventually more - as this is our preferred way), and how a service can connect as a separate, restricted [app role](#the-app-role). Other services relying on older alembic migrations have a different strategy, for example see
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

Use it for backfills, for re-running after a failed deploy, to migrate without a full release,
or after a new image behind a [floating tag](#floating-image-tags).

# Floating image tags

**A new image pushed under the same tag is not migrated automatically.** The migration Job's name
hashes the image *tag*, not the image itself, which Helm cannot see. When `main` or
`feat/foobar` gets a new commit, the tag is unchanged, so the deploy re-applies the same Job,
which has already run (or has been reaped), and nothing migrates. The same holds for the
gen3-embeddings [app-user Job](#the-app-role), so a new table is not granted either.

This fails safe rather than silently: the pod's init container checks the **database**, not the
Jobs. It waits until every migration in the pod's own image is applied and the app role can use
every row level security table, so new pods sit in `Init`, logging what they are waiting for,
while the old pods keep serving. They start on their own once the manual Jobs below have run.

Such a deploy usually does not go through Helm at all: an unchanged `helm upgrade` leaves the
Deployment alone, so it is a `kubectl rollout restart`. Run the manual Jobs first, in order, then
restart:

```bash
kubectl delete job gen3-embeddings-dbmigrate-manual gen3-embeddings-appuser-manual --ignore-not-found

kubectl create job --from=cronjob/gen3-embeddings-dbmigrate-cronjob gen3-embeddings-dbmigrate-manual
kubectl wait --for=condition=complete --timeout=30m job/gen3-embeddings-dbmigrate-manual

kubectl create job --from=cronjob/gen3-embeddings-appuser-cronjob gen3-embeddings-appuser-manual
kubectl wait --for=condition=complete --timeout=10m job/gen3-embeddings-appuser-manual

kubectl rollout restart deployment/gen3-embeddings-deployment
```

Both manual Jobs pull the image under the tag, with the chart's `image.pullPolicy` (`Always` by
default), so they see the new commit. The order is not critical: if you restart first, the new
pods wait in `Init` and start once the Jobs finish. The app-user Job also waits for the
migrations itself, indefinitely, so it only finishes once the migration Job has run.

Pinned tags, such as release versions or commit SHAs, need none of this: a new tag produces new
Jobs, and the deployment waits for them.

# The app role

The role in `<chart>-dbcreds` owns the tables and runs the migrations. A table's owner can switch
row level security off on its own tables, so a service relying on row level security must not
connect as it. With `postgres.appUser`, the service connects as a second role that owns nothing
and holds only what the image's grants script gives it. gen3-embeddings uses it:

```yaml
postgres:
  appUser:
    # Connect as the separate app role.
    enabled: true
    # Role name. Defaults to postgres.username, or <chart>_<release>, plus `_app`.
    username:
    # Path inside the service image of the script that grants the role its privileges.
    sqlFile: /services/gen3_embeddings/db/app_user.sql
```

It has three parts:

- **Creating the role** (`helm/common/templates/_db_app_user.tpl`). `<chart>-dbcreate`
  (`common.db_setup_job`) creates it with its admin connection, `NOSUPERUSER NOBYPASSRLS`, and
  refuses a role that already exists with either attribute or that is the admin or table owner
  role. As for `<chart>-dbcreds`, the password is set only when the role is created: it reaches
  the server in cleartext and may be logged there. Changing the Secret afterwards does not change
  the role's password; change both by hand.
- **Granting it the tables** (`helm/gen3-embeddings/templates/app-user.yaml`). The
  `<chart>-appuser-<hash>` Job waits for the migrations, runs `sqlFile` as the table owner, then
  checks that the role can use every row level security table in schema `public`. It runs under
  its own `<chart>-appuser-sa`, which can only write `<chart>-appuser-ready`.
- **Connecting as it.** The deployment reads `PGUSER`/`PGPASSWORD` from `<chart>-app-dbcreds`.
  It starts once two gates pass:
  - this deploy's Job has written a key named after itself into `<chart>-appuser-ready`, so
    each deploy whose Job changes waits for its own Job, not an earlier one's;
  - its init container finds the role can use every row level security table in `public`, the
    same check the Job ends with. This one reads the database, so it also holds back a new image
    under an unchanged tag (see [Floating image tags](#floating-image-tags)). It runs in the
    service image with its Python and asyncpg, since that image has no `psql`.

The grants step lives in the gen3-embeddings chart, as the only service using it. Role creation
and credentials are already in `common`; a second service adopting the app role is the time to
move the Job there too.

## Writing the grants script

`sqlFile` is a psql script the service image ships. It runs with `-v app_user=<role>` and
`-v app_password=` (empty), as the role that owns the tables, so it must:

- be idempotent - repeating a `GRANT` is a no-op;
- grant on every table the service uses, so a migration that adds a table should add its grant in
  the same commit;
- not rely on `app_password`. If it creates the role when missing, for local use, guard the
  `CREATE ROLE` with `\if` rather than a server-side check: psql substitutes the password into any
  statement naming it, so it would otherwise reach the server, and its log, on every run.

## Credentials

`<chart>-app-dbcreds` follows `<chart>-dbcreds`:

- **Locally**, the chart renders it with a random password, kept across upgrades.
- **With External Secrets** (`global.externalSecrets.deploy`), it is an ExternalSecret reading
  the Secrets Manager entry `<environment>-<chart>-app-creds` (override with
  `externalSecrets.appDbcreds`), with `username` and `password` properties.
  - With `pushSecret` set, `<chart>-dbcreate` seeds that entry with a random password the first
    time, as it does for `<chart>-dbcreds`.
  - **Without `pushSecret`, create the entry in Secrets Manager before the first deploy.** Nothing
    else creates it. Without it, `<chart>-dbcreate` fails after waiting five minutes for
    `<chart>-app-dbcreds`, and the pods stay in `CreateContainerConfigError`.

# Operational notes

**The Job name contains a hash** of the image tag, migrations directory and sslmode. An unchanged
deploy re-applies an identical spec, which is a no-op, so the Job never needs deleting first.
A new image tag produces a new Job that runs; a new image under the same tag does not (see
[Floating image tags](#floating-image-tags)). Editing the Job spec in
`_db_migrate_job.tpl` without changing any hashed input requires deleting the old Job once.

**Pods carry `app: gen3job`.** `common.db_netpolicy` grants
database egress to `app in (<chart>, gen3job)`, so a migration pod without that label cannot reach
Postgres wherever network policies are enabled. It is also how the observability stack finds Gen3
job logs in Loki.

**Migrations connect as the role in `<chart>-dbcreds`**, through `DB_MIGRATION_*`, so that role
owns the tables they create. `activeDeadlineSeconds` is deliberately unset - a
container-create failure does not consume `backoffLimit`, so waiting on `dbcreated` is safe, but a
deadline would kill the Job while it waits.