# Grafana Alloy and Faro

## Overview

This guide provides a step-by-step approach to configuring an Alloy instance to collect Grafana Faro logs sent over the internet, similar to Real User Monitoring (RUM). The Portal service generates Faro logs, which Alloy collects and forwards to Loki for storage and analysis in Grafana. Additionally, this guide explains how to enable metrics in the Fence service and adjust the Faro URL in the Gen3 Portal configuration to route metrics to your Alloy instance. Future updates will enable more Gen3 services to offer metric collection.

Before deploying Alloy, it is important to first deploy the "observability" Helm chart, as it provides the necessary components and configuration for Alloy to function properly. Please refer to the [SETUP.md](https://github.com/uc-cdis/gen3-helm/blob/master/helm/observability/SETUP.md) observability chart documentation for instructions on how to set it up before proceeding with the Alloy deployment.

### Why Does Faro Require an Internet-Facing Ingress?

Grafana Faro collects Real User Monitoring (RUM) data, such as performance metrics, errors, and user interactions, via the Fence and Portal services. This data is sent from user devices to the backend, which in this case is Alloy. To enable this communication, an internet-facing ingress is required to expose the Faro endpoint to the public, allowing users' browsers to send RUM data to the Alloy instance over the internet.

## Configuring Alloy for Faro Logs

### Helm Chart Configuration

The ingress is configured with AWS ALB (Application Load Balancer) to expose the Alloy Faro port (12347) to the internet. The alb.ingress.kubernetes.io/scheme annotation ensures that the ALB is internet-facing, allowing users to send logs from their browsers to Alloy.

When configuring the Faro collector, you will need to update the hosts section of the values.yaml file to match the hostname you plan to use for the Faro collector. For example, replace "faro.example.com" with your desired hostname.

Additionally, it is highly recommended that you uncomment and adjust the annotations provided for AWS ALB (Application Load Balancer) to fit your environment. These annotations will help ensure proper configuration of the load balancer, SSL certificates, and other key settings. For instance, make sure to replace the placeholder values such as "cert arn", "ssl policy", and "environment name" with your specific details.

```yaml
alloy:
  extraPorts:
    - name: "faro"
      port: 12347
      targetPort: 12347
      protocol: "TCP"
  clustering:
    enabled: true
  configMap:
    name: alloy-gen3
    key: config

ingress:
  enabled: true
  ingressClassName: "alb"
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: <cert arn>
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=600
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-policy: <ssl policy>
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/tags:  Environment=<environment>
    alb.ingress.kubernetes.io/target-type: ip
  labels: {}
  path: /
  faroPort: 12347
  hosts:
    - faro.example.com

alloy-configmap-data: |
  logging {
    level    = "info"
    format   = "json"
  }

  otelcol.exporter.otlp "tempo" {
    client {
      endpoint = "http://grafana-tempo-distributor.monitoring:4317"
      tls {
        insecure = true
        insecure_skip_verify = true
      }
    }
  }
  
  loki.write "endpoint" {
    endpoint {
      url = "http://grafana-loki-gateway.monitoring:80/loki/api/v1/push"
    }
  }
  
  faro.receiver "default" {
    server {
      listen_address = "0.0.0.0"
      listen_port = 12347
      cors_allowed_origins = ["*"]
    }

    extra_log_labels = {
      service = "frontend-app",
      app_name = "",
      app_environment = "",
      app_namespace = "",
      app_version = "",
    }
    output {
      logs   = [loki.write.endpoint.receiver]
      traces = [otelcol.exporter.otlp.tempo.input]
    }
  }
```

### Helm Chart Links
The link below will take you to the Grafana Alloy chart, providing a comprehensive list of configurable options to help you further customize your setup.

[Alloy Helm Chart](https://github.com/grafana/alloy/blob/main/operations/helm/charts/alloy/values.yaml)

---

## Enabling Faro Metrics in Fence

Fence now has built-in Faro metrics. To enable these metrics, you must update your Fence deployment.

*** Note: you must be using Fence version 10.2.0 or later

### Step 1: Enable Prometheus Metrics in the Fence Pod

Update your Fence deployment with the following annotations to allow Prometheus to scrape the metrics:

```yaml
fence:
    podAnnotations:
        prometheus.io/path: /metrics
        prometheus.io/scrape: "true"
```

### Step 2: Enable Metrics in the Fence Configuration

Modify the FENCE_CONFIG_PUBLIC section to enable Prometheus metrics:

```yaml
fence:
    FENCE_CONFIG_PUBLIC:
        ENABLE_PROMETHEUS_METRICS: true
        ENABLE_DB_MIGRATION: true
```

---

## Updating Faro URL in Gen3 Portal

If you need to change the Faro URL that metrics are sent to, you will need to update the "grafanaFaroUrl" field by modifying the "gitops.json" value in your values.yaml. You can refer to [this link](https://github.com/uc-cdis/data-portal/blob/master/docs/portal_config.md) for more information.

```yaml
portal:
    # -- (map) GitOps configuration for portal
    gitops:
    # -- (string) multiline string - gitops.json
        json: |
            {
            "grafanaFaroConfig": {
                "grafanaFaroEnable": true, // optional; flag to turn on Grafana Faro RUM, default to false
                "grafanaFaroNamespace": "DEV", // optional; the Grafana Faro RUM option specifying the application’s namespace, for example: prod, pre-prod, staging, etc. Can be determined automatically if omitted. But it is highly recommended to customize it to include project information, such as 'healprod'
                "grafanaFaroUrl": "", // optional: the Grafana Faro collector url. Defaults to https://faro.example.com/collect
                "grafanaFaroSampleRate": 1, // optional; numeric; the Grafana Faro option specifying the percentage of sessions to track: 1 for all, 0 for none. Default to 1 if omitted
            },
```
--- 

By following this guide, you'll have successfully set up Alloy to receive Grafana Faro logs and metrics while exposing the service over the internet using Kubernetes ingress. You’ll also be able to monitor Faro metrics through Fence and make necessary configurations in Gen3 Portal for seamless Faro integration.