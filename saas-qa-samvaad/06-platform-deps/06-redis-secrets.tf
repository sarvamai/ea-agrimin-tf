data "kubernetes_secret" "redis_password_secret" {
  metadata {
    name      = "redis-password-secret"
    namespace = "redis"
  }
}

resource "kubernetes_config_map" "agents_redis_config" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "agents-redis-env"
    namespace = each.key
  }

  data = {
    "REDIS_HOST" = "redis-master.redis.svc.cluster.local"
    "REDIS_PORT" = "6379"
  }
}

resource "kubernetes_secret_v1" "redis_secrets" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "agents-redis-secrets"
    namespace = each.key
  }

  data = {
    "REDIS_PASSWORD"   = data.kubernetes_secret.redis_password_secret.data["redis-password"]
    "REDIS_URL_PREFIX" = "redis://:${data.kubernetes_secret.redis_password_secret.data["redis-password"]}@redis-master.redis.svc.cluster.local:6379"
  }
}
