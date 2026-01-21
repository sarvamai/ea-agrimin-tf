resource "google_service_account" "monitoring_sa" {
  account_id   = "${local.env_prefix}-monitoring-sa"
  display_name = "Monitoring Service Account"
}

resource "google_storage_bucket_iam_member" "monitoring_bucket_binding" {
  bucket = local.thanos_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.monitoring_sa.email}"
}

resource "google_service_account_iam_member" "monitoring_workload_binding" {
  service_account_id = google_service_account.monitoring_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[monitoring/monitoring-service]"
}

locals {
  monitoring_service_account = {
    "monitoring-service" = {
      "name"                 = "monitoring-service"
      "namespace"            = "monitoring"
      "service_account_name" = "monitoring-service"
      "sa_email"             = google_service_account.monitoring_sa.email
    }
  }
}
