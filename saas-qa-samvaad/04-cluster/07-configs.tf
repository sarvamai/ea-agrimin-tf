resource "kubernetes_config_map_v1" "observe_env" {
  metadata {
    name      = "observe-env"
    namespace = "platform"
  }

  data = {
    "observe-env" = "true"
  }

  depends_on = [kubernetes_namespace_v1.this["platform"]]
}