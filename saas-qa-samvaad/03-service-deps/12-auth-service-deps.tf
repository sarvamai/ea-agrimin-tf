resource "google_service_account" "auth_service_gsa" {
  account_id = "auth-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "app_storage_auth_service_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.auth_service_gsa.email}"
  depends_on = [google_service_account.auth_service_gsa]
}

resource "google_service_account_iam_member" "auth_service_workload_identity_binding" {
  service_account_id = google_service_account.auth_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/auth-service]"
}

locals {
  auth_service_accounts = {
    "auth-service-authoring" = {
      "name"                 = "auth-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "auth-service"
      "sa_email"             = google_service_account.auth_service_gsa.email
    }
  }
}