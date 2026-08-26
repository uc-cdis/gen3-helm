# Local observability on kind

## Overview

Gen3 services emit four kinds of telemetry: Prometheus metrics scraped from a `/metrics`
endpoint, logs written to stdout, OpenTelemetry traces pushed over OTLP, and continuous profiles
pushed to Pyroscope. In a deployed cluster the first three flow through
[Grafana Alloy](../helm/alloy/SETUP.md), which forwards metrics to Mimir, logs to Loki, and traces
to Tempo. Profiles take no such detour - the SDK inside each service pushes them straight to
Pyroscope, so nothing in Alloy's configuration is involved in carrying them.

This guide stands the same Alloy pipeline up on a kind cluster, backed by a single-pod LGTM
stack instead of the [observability](../helm/observability/SETUP.md) chart. You get Grafana,
Prometheus, Tempo, Loki, and Pyroscope in one container, and Alloy configured as it is in a real
cluster apart from the three addresses it writes to and one added log-processing stage.

That stage is the one deliberate behavioural difference, and it matters when comparing against a
deployed cluster: the overlay promotes each log line's `trace_id` to Loki structured metadata and
takes `service_name` from the line itself, which is what makes Grafana's trace-to-logs link
resolve. `helm/alloy/values.yaml` carries no such stage, so a deployed cluster using that chart
correlates traces to logs only once the change described in
[otel-logs-and-traces.md](otel-logs-and-traces.md) lands there.

Use this when you are developing a service and want to see its own metrics, traces, logs, and
profiles. Do not use it as a model for a deployed cluster:

- one replica of everything, no high availability
- `emptyDir` storage, so all data is lost when the pod restarts
- no ingress, no TLS, no authentication beyond Grafana's default `admin` / `admin`

The `observability` chart is the deployed-cluster answer. It is sized for EKS - five Mimir
ingesters, S3 storage, ALB ingresses - and will not fit comfortably on a laptop. It also deploys
neither Tempo nor Pyroscope, so a deployed cluster gets traces and profiles only from backends
outside that chart; see [otel-logs-and-traces.md](otel-logs-and-traces.md).

## Prerequisites

A running kind cluster. See [kubernetes-in-docker.md](kubernetes-in-docker.md).

# Step 1. Deploy the LGTM backend

[examples/local_lgtm.yaml](../examples/local_lgtm.yaml) is adapted from the manifest published
by [grafana/docker-otel-lgtm](https://github.com/grafana/docker-otel-lgtm), with two changes: the
Loki port is exposed, so Alloy has somewhere to send logs, and the Pyroscope port is exposed, so
services can push profiles. Both listen inside the image already; only the Service was missing
them, and a Service without the port silently drops the traffic rather than refusing it. The
image already starts Prometheus with `--web.enable-remote-write-receiver`, which is what Alloy
needs in order to deliver metrics, so nothing has to be passed to enable it.

```bash
kubectl apply -f examples/local_lgtm.yaml

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=lgtm \
  --timeout=180s
```

Grafana comes with Prometheus, Tempo, Loki, and Pyroscope datasources already provisioned, so
there is nothing to wire up by hand.

# Step 2. Deploy Alloy

[examples/local_alloy_values.yaml](../examples/local_alloy_values.yaml) is the stock Alloy
configuration with its three write endpoints pointed at the pod from step 1. It also clears the
`us-east-1a` node affinity the chart applies by default, which no kind node satisfies.

```bash
helm dependency update helm/alloy
helm upgrade --install alloy ./helm/alloy -n monitoring -f examples/local_alloy_values.yaml
```

The release has to be named `alloy` and live in `monitoring`. Gen3 service images ship with
`OTEL_EXPORTER_OTLP_ENDPOINT=http://alloy.monitoring:4318` baked in, and that address is
`<release>.<namespace>`.

Confirm Alloy came up clean:

```bash
kubectl -n monitoring logs deploy/alloy | grep '"level":"error"'
```

Expect `"level":"warn"` lines reading `tailer stopped; will retry` for any container that has not
started yet. `loki.source.kubernetes` gets a target per declared container as soon as the pod object
exists, so it retries on a backoff until the container runs. A pod stuck in
`Init:CreateContainerConfigError` or `ImagePullBackOff` produces these indefinitely without
affecting collection from healthy pods.

# Step 3. Point a service at it

**Metrics need nothing.** Every Gen3 chart stamps `prometheus.io/scrape: "true"` and
`prometheus.io/path: /metrics` onto its pods, controlled by `global.metricsEnabled` (default
`true`). Alloy discovers pods by those annotations and scrapes `<pod IP>:<container port>/metrics`.
The only requirement is that your service actually serves `/metrics`.

**Traces need three values**, and only if you want to override what the image already does. For
`gen3-embeddings`:

```yaml
gen3-embeddings:
  otel:
    enabled: true
    endpoint: "http://alloy.monitoring:4318"
    protocol: "http/protobuf"
```

`endpoint` and `protocol` have to change together: Alloy listens for `http/protobuf` on 4318 and
for `grpc` on 4317, and a mismatched pair fails when the first span is exported rather than at
startup.

**Profiles need one address.** A service that ships a Pyroscope SDK likely pushes to
`PYROSCOPE_SERVER_ADDRESS`, which is something like:

```
PYROSCOPE_SERVER_ADDRESS=http://lgtm.monitoring:4040
```

> NOTE: Check the individual service config for how to enable and configure observability. We are trying to consolidate Python observability into one of our Python packages that we import and use in the services, but there may be some differences across services.

Services deployed in another namespace reach Alloy fine - `alloy.monitoring` resolves from
anywhere in the cluster, as does `lgtm.monitoring`.

# Step 4. Look at the data

```bash
kubectl port-forward -n monitoring svc/lgtm 3000:3000     # Grafana, admin / admin
kubectl port-forward -n monitoring svc/alloy 12345:12345  # Alloy UI, at /alloy
```

In Grafana, Explore against the Prometheus datasource for metrics, the Tempo datasource for
traces, the Loki datasource for logs, and the Pyroscope datasource for profiles. Traces are
searchable by `service.name`; logs are selected by `service_name`, for example
`{service_name="gen3_embeddings"}`. Profiles are selected by the application name the SDK
registers, which the service sets rather than the chart.

To jump from a trace to its logs, open a span in Tempo and follow its logs link. The Tempo
datasource in the LGTM image builds that query as `{service_name="..."} | trace_id = "..."`, a
label filter with no parser stage, which resolves only because the Alloy overlay stores
`trace_id` as structured metadata.

Every sample Alloy forwards carries `cluster="local-kind"` and `project="local"`, set as
external labels in the values file. If a metric has those labels it came through this pipeline.

## When a log line or trace link does not show up

Alloy tails every pod's containers by default, so absent logs are usually a write or a label
problem rather than a collection one. Work forwards along the path.

1. **Is Alloy tailing the pod?** `kubectl -n monitoring logs deploy/alloy -c alloy | grep "opened log stream"`
   names each container it reads. `tailer stopped; will retry` is normal against a container that
   is not running, and clears once it starts. Against a pod wedged in `ImagePullBackOff` or
   `Init:CreateContainerConfigError` it repeats on a backoff for as long as the pod exists - that is
   a broken pod, not a broken collector.
1. **Is Loki accepting the writes?** `kubectl -n monitoring logs deploy/alloy -c alloy | grep "error sending batch"`.
   A 500 reading `at least 1 live replicas required, could only find 0` means Loki's single
   ingester missed its heartbeat, which on a laptop is resource pressure rather than
   misconfiguration. Alloy retries, so short stalls only leave gaps in log history.
1. **Did the line land?** `{service_name="<name>"}` in Explore. If the stream exists under a
   different `service_name` than you expect, the line had no `service` field and Loki fell back to
   deriving the label from the pod's `app` label.
1. **Is `trace_id` queryable?** `{service_name="<name>"} | trace_id != ""` must return lines with
   no `| json` stage. If it only works with `| json`, `stage.structured_metadata` is not taking
   effect and the trace-to-logs link will stay empty.
1. **Does the span agree?** Compare `service.name` on a span in Tempo against `service_name` on
   the log stream. They have to be spelled identically, underscores included.

Lines logged outside a span carry `"trace_id": null`, which is expected for startup and for the
OTLP exporter's own HTTP calls. Only lines emitted while a span is active can correlate.

## When a metric does not show up

Work backwards along the path.

1. **Is the endpoint serving?** `kubectl exec deploy/<your-deployment> -- curl -sf localhost:<port>/metrics`.
   An empty 200 is a real failure mode for Python services using `prometheus_client` in
   multiprocess mode: the client picks its storage backend when it is first imported, so
   `PROMETHEUS_MULTIPROC_DIR` has to be set in the environment before then, not at runtime.
1. **Did Alloy find the pod?** The Alloy UI lists the targets for `prometheus.scrape "metrics"`.
   A missing pod means the annotations are absent; a target in state DOWN means Alloy reached
   the pod and the endpoint failed.
1. **Did the sample land?** Query Prometheus directly through the port-forward at
   `http://localhost:9090`, which rules out a Grafana datasource problem.

For traces, check the Alloy logs for OTLP export failures, then confirm the service is exporting
at all - some Gen3 services log the collector address they were configured with at startup.

## Keeping the values file current

`examples/local_alloy_values.yaml` contains a copy of `alloyConfigmapData` from
[helm/alloy/values.yaml](../helm/alloy/values.yaml). Helm treats that setting as one string, so
it can only be replaced wholesale, never merged into. Regenerate the copy rather than editing
it, after any change to the chart's configuration:

```bash
python3 .github/scripts/regenerate_local_alloy_values.py
```

The script exits non-zero and writes nothing if the chart no longer contains a line it expects
to rewrite, which means the substitutions need revisiting. Running it in CI and checking for a
dirty tree would catch the overlay drifting from the chart.