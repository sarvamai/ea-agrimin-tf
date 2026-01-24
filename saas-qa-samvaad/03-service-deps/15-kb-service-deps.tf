resource "google_service_account" "kb_service_gsa" {
  account_id = "knowledge-base-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "kb_service_kb_storage_ra" {
  bucket     = local.kb_storage_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.kb_service_gsa.email}"
  depends_on = [google_service_account.kb_service_gsa]
}

resource "google_service_account_iam_member" "kb_workload_identity_binding" {
  service_account_id = google_service_account.kb_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/knowledge-base-service]"
}

locals {
  kb_service_accounts = {
    "knowledge-base-runtime" = {
      "name"                 = "knowledge-base-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "knowledge-base-service"
      "sa_email"             = google_service_account.kb_service_gsa.email
    }
    "knowledge-base-authoring" = {
      "name"                 = "knowledge-base-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "knowledge-base-service"
      "sa_email"             = google_service_account.kb_service_gsa.email
    }
  }
}