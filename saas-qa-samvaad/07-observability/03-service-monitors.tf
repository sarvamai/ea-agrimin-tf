
resource "kubernetes_manifest" "postgres_podmonitor_all" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "postgres-cluster"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "cnpg.io/cluster" = "postgres-cluster"
        }
      }
      namespaceSelector = {
        matchNames = ["postgres"]
      }
      podMetricsEndpoints = [
        {
          port = "metrics"
        }
      ]
    }
  }
}
