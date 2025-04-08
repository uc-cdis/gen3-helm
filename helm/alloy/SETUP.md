# Grafana Alloy

## Overview

This document provides a guide for deploying Grafana Alloy to your Kubernetes cluster using Helm. Grafana Alloy is a powerful observability tool that collects and ships logs and metrics from your services to Grafana Loki and Mimir for storage and analysis. By deploying Alloy, you can gain deep insights into your system’s performance, track key metrics, and troubleshoot issues efficiently.

In this deployment, the Alloy ConfigMap plays a crucial role in configuring which logs are collected for Loki and which metrics are gathered for Mimir. It also specifies the endpoints for Loki and Mimir where the data will be sent.

Before deploying Alloy, it is important to first deploy the "observability" Helm chart, as it provides the necessary components and configuration for Alloy to function properly. Please refer to the [SETUP.md](https://github.com/uc-cdis/gen3-helm/blob/master/helm/observability/SETUP.md) observability chart documentation for instructions on how to set it up before proceeding with the Alloy deployment.

## Configuring Alloy

### Helm Chart Configuration

The Alloy configuration is the key component that allows users to customize what logs are collected for Loki and which metrics are collected for Mimir. Through this configuration, you can define the specific endpoints where logs and metrics should be sent, ensuring that data is properly routed for observability and analysis.

In this configuration, it is important to replace the placeholder hostnames (*.example.com) with the actual Loki and Mimir hostnames that were configured in the "observability" Helm chart. This ensures that logs are sent to the correct Loki endpoint and metrics are forwarded to the appropriate Mimir endpoint, allowing your observability stack to function effectively. Additionally, you can fine-tune the alloyConfigmapData to suit your environment's needs. Please click [here](https://grafana.com/docs/alloy/latest/reference/components/#components) to see in-depth documentation on how to do so.

```yaml
    // Write Endpoints
    // prometheus write endpoint
    prometheus.remote_write "default" {
      external_labels = {
        cluster = "{{ .Values.cluster }}",
        project = "{{ .Values.project }}",
      }
      endpoint {
        url = "https://mimir.example.com/api/v1/push"

        headers = {
          "X-Scope-OrgID" = "anonymous",
        }

      }
    }

    // loki write endpoint
    loki.write "endpoint" {
      external_labels =  {
        cluster = "{{ .Values.cluster }}",
        project = "{{ .Values.project }}",
      }
      endpoint {
        url = "https://loki.example.com/loki/api/v1/push"
      }
    }
```
### Helm Chart Links
The link below will take you to the Grafana Alloy chart, providing a comprehensive list of configurable options to help you further customize your setup.

[Alloy Helm Chart](https://github.com/grafana/alloy/blob/main/operations/helm/charts/alloy/values.yaml)

---

By following this guide, you'll successfully configure Alloy to send logs and metrics to Grafana Loki and Mimir. The setup will ensure that Alloy collects the necessary observability data from your environment and forwards logs to Loki and metrics to Mimir for analysis and storage. This configuration will allow you to monitor your system's logs and metrics efficiently through Grafana.