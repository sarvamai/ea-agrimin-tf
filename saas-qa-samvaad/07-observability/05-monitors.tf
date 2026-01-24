

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