data "kubernetes_secret" "postgres_agents_secret" {
  metadata {
    name      = "samvaad-db-creds"
    namespace = "postgres"
  }
}

data "kubernetes_secret" "postgres_superuser_secret" {
  metadata {
    name      = "postgres-cluster-superuser"
    namespace = "postgres"
  }
}


resource "kubernetes_secret" "agents_postgres_db_secrets" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "agents-postgres-db-secrets"
    namespace = each.key
  }

  data = {
    DATABASE_PASSWORD   = data.kubernetes_secret.postgres_agents_secret.data["password"]
    DATABASE_PREFIX_URL = "postgresql://${data.kubernetes_secret.postgres_agents_secret.data["username"]}:${data.kubernetes_secret.postgres_agents_secret.data["password"]}@postgres-cluster-rw.postgres.svc.cluster.local:5432"
  }
}

resource "kubernetes_config_map_v1" "agents_postgres_db_env" {
  for_each = toset(local.namespaces)

  metadata {
    name      = "agents-postgres-db-env"
    namespace = each.key
  }

  data = {
    "DATABASE_HOST" = "postgres-cluster-rw.postgres.svc.cluster.local"
    "DATABASE_PORT" = data.kubernetes_secret.postgres_superuser_secret.data["port"]
    "DATABASE_USER" = data.kubernetes_secret.postgres_agents_secret.data["username"]
  }
}
