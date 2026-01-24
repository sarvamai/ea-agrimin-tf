# data "google_secret_manager_secret_version" "grafana_google_client_secret" {
#   secret  = "grafana-google-client-secret"
#   version = "latest"
# }

resource "kubernetes_secret_v1" "thanos_objstore" {
  metadata {
    name      = "thanos-objstore"
    namespace = "monitoring"
  }

  data = {
    "objstore.yml" = yamlencode({
      type = "GCS"
      config = {
        bucket = local.thanos_bucket_name
      }
    })
  }
  type = "Opaque"
}

resource "kubernetes_secret" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = "monitoring"
  }

  data = {
    "GF_DATABASE_PASSWORD"         = local.grafana_db_password
    #"GF_AUTH_GOOGLE_CLIENT_SECRET" = data.google_secret_manager_secret_version.grafana_google_client_secret.secret_data
  }

  type = "Opaque"
}