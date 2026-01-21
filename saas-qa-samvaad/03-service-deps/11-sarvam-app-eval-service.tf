resource "google_service_account" "sarvam_app_eval_gsa" {
  account_id = "sarvam-app-eval-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "app_storage_eval_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sarvam_app_eval_gsa.email}"
  depends_on = [google_service_account.sarvam_app_eval_gsa]
}

resource "google_service_account_iam_member" "eval_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_app_eval_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/sarvam-app-eval-service]"
}

locals {
  eval_service_accounts = {
    "sarvam-app-eval-authoring" = {
      "name"                 = "sarvam-app-eval-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "sarvam-app-eval-service"
      "sa_email"             = google_service_account.sarvam_app_eval_gsa.email
    }
  }
}