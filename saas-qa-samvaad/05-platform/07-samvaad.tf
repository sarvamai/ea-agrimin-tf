resource "random_password" "samvaad_db_password" {
  length  = 24
  special = false # Postgres sometimes dislikes complex special chars in auth
}

resource "kubernetes_secret" "samvaad_db_creds_cnpg" {
  metadata {
    name      = "samvaad-db-creds"
    namespace = "postgres"
  }

  data = {
    username = "samvaad"
    password = random_password.samvaad_db_password.result
  }

  type = "kubernetes.io/basic-auth"
}