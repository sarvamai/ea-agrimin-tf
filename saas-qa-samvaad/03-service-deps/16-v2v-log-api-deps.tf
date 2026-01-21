resource "google_service_account" "v2v_log_api_gsa" {
  account_id = "v2v-log-api"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "v2v_log_api_storage_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.v2v_log_api_gsa.email}"
  depends_on = [google_service_account.v2v_log_api_gsa]
}

resource "google_service_account_iam_member" "v2v_log_api_workload_identity_binding" {
  service_account_id = google_service_account.v2v_log_api_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/v2v-log-api]"
}

locals {
  v2v_log_api_service_accounts = {
    "v2v-log-api-runtime" = {
      "name"                 = "v2v-log-api"
      "namespace"            = "apps-runtime"
      "service_account_name" = "v2v-log-api"
      "sa_email"             = google_service_account.v2v_log_api_gsa.email
    }
  }
}