resource "random_password" "grafana_db_password" {
  length  = 24
  special = false # Postgres sometimes dislikes complex special chars in auth
}

resource "kubernetes_secret" "grafana_db_creds_cnpg" {
  metadata {
    name      = "grafana-db-creds"
    namespace = "postgres"
  }

  data = {
    username = "grafana"
    password = random_password.grafana_db_password.result
  }

  type = "kubernetes.io/basic-auth"
}