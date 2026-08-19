# Local observability on kind

## Overview

Gen3 services emit two kinds of telemetry: Prometheus metrics scraped from a `/metrics`
endpoint, and OpenTelemetry traces pushed over OTLP. In a deployed cluster both flow through
[Grafana Alloy](../helm/alloy/SETUP.md), which forwards metrics to Mimir, logs to Loki, and
traces to Tempo.

This guide stands the same Alloy pipeline up on a kind cluster, backed by a single-pod LGTM
stack instead of the [observability](../helm/observability/SETUP.md) chart. You get Grafana,
Prometheus, Tempo, and Loki in one container, and Alloy configured exactly as it is in a real
cluster apart from the three addresses it writes to.

Use this when you are developing a service and want to see its own metrics and traces. Do not
use it as a model for a deployed cluster:

- one replica of everything, no high availability
- `emptyDir` storage, so all data is lost when the pod restarts
- no ingress, no TLS, no authentication beyond Grafana's default `admin` / `admin`

The `observability` chart is the deployed-cluster answer. It is sized for EKS - five Mimir
ingesters, S3 storage, ALB ingresses - and will not fit comfortably on a laptop.

## Prerequisites

A running kind cluster. See [kubernetes-in-docker.md](kubernetes-in-docker.md).

# Step 1. Deploy the LGTM backend

[examples/local_lgtm.yaml](../examples/local_lgtm.yaml) is adapted from the manifest published
by [grafana/docker-otel-lgtm](https://github.com/grafana/docker-otel-lgtm), with one change: the
Loki port is exposed, so Alloy has somewhere to send logs. The image already starts Prometheus
with `--web.enable-remote-write-receiver`, which is what Alloy needs in order to deliver
metrics, so nothing has to be passed to enable it.

```bash
kubectl apply -f examples/local_lgtm.yaml

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=lgtm \
  --timeout=180s
```

Grafana comes with Prometheus, Tempo, and Loki datasources already provisioned, so there is
nothing to wire up by hand.

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
kubectl -n monitoring logs deploy/alloy | grep -i error
```

Scrape jobs for `kube-state-metrics`, `node-exporter`, and the kubelet are part of the shipped
configuration and find nothing on kind. They sit idle rather than failing.

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

Services deployed in another namespace reach Alloy fine - `alloy.monitoring` resolves from
anywhere in the cluster.

# Step 4. Look at the data

```bash
kubectl port-forward -n monitoring svc/lgtm 3000:3000     # Grafana, admin / admin
kubectl port-forward -n monitoring svc/alloy 12345:12345  # Alloy UI, at /alloy
```

In Grafana, Explore against the Prometheus datasource for metrics and the Tempo datasource for
traces. Traces are searchable by `service.name`.

Every sample Alloy forwards carries `cluster="local-kind"` and `project="local"`, set as
external labels in the values file. If a metric has those labels it came through this pipeline.

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