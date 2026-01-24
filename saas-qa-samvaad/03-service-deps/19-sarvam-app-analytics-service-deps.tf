resource "google_service_account" "analytics_service_gsa" {
  account_id = "sarvam-app-analytics-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "analytics_service_app_storage_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.analytics_service_gsa.email}"
  depends_on = [google_service_account.analytics_service_gsa]
}

resource "google_storage_bucket_iam_member" "analytics_service_public_app_storage_ra" {
  bucket     = local.public_app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.analytics_service_gsa.email}"
  depends_on = [google_service_account.analytics_service_gsa]
}

resource "google_storage_bucket_iam_member" "analytics_service_failed_events_storage_ra" {
  bucket     = local.failed_events_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.analytics_service_gsa.email}"
  depends_on = [google_service_account.analytics_service_gsa]
}

resource "google_service_account_iam_member" "analytics_workload_identity_binding" {
  service_account_id = google_service_account.analytics_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/sarvam-app-analytics-service]"
}

locals {
  analytics_service_accounts = {
    "sarvam-app-analytics-runtime" = {
      "name"                 = "sarvam-app-analytics-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "sarvam-app-analytics-service"
      "sa_email"             = google_service_account.analytics_service_gsa.email
    }
  }
}