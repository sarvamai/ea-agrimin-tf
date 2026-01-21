resource "google_service_account" "clickhouse_backup_sa" {
  account_id   = "${local.env_prefix}-chi-backup-sa"
  lifecycle {
    prevent_destroy = true
  }
  display_name = "Service Account for ClickHouse Backups to GCS"
}

resource "google_storage_bucket_iam_member" "backup_sa_storage_admin" {
  bucket = local.clickhouse_backup_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.clickhouse_backup_sa.email}"
}

resource "google_service_account_key" "backup_sa_key" {
  service_account_id = google_service_account.clickhouse_backup_sa.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_secret_manager_secret" "backup_secret_container" {
  secret_id = "clickhouse-backup-credentials"

  replication {
    user_managed {
      replicas {
        location = local.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "backup_sa_key_version" {
  secret      = google_secret_manager_secret.backup_secret_container.id
  secret_data = base64decode(google_service_account_key.backup_sa_key.private_key)
}

