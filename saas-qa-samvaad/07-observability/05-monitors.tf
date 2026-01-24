

resource "kubernetes_manifest" "kafka_pod_monitor" {
  provider = kubernetes

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PodMonitor"
    "metadata" = {
      "name"      = "kafka-pod-monitor"
      
      # IMPORTANT: This should be the namespace where your Prometheus is installed (e.g., "monitoring").
      "namespace" = "monitoring" 
      
      "labels" = {
        # This label helps your Prometheus instance discover this monitor.
        "release" = "prometheus"
      }
    }
    "spec" = {
      # This tells the monitor WHERE TO LOOK for pods. This is correct.
      "namespaceSelector" = {
        "matchNames" = [
          "kafka",
        ]
      }
      # This selector is more specific to Strimzi's core Kafka components.
      "selector" = {
        "matchLabels" = {
          "kafka-metrics" = "true"
        }
      }
      # CORRECTED: Use "podMetricsEndpoints" for a PodMonitor.
      "podMetricsEndpoints" = [
        {
          "port"     = "tcp-prometheus"
          "interval" = "60s"
          # "path" is not needed as "/metrics" is the default.
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "kong_dataplane_podmonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "kong-dataplane"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["kong"]
      }
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "kong-dp"
        }
      }
      podMetricsEndpoints = [
        {
          port     = "status"
          path     = "/metrics"
          interval = "15s"
          relabelings = [
            {
              sourceLabels = ["__meta_kubernetes_namespace"]
              targetLabel  = "namespace"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_name"]
              targetLabel  = "pod"
            },
            {
              targetLabel = "kong_role"
              replacement = "data_plane"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "kong_controlplane_podmonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "kong-controlplane"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["kong"]
      }
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "kong-cp"
        }
      }
      podMetricsEndpoints = [
        {
          port     = "cmetrics"
          path     = "/metrics"
          interval = "30s"
          relabelings = [
            {
              sourceLabels = ["__meta_kubernetes_namespace"]
              targetLabel  = "namespace"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_name"]
              targetLabel  = "pod"
            },
            {
              targetLabel = "kong_role"
              replacement = "control_plane"
            }
          ]
        },
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
          relabelings = [
            {
              sourceLabels = ["__meta_kubernetes_namespace"]
              targetLabel  = "namespace"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_name"]
              targetLabel  = "pod"
            },
            {
              targetLabel = "kong_role"
              replacement = "control_plane"
            }
          ]
        }
      ]
    }
  }
}