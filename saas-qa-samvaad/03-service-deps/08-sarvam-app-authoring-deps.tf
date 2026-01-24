resource "google_service_account" "sarvam_app_authoring_gsa" {
  account_id = "sarvam-app-authoring-service"
}

resource "google_storage_bucket_iam_member" "authoring_service_auth_storage_ra" {
  bucket     = local.publicaccess_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sarvam_app_authoring_gsa.email}"
  depends_on = [google_service_account.sarvam_app_authoring_gsa]
}

resource "google_storage_bucket_iam_member" "authoring_service_app_storage_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sarvam_app_authoring_gsa.email}"
  depends_on = [google_service_account.sarvam_app_authoring_gsa]
}

resource "google_service_account_iam_member" "authoring_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_app_authoring_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/sarvam-app-authoring-service]"
}

resource "google_service_account_iam_member" "authoring_runtime_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_app_authoring_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/sarvam-app-authoring-service]"
}

locals {
  authoring_service_accounts = {
    "sarvam-app-authoring-authoring" = {
      "name"                 = "sarvam-app-authoring-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "sarvam-app-authoring-service"
      "sa_email"             = google_service_account.sarvam_app_authoring_gsa.email
    }
    "sarvam-app-authoring-runtime" = {
      "name"                 = "sarvam-app-authoring-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "sarvam-app-authoring-service"
      "sa_email"             = google_service_account.sarvam_app_authoring_gsa.email
    }
  }
}