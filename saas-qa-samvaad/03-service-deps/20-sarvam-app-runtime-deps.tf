resource "google_service_account" "app_runtime_gsa" {
  account_id = "app-runtime-service"
}

resource "google_storage_bucket_iam_member" "app_storage_ra" {
  bucket     = local.app_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.app_runtime_gsa.email}"
  depends_on = [google_service_account.app_runtime_gsa]
}

resource "google_service_account_iam_member" "app_runtime_workload_identity_binding" {
  service_account_id = google_service_account.app_runtime_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/app-runtime-service]"
}

locals {
  app_runtime_service_account = {
    "app-runtime-service-apps-runtim" = {
      "name"                 = "app-runtime-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "app-runtime-service"
      "sa_email"             = google_service_account.app_runtime_gsa.email
    }
  }
}
