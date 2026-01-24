resource "google_service_account" "sarvam_vad_service_gsa" {
  account_id = "sarvam-vad-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_iam_member" "vad_authoring_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_vad_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/sarvam-vad-service]"
}

resource "google_service_account_iam_member" "vad_runtime_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_vad_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/sarvam-vad-service]"
}

locals {
  vad_service_accounts = {
    "sarvam-vad-authoring" = {
      "name"                 = "sarvam-vad-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "sarvam-vad-service"
      "sa_email"             = google_service_account.sarvam_vad_service_gsa.email
    }
    "sarvam-vad-runtime" = {
      "name"                 = "sarvam-vad-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "sarvam-vad-service"
      "sa_email"             = google_service_account.sarvam_vad_service_gsa.email
    }
  }
}