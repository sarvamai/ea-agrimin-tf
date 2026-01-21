#########
# Redis
#########
resource "random_password" "redis_password" {
  length  = 10
  special = false
}

resource "kubernetes_secret" "redis_password_secret" {
  metadata {
    name      = "redis-password-secret"
    namespace = "redis"
  }

  data = {
    "redis-password" = base64encode(random_password.redis_password.result)
  }

  type = "Opaque"
}
