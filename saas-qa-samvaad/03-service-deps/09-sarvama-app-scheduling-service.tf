resource "google_service_account" "sarvam_app_scheduling_gsa" {
  account_id = "sarvam-app-scheduling-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "sarvam_app_scheduling_runtime_gsa" {
  account_id = "scheduling-runtime-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_iam_member" "scheduling_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_app_scheduling_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/sarvam-app-scheduling-service]"
}

resource "google_service_account_iam_member" "scheduling_runtime_workload_identity_binding" {
  service_account_id = google_service_account.sarvam_app_scheduling_runtime_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/sarvam-app-scheduling-runtime-service]"
}

locals {
  scheduling_service_accounts = {
    "sarvam-app-scheduling-authoring" = {
      "name"                 = "sarvam-app-scheduling-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "sarvam-app-scheduling-service"
      "sa_email"             = google_service_account.sarvam_app_scheduling_gsa.email
    }
    "sarvam-app-scheduling-runtime" = {
      "name"                 = "sarvam-app-scheduling-runtime-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "sarvam-app-scheduling-runtime-service"
      "sa_email"             = google_service_account.sarvam_app_scheduling_runtime_gsa.email
    }
  }
}