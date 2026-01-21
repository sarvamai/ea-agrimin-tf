resource "kubernetes_manifest" "kong_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "kong-db"
      namespace = "postgres"
    }
    spec = {
      name  = "kong" # The database name
      owner = "kong" # Must match the 'name' in kong_role above
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}
