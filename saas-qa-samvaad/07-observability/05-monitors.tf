

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

resource "kubernetes_manifest" "strimzi_kafka_stack_podmonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "strimzi-kafka-stack"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["kafka"]
      }
      selector = {
        matchExpressions = [
          {
            key      = "strimzi.io/kind"
            operator = "Exists"
          }
        ]
      }
      podMetricsEndpoints = [
        {
          port     = "tcp-prometheus"
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
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_kind"]
              targetLabel  = "strimzi_kind"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_name"]
              targetLabel  = "strimzi_name"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_cluster"]
              targetLabel  = "kafka_cluster"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "strimzi_kafka_by_port_podmonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "strimzi-kafka-by-port"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["kafka"]
      }
      selector = {
        matchLabels = {}
      }
      podMetricsEndpoints = [
        {
          targetPort = 9404
          path       = "/metrics"
          interval   = "30s"
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
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_kind"]
              targetLabel  = "strimzi_kind"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_name"]
              targetLabel  = "strimzi_name"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_cluster"]
              targetLabel  = "kafka_cluster"
            },
            {
              sourceLabels = ["__meta_kubernetes_pod_label_strimzi_io_name"]
              regex        = ".*-kafka-exporter"
              targetLabel  = "strimzi_kind"
              replacement  = "KafkaExporter"
            }
          ]
        }
      ]
    }
  }
}

# resource "kubernetes_manifest" "node_exporter_sm" {
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "ServiceMonitor"

#     metadata = {
#       name      = "node-exporter"
#       namespace = "monitoring"
#       labels = {
#         release                     = "prometheus"
#         "app.kubernetes.io/name"    = "prometheus-node-exporter"
#       }
#     }

#     spec = {
#       jobLabel = "node-exporter"

#       selector = {
#         matchLabels = {
#           "app.kubernetes.io/name" = "prometheus-node-exporter"
#         }
#       }

#       namespaceSelector = {
#         matchNames = ["monitoring", "kube-system", "prometheus"]
#       }

#       endpoints = [{
#         port           = "http-metrics"
#         interval       = "30s"
#         scrapeTimeout  = "10s"
#         path           = "/metrics"

#         relabelings = [
#           {
#             sourceLabels = ["__meta_kubernetes_pod_node_name"]
#             targetLabel  = "node"
#           },
#           {
#             sourceLabels = ["__meta_kubernetes_endpoint_node_name"]
#             targetLabel  = "instance"
#           }
#         ]
#       }]
#     }
#   }
# }

# resource "kubernetes_manifest" "kube_state_metrics_sm" {
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "ServiceMonitor"

#     metadata = {
#       name      = "kube-state-metrics"
#       namespace = "monitoring"
#       labels = {
#         release                  = "prometheus"
#         "app.kubernetes.io/name" = "kube-state-metrics"
#       }
#     }

#     spec = {
#       jobLabel = "app.kubernetes.io/name"

#       selector = {
#         matchLabels = {
#           "app.kubernetes.io/name" = "kube-state-metrics"
#         }
#       }

#       namespaceSelector = {
#         matchNames = ["monitoring", "kube-system"]
#       }

#       endpoints = [
#         {
#           port          = "http"
#           path          = "/metrics"
#           interval      = "30s"
#           scrapeTimeout = "10s"
#           honorLabels   = true
#         },
#       ]
#     }
#   }
# }

/* resource "kubernetes_manifest" "node_exporter_pm" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"

    metadata = {
      name      = "node-exporter"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }

    spec = {
      jobLabel = "node-exporter"

      namespaceSelector = {
        matchNames = ["monitoring", "kube-system"]
      }

      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "prometheus-node-exporter"
        }
      }

      podMetricsEndpoints = [{
        port     = "metrics"
        path     = "/metrics"
        interval = "30s"

        relabelings = [
          {
            sourceLabels = ["__meta_kubernetes_pod_node_name"]
            targetLabel  = "node"
          },
          {
            sourceLabels = ["__meta_kubernetes_pod_node_name"]
            targetLabel  = "instance"
          }
        ]
      }]
    }
  }
} */

# resource "kubernetes_manifest" "kube_state_metrics_pm" {
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "PodMonitor"

#     metadata = {
#       name      = "kube-state-metrics"
#       namespace = "monitoring"
#       labels = {
#         release = "prometheus"
#       }
#     }

#     spec = {
#       jobLabel = "kube-state-metrics"

#       namespaceSelector = {
#         matchNames = ["monitoring", "kube-system"]
#       }

#       selector = {
#         matchLabels = {
#           "app.kubernetes.io/name" = "kube-state-metrics"
#         }
#       }

#       podMetricsEndpoints = [{
#         port        = "http"
#         path        = "/metrics"
#         interval    = "30s"
#         honorLabels = true
#       }]
#     }
#   }
# }