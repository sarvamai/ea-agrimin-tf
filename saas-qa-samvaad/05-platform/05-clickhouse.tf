# TODO: SHift to 05
locals {
  secrets_name = [
    "chi-metabase-secret",
    "chi-harish-secret",
    "chi-avi-secret",
    "chi-analytics-secret",
    "chi-grafana-secret",
    "clickhouse-backup-credentials"
  ]
}

data "google_secret_manager_secret_version" "this" {
  for_each = toset(local.secrets_name)
  secret   = each.value
  version  = "latest"
}

##############
# Clickhouse
##############
resource "kubernetes_secret_v1" "clickhouse_db_secrets" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "clickhouse-samvaad-db-secrets"
    namespace = each.key
  }

  data = {
    CLICKHOUSE_DB_AVI_SECRET           = data.google_secret_manager_secret_version.this["chi-grafana-secret"].secret_data
    CLICKHOUSE_DB_HARISH_SECRET        = data.google_secret_manager_secret_version.this["chi-harish-secret"].secret_data
    CLICKHOUSE_DB_GRAFANA_SECRET       = data.google_secret_manager_secret_version.this["chi-grafana-secret"].secret_data
    CLICKHOUSE_DB_ANALYTICS_SVC_SECRET = data.google_secret_manager_secret_version.this["chi-analytics-secret"].secret_data
    CLICKHOUSE_DB_METABASE_SECRET      = data.google_secret_manager_secret_version.this["chi-metabase-secret"].secret_data
  }
}

resource "kubernetes_secret_v1" "clickhouse_backup_secrets" {
  metadata {
    name      = "chi-samvaad-backup-secrets"
    namespace = "clickhouse-samvaad"
  }

  data = {
    GCS_BUCKET           = local.clickhouse_backup_bucket_name
    GCS_CREDENTIALS_JSON = data.google_secret_manager_secret_version.this["clickhouse-backup-credentials"].secret_data
  }
}

resource "kubernetes_secret_v1" "clickhouse_samvaad_grafana_secrets" {
  metadata {
    name      = "clickhouse-samvaad-grafana-secret"
    namespace = "clickhouse-samvaad"
  }

  data = {
    CLICKHOUSE_DB_GRAFANA_SECRET = data.google_secret_manager_secret_version.this["chi-grafana-secret"].secret_data
  }
}
