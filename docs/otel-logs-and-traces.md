# Structured logs and tracing in a deployed cluster

> **Working notes** This is one reading of what the platform would need in order to
> support JSON logging and tracing for Gen3 services in general. This file is meant to be deleted once the work is scoped.

## What the services emit

The Gen3 AI services (`gen3-embeddings` and its siblings) v1.0.0 will emit logs in JSON, tracing info with Open Telemetry, and metrics with prometheus. Metrics need no
chart work from what I can tell.

`gen3logging`'s JSON formatter writes one object per line:

```json
{
  "timestamp": "2026-08-17T17:43:05.149Z",
  "logger": "gen3_embeddings",
  "level": "INFO",
  "message": "...",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "service": "gen3_embeddings"
}
```

* Traces go to Alloy over OTLP on port 4318 (`http/protobuf`).
* `trace_id` and `span_id` come from `opentelemetry-instrumentation-logging`(python library), which puts them on
  every log record. They are `null` for anything logged outside a request span, such as startup or
  the OTLP exporter's own HTTP calls. Only lines emitted while a span is active can correlate.
* `service` is the OpenTelemetry `service.name`, and it is **underscored** (`gen3_embeddings`),
  matching the Python package. Kubernetes labels for the same service appear **hyphenated**
  (`gen3-embeddings`). 
    - I opted to keep the service name aligned to the Python package and repo in the traces
* `GEN3_JSON_LOGS=false` switches to existing text formatter that appends `[trace_id=... span_id=...]` as
  a suffix if we need to. But everything below assumes JSON.

For the laptop equivalent, see [local-observability.md](local-observability.md).

## What production seemingly runs today

Alloy reaches clusters by two different paths, but they are not equivalent:

| Path                    | Config lives in                            | Traces go to                                                          |
| ----------------------- | ------------------------------------------ | --------------------------------------------------------------------- |
| ArgoCD (the one in use) | `helm/cluster-level-resources/values.yaml` | `https://tempo.planx-pla.net:443`, external and CTDS-managed          |
| The `helm/alloy` chart  | `helm/alloy/values.yaml`                   | `monitoring-tempo-distributor.monitoring:4317`, which nothing creates |

Logs and metrics in both cases go to the Loki and Mimir deployed by `helm/observability` (the
`lgtm-distributed` chart, with `lgtm.tempo.enabled: false`).

Everything below refers to the ArgoCD path unless it says otherwise.

# Getting correlation working

These three sections are ordered by dependency. Nothing in the second is observable until the
first is done, and the third has no effect without the second.

## 1. Loki has to accept the streams

**Symptom:** no logs in Loki for a service, and `final error sending batch ... status 400` in
Alloy's own logs, reading `has N label names; limit 15`.

`helm/observability/values.yaml` sets `loki.structuredConfig.limits_config` with
`max_query_series`, `max_streams_per_user`, and `max_entries_limit_per_query`, but not
`max_label_names_per_series`, which therefore sits at Loki's default of **15**.

A Gen3 pod stream carries about fifteen. `discovery.relabel "all_pods"` in
`cluster-level-resources/values.yaml` sets five labels, `labelmap`s every pod label on top, then
drops nine high-cardinality ones; `loki.write` adds `cluster` and `project`, and
`loki.source.kubernetes` adds `instance` and `job`. What pushes it over is the network-policy
labels Gen3 charts attach: `netnolimit`, `public`, `userhelper`, and for some services
`authprovider`, `internet`, `linklocal`, `netvpc`. `fence` is the clearest case.

Two fixes, not exclusive:

```yaml
# helm/observability/values.yaml, under lgtm.loki.structuredConfig.limits_config
limits_config:
  max_label_names_per_series: 32
```

or extend the existing `labeldrop` regex in `cluster-level-resources/values.yaml` to drop the
network-policy labels, which are probably not useful for querying logs:

```
regex = "pod_template_hash|...|netnolimit|public|userhelper|authprovider|internet|linklocal|netvpc"
```

Raising the limit is the smaller change and keeps the labels available. Dropping them is better
hygiene, since each one multiplies Loki's stream count. Prefer dropping, and raise the limit as
well so that a chart adding one more label does not silently start dropping logs again.

**Verify:** `kubectl -n monitoring logs deploy/alloy | grep "status 400"` is quiet, and
`{service_name="gen3_embeddings"}` in Explore returns lines.

## 2. `trace_id` and `service_name` have to be queryable

`cluster-level-resources/values.yaml` wires pod logs straight through:

```alloy
loki.source.kubernetes "pods" {
  targets = discovery.relabel.all_pods.output
  forward_to = [loki.write.endpoint.receiver]
}
```

Two problems follow from that.

`trace_id` is only text inside the log message, so a LogQL label filter cannot see it and a query
built from a trace id matches nothing.

The service name also disagrees with itself. Grafana builds its trace-to-logs stream selector from
the span's `service.name`, while Loki derives `service_name` from the pod's `app` label when the
label is absent. A span says `service.name = gen3_embeddings` and its logs land on a stream
labelled `service_name = gen3-embeddings`, so the join finds nothing. Underscore against hyphen.

Insert a processing stage between the source and the write:

```alloy
loki.source.kubernetes "pods" {
  targets = discovery.relabel.all_pods.output
  forward_to = [loki.process.pod_logs.receiver]
}

loki.process "pod_logs" {
  forward_to = [loki.write.endpoint.receiver]

  stage.json {
    expressions = { trace_id = "trace_id", span_id = "span_id", otel_service = "service" }
  }

  stage.structured_metadata {
    values = { trace_id = "", span_id = "" }
  }

  stage.labels {
    values = { service_name = "otel_service" }
  }
}
```

`trace_id` becomes **structured metadata**, not a stream label. That distinction is the point:
structured metadata is filterable with `| trace_id = "..."` and no parser stage, while a
per-request value used as a stream label would multiply Loki's stream cardinality without bound.

`stage.labels` takes `service_name` from the line's own `service` field, so the label matches the
span by construction. Lines logged outside a span have no `service` value and keep Loki's derived
label, which is why both spellings appear in a healthy cluster.

Requires Loki on `tsdb` with schema `v13` or later. `helm/observability/values.yaml` already
configures `store: tsdb` with `schema: v13`.

Lines that are not JSON, such as etcd, kube-proxy, and nginx, extract nothing and pass through
unchanged.

This stage currently ships in one place only: the kind overlay, where
`.github/scripts/regenerate_local_alloy_values.py` inserts it while generating
`examples/local_alloy_values.yaml`. Neither `cluster-level-resources/values.yaml` nor
`helm/alloy/values.yaml` contains it, so correlation is a local-development capability until this
lands in one of them. Anything verified against a kind cluster is exercising the overlay rather
than the configuration a cluster runs.

**Verify:** `{service_name="gen3_embeddings"} | trace_id != ""` returns lines **with no `| json`
stage**. That absence is the proof the value is structured metadata rather than text. If the
stream exists but the filter returns nothing, `stage.json` is not matching, so check that
`GEN3_JSON_LOGS` is not false. Then compare `service.name` on a span in Tempo against
`service_name` on the log stream; they have to be spelled identically.

## 3. Grafana has to be wired for it

`helm/observability/values.yaml` does not override `grafana.datasources`, so the
`lgtm-distributed` defaults apply. Those give the Tempo datasource a `tracesToLogsV2` block with
nothing but `datasourceUid: loki` in it.

Without a `customQuery`, trace-to-logs does a plain stream lookup over a time window rather than
filtering to the request, so "Logs for this span" returns everything the service logged around
that moment. And the Loki datasource has no `derivedFields`, so there is no link in the other
direction, from a log line to its trace. Both need stating explicitly:

```yaml
lgtm:
  grafana:
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
          - name: Tempo
            uid: tempo
            type: tempo
            url: http://{{ .Release.Name }}-tempo-query-frontend:3200
            jsonData:
              tracesToLogsV2:
                customQuery: true
                datasourceUid: loki
                query: '{$${__tags}} | trace_id = "$${__trace.traceId}"'
                tags:
                  - key: service.name
                    value: service_name
          - name: Loki
            uid: loki
            type: loki
            url: http://{{ .Release.Name }}-loki-gateway
            jsonData:
              derivedFields:
                - name: trace_id
                  matcherType: label
                  matcherRegex: trace_id
                  url: "$${__value.raw}"
                  datasourceUid: tempo
```

Overriding `datasources.yaml` replaces the whole list, so the Mimir datasource has to be restated
alongside these. The `$$` escaping is required because these strings pass through Helm templating.

`matcherType: label` is what makes the derived field read structured metadata rather than
re-parsing the line, which is why section 2 has to land first.

While editing datasources, `exemplarTraceIdDestinations` on the Mimir datasource is worth adding.
It turns latency panels into click-throughs to a trace, but only once Mimir is started with
exemplar storage enabled, which is a separate change.

**Verify:** open a span in Tempo and use its logs link. It should return only that request's
lines, not everything in the window.

# Separate decisions

## There is no Tempo in the observability chart

`helm/observability/values.yaml:12` sets `lgtm.tempo.enabled: false`, and the `helm/alloy` chart
points at a `monitoring-tempo-distributor` that nothing creates. Clusters using the ArgoCD path
send traces to the external `tempo.planx-pla.net` instead, so tracing works there and only there.

Enabling Tempo needs three values, not one:

```yaml
lgtm:
  tempo:
    enabled: true
    traces:
      otlp:
        grpc:
          enabled: true      # tempo-distributed defaults this to false
    storage:
      trace:
        backend: s3          # `local` cannot work: ingesters and queriers share no filesystem
        s3: {}               # bucket, region, and an IRSA policy alongside Mimir's and Loki's
```

The `traces.otlp.grpc.enabled` default is the one that catches people: enabling Tempo alone leaves
port 4317 closed, and Alloy's exporter fails with nothing obviously wrong in the chart.

Whether a cluster should run its own Tempo at all, given the central one, is a decision rather
than a defect.

## Alert rules assume a different log shape

`helm/observability/values.yaml` provisions Grafana alert rules that parse logs. Two filter on a
JSON field the new format does not emit:

```logql
sum by (cluster) (count_over_time({cluster=~".+"} | json | http_status_code="500" [1h])) > 0
sum(count_over_time({cluster=~".+"} | json | http_status_code="431" [5m])) >= 2
```

The Gen3 AI services emit `timestamp`, `logger`, `level`, `message`, `trace_id`, `span_id`, and
`service`. There is no `http_status_code`, so these alerts will never fire for them. They were
written against another service's log shape.

Either have the services add an `http_status_code` field when logging a response, or narrow the
alerts to the services that do emit it. Adding the field is the smaller change and makes the alert
mean what it says.

> Do we need/use this rule? Should I change the Gen3 AI services to include `http_status_code` when it's available? The problem is that we'd have to ensure a log at the end of every request when the status code is locked in.

# Seemingly we have defects in the `helm/alloy` chart

Not required for the ArgoCD path, but it should probably not stay broken. Grouped by what each one costs.

**Prevents startup.**

- The template opens a block scalar with `config: |` and then runs the value through `toYaml`,
  which emits a second block scalar inside the first. A literal `|` becomes the first line of the
  ConfigMap and Alloy fails with `missing second | in ||`.
  `cluster-level-resources/templates/alloy-configmap.yaml:8` avoids this by not opening a scalar
  and letting `toYaml` produce it:
  `config: {{ tpl (index .Values "alloy-configmap-data") . | toYaml | indent 2}}`.
- `values.yaml:12` pins the pod to `topology.kubernetes.io/zone=us-east-1a`, so it stays `Pending`
  anywhere else. Clearing this from a values file needs `affinity: null`; `affinity: {}` merges an
  empty map and changes nothing.

**Degrades the data.**

- The config is never passed through `tpl`, so `cluster` and `project` reach the ConfigMap as the
  literal strings `{{ .Values.cluster }}` and `{{ .Values.project }}`, and every metric and log
  stream Alloy forwards carries those as external labels. Dropping `toYaml` alone does not fix
  this; only `tpl` evaluates the template. Note that `tpl` evaluates the whole config, so any
  future stage using Go-style braces, `stage.template` being the common one, would break.
- No `labeldrop`, unlike the ArgoCD config, which makes the label limit in section 1 worse.

**Blocks correlation.**

- No `loki.process` stage, so section 2 does not apply and pod logs reach Loki with `trace_id` as
  message text only.

**Collides with another chart.**

- `helm/faro-collector/templates/alloy-config.yaml` uses the same construction and also renders a
  ConfigMap named `alloy-gen3`, so the two charts overwrite each other in one namespace.

# What needs no work

Metrics. `common.grafanaAnnotations` already puts `prometheus.io/scrape` and `prometheus.io/path`
on every Gen3 pod, `global.metricsEnabled` defaults to true, and Alloy's
`annotation_autodiscovery_pods` relabel already resolves those to `podIP:<containerPort>/metrics`.
A service only has to serve the endpoint.