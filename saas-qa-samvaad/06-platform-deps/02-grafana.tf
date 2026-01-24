resource "kubernetes_manifest" "grafana_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "grafana-db"
      namespace = "postgres"
    }
    spec = {
      name  = "grafana"
      owner = "grafana"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}