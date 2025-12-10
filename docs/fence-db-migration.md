# Fence Database Migration Guide (gen3-helm)

This document describes how to run Fence database migrations when deploying gen3-helm.
You can perform migrations automatically via an initContainer or manually using a Kubernetes job.

# Overview

Fence releases will sometimes require a database migrations when new releases introduce schema changes. This will be highlighted in the release notes. 

gen3-helm supports two migration workflows:

Automatic migration using an initContainer.

Manual migration by triggering a Kubernetes job from the provided CronJob

# 1. Automatic Migration via initContainer

Fence can automatically run database migrations during pod startup if enabled in its configuration.

Enable automatic DB migration

Set the following in fence-config.yaml (either in .Values.fence.FENCE_CONFIG within values.yaml or in your external secret):

```yaml
ENABLE_DB_MIGRATION: true
```

Once enabled, Fence will run migrations on startup through an initContainer before the main container begins.

## Where to configure

values.yaml example:

```yaml
fence:
  FENCE_CONFIG:
    ENABLE_DB_MIGRATION: true
```

Or via an external secret that provides fence-config.yaml.

Behavior

The initContainer runs migrations once per pod start.

If the database is up-to-date, it exits cleanly.

If a migration is required, it applies changes before allowing the main Fence container to start.

# 2. Manual Migration via Kubernetes Job

If you prefer more control or are upgrading a production system, you can manually execute the migration.

gen3-helm includes a CronJob template named fence-db-migrate-cronjob.
You can trigger a one-off migration job based on the CronJob.

## Steps

Deploy or upgrade to the latest version of the gen3-helm charts (so the CronJob exists).

Run the migration job manually:

```sh
kubectl create job --from=cronjob/fence-db-migrate-cronjob fence-db-migrate-manual
```