#!/usr/bin/env python3
"""
Regenerate examples/local_alloy_values.yaml from the Alloy chart's own configuration.

``helm/alloy/values.yaml`` carries Alloy's whole configuration in a single YAML string,
``alloy.alloyConfigmapData``. Helm can only replace such a value wholesale, never merge into it,
so the local-development overlay has to contain a full copy. This script produces that copy so
it stays byte-identical to the chart apart from a fixed set of substitutions: the three write
endpoints, which in the chart point at Mimir, Loki and Tempo hostnames that do not exist on a
laptop; the two external labels, which the chart writes as Go template syntax that
``templates/alloy-config.yaml`` never renders; and a ``loki.process`` stage inserted after the pod
log source.

Two of the substitutions are not address rewrites but added behaviour that exists nowhere else.
The ``loki.process`` stage promotes ``trace_id`` to Loki structured metadata and relabels
``service_name`` from the log line, which is what makes Grafana's trace-to-logs query resolve. The
cAdvisor scrape adds the per-container memory and CPU series the chart's kubelet scrape does not
carry. The chart has no equivalent of either, so moving one into ``helm/alloy/values.yaml`` is what
would extend it to deployed clusters, and its substitution would then be dropped.

Run it after any change to the chart's configuration:

    python3 .github/scripts/regenerate_local_alloy_values.py

It exits non-zero, changing nothing, if the chart no longer contains a line it expects to
rewrite. That means the chart moved and the substitutions below need revisiting - it is the
signal that the overlay would otherwise have drifted silently.
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CHART_VALUES = REPO_ROOT / "helm" / "alloy" / "values.yaml"
OVERLAY = REPO_ROOT / "examples" / "local_alloy_values.yaml"

# Applied in order to the copied configuration, each exactly once.
SUBSTITUTIONS = [
    (
        '        endpoint = "http://monitoring-tempo-distributor.monitoring:4317"\n',
        '        endpoint = "lgtm.monitoring:4317"\n',
    ),
    (
        # X-Scope-OrgID is Mimir's tenant header; the local Prometheus has no notion of tenants.
        '        url = "https://mimir.example.com/api/v1/push"\n'
        "\n"
        "        headers = {\n"
        '          "X-Scope-OrgID" = "anonymous",\n'
        "        }\n"
        "\n",
        '        url = "http://lgtm.monitoring:9090/api/v1/write"\n',
    ),
    (
        '        url = "https://loki.example.com/loki/api/v1/push"\n',
        '        url = "http://lgtm.monitoring:3100/loki/api/v1/push"\n',
    ),
    (
        '    loki.source.kubernetes "pods" {\n'
        "      targets = discovery.relabel.all_pods.output\n"
        "      forward_to = [loki.write.endpoint.receiver]\n"
        "    }\n",
        '    loki.source.kubernetes "pods" {\n'
        "      targets = discovery.relabel.all_pods.output\n"
        "      forward_to = [loki.process.pod_logs.receiver]\n"
        "    }\n"
        "\n"
        "    // Gen3 services log JSON carrying the OpenTelemetry trace_id. Promoting it to\n"
        "    // structured metadata is what lets Grafana's trace-to-logs query filter on\n"
        '    // `| trace_id = "..."` with no parser stage, which is how the Tempo datasource in\n'
        "    // the local LGTM image is provisioned. It deliberately does not become a stream\n"
        "    // label: a per-request value there would multiply Loki's stream cardinality.\n"
        "    //\n"
        "    // Lines that are not JSON, such as etcd and kube-proxy output, extract nothing and\n"
        "    // pass through unchanged.\n"
        '    loki.process "pod_logs" {\n'
        "      forward_to = [loki.write.endpoint.receiver]\n"
        "\n"
        "      stage.json {\n"
        '        expressions = { trace_id = "trace_id", span_id = "span_id", otel_service = "service" }\n'
        "      }\n"
        "\n"
        "      stage.structured_metadata {\n"
        '        values = { trace_id = "", span_id = "" }\n'
        "      }\n"
        "\n"
        "      // Each line reports the service.name its span was recorded under. Using that as\n"
        "      // the stream label is what keeps logs joinable to traces: Grafana builds its\n"
        "      // trace-to-logs query from service.name, while Loki would otherwise derive\n"
        "      // service_name from the pod's `app` label. Those two spellings differ whenever a\n"
        "      // service names itself with underscores, and the join then silently finds nothing.\n"
        "      //\n"
        "      // Lines logged outside a span extract nothing here and keep Loki's derived value.\n"
        "      stage.labels {\n"
        '        values = { service_name = "otel_service" }\n'
        "      }\n"
        "    }\n",
    ),
    (
        # cAdvisor, reached over the same node proxy the kubelet scrape uses. The chart scrapes
        # the kubelet's own /metrics, which carries no per-container memory or CPU, so nothing
        # in a cluster deployed from helm/alloy reports what a pod actually uses.
        '    // Cluster Events\n',
        '    // cAdvisor. Local-only for now; see docs/otel-logs-and-traces.md.\n'
        "    //\n"
        "    // The kubelet serves this on a second path, so it needs its own scrape rather than a\n"
        "    // longer keep list on the kubelet one.\n"
        '    discovery.relabel "cadvisor" {\n'
        "      targets = discovery.kubernetes.nodes.targets\n"
        "      rule {\n"
        '        target_label = "__address__"\n'
        '        replacement  = "kubernetes.default.svc.cluster.local:443"\n'
        "      }\n"
        "      rule {\n"
        '        source_labels = ["__meta_kubernetes_node_name"]\n'
        '        regex         = "(.+)"\n'
        '        replacement   = "/api/v1/nodes/${1}/proxy/metrics/cadvisor"\n'
        '        target_label  = "__metrics_path__"\n'
        "      }\n"
        "    }\n"
        "\n"
        '    prometheus.scrape "cadvisor" {\n'
        '      job_name   = "integrations/kubernetes/cadvisor"\n'
        "      targets  = discovery.relabel.cadvisor.output\n"
        '      scheme   = "https"\n'
        '      scrape_interval = "60s"\n'
        '      bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"\n'
        "      tls_config {\n"
        "        insecure_skip_verify = true\n"
        "      }\n"
        "      clustering {\n"
        "        enabled = true\n"
        "      }\n"
        "      forward_to = [prometheus.relabel.cadvisor.receiver]\n"
        "    }\n"
        "\n"
        '    prometheus.relabel "cadvisor" {\n'
        "      rule {\n"
        '        source_labels = ["__name__"]\n'
        '        regex = "container_memory_working_set_bytes|container_memory_rss|container_spec_memory_limit_bytes|container_cpu_usage_seconds_total|container_cpu_cfs_periods_total|container_cpu_cfs_throttled_periods_total|container_spec_cpu_quota|container_spec_cpu_period|container_oom_events_total"\n'
        '        action = "keep"\n'
        "      }\n"
        "\n"
        "      // cAdvisor reports one series per cgroup level. The pod and slice rollups carry an\n"
        "      // empty container label and sum the containers beneath them, so keeping both counts\n"
        "      // every container twice.\n"
        "      rule {\n"
        '        source_labels = ["container"]\n'
        '        regex = ""\n'
        '        action = "drop"\n'
        "      }\n"
        "\n"
        "      forward_to = [prometheus.relabel.metrics_service.receiver]\n"
        "    }\n"
        "\n"
        '    // Cluster Events\n',
    ),
    # Once per write endpoint, hence the repeated pairs.
    ('        cluster = "{{ .Values.cluster }}",\n', '        cluster = "local-kind",\n'),
    ('        project = "{{ .Values.project }}",\n', '        project = "local",\n'),
    ('        cluster = "{{ .Values.cluster }}",\n', '        cluster = "local-kind",\n'),
    ('        project = "{{ .Values.project }}",\n', '        project = "local",\n'),
]

HEADER = """\
# GENERATED by .github/scripts/regenerate_local_alloy_values.py - re-run that script rather than
# editing alloyConfigmapData below by hand.
#
# Grafana Alloy sized for a kind cluster, writing to the single-pod LGTM stack described in
# docs/local-observability.md. Install with:
#
#   helm dependency update helm/alloy
#   helm upgrade --install alloy ./helm/alloy -n monitoring -f examples/local_alloy_values.yaml
#
# The release must be named `alloy` in namespace `monitoring`: that is the collector address
# Gen3 service images have baked in as OTEL_EXPORTER_OTLP_ENDPOINT.
alloy:
  controller:
    type: deployment
    replicas: 1
    # helm/alloy/values.yaml pins Alloy to topology.kubernetes.io/zone=us-east-1a. A kind node
    # carries no zone label, so without this the pod never leaves Pending. It has to be null
    # rather than {}: Helm merges an empty map, which leaves the chart's affinity in place, and
    # only an explicit null deletes the key.
    affinity: null

  alloy:
    stabilityLevel: "public-preview"
    uiPathPrefix: /alloy
    # Lists replace rather than merge, so the OTLP ports have to be restated here.
    extraPorts:
      - name: "otel-grpc"
        port: 4317
        targetPort: 4317
        protocol: "TCP"
      - name: "otel-http"
        port: 4318
        targetPort: 4318
        protocol: "TCP"
    # A single replica has nobody to gossip with, and the peer lookups are noise in the logs.
    clustering:
      enabled: false
    # The parent chart renders the alloy-gen3 ConfigMap; letting the subchart render one too
    # would collide on the name.
    configMap:
      create: false
      name: alloy-gen3
      key: config
    resources:
      requests:
        cpu: 100m
        memory: 256Mi

  # Copied from helm/alloy/values.yaml, changing the three write endpoints and the two external
  # labels, and inserting two things the chart has no equivalent of: the loki.process stage that
  # follows the pod log source, and the cAdvisor scrape. Both are local-only, so trace-to-logs
  # correlation and per-container memory and CPU work here and not in a cluster deployed from
  # helm/alloy. See docs/otel-logs-and-traces.md.
  #
  # The labels are written out literally on purpose. templates/alloy-config.yaml renders this
  # with toYaml rather than tpl, so any {{ }} left in here reaches the ConfigMap unrendered.
  alloyConfigmapData: |
"""

CONFIG_KEY = "  alloyConfigmapData: |"


def main() -> int:
    """
    Write the overlay from the current chart configuration.

    Returns:
        int: 0 on success, 1 if the chart no longer matches what the substitutions expect.
    """
    lines = CHART_VALUES.read_text().splitlines(keepends=True)

    try:
        start = next(i for i, line in enumerate(lines) if line.startswith(CONFIG_KEY))
    except StopIteration:
        print(f"{CHART_VALUES} has no '{CONFIG_KEY.strip()}' key", file=sys.stderr)
        return 1

    # alloyConfigmapData is the last key in the file, so the config block runs to the end.
    config = "".join(lines[start + 1 :]).rstrip("\n") + "\n"

    for needle, replacement in SUBSTITUTIONS:
        if needle not in config:
            print(f"chart configuration no longer contains:\n{needle}", file=sys.stderr)
            return 1
        config = config.replace(needle, replacement, 1)

    if "{{" in config:
        print("template syntax left in the copied configuration", file=sys.stderr)
        return 1

    OVERLAY.write_text(HEADER + config)
    print(f"wrote {OVERLAY} ({len(config.splitlines())} configuration lines)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
