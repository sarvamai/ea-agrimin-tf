
resource "google_service_account" "cnpg_backup_sa" {
  account_id   = "cnpg-backup-sa"
  display_name = "CloudNativePG Backup Service Account"
  project      = local.project_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "backup_bucket_binding" {
  bucket = local.postgres_backup_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cnpg_backup_sa.email}"
}

resource "google_service_account_iam_member" "cnpg_workload_identity_binding" {
  service_account_id = google_service_account.cnpg_backup_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[postgres/postgres-cluster]"
}
