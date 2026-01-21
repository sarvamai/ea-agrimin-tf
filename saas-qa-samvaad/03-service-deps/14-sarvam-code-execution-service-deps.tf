resource "google_service_account" "sarvam_code_execution_gsa" {
  account_id = "sarvam-code-execution-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "sarvam_code_execution_ces_storage_ra" {
  bucket     = local.ces_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sarvam_code_execution_gsa.email}"
  depends_on = [google_service_account.sarvam_code_execution_gsa]
}

resource "google_storage_bucket_iam_member" "sarvam_code_execution_kb_storage_ra" {
  bucket     = local.kb_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sarvam_code_execution_gsa.email}"
  depends_on = [google_service_account.sarvam_code_execution_gsa]
}

resource "google_service_account_iam_member" "sarvam_code_execution_service_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_code_execution_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[data-analyst-runtime/sarvam-code-execution-service]"
}

locals {
  code_execution_service_accounts = {
    "sarvam-code-execution-runtime" = {
      "name"                 = "sarvam-code-execution-service"
      "namespace"            = "data-analyst-runtime"
      "service_account_name" = "sarvam-code-execution-service"
      "sa_email"             = google_service_account.sarvam_code_execution_gsa.email
    }
  }
}