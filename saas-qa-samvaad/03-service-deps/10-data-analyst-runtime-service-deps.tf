resource "google_service_account" "data_analyst_runtime_gsa" {
  account_id = "data-analyst-runtime-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_iam_member" "data_analyst_runtime_workload_identity_binding" {
  service_account_id = google_service_account.data_analyst_runtime_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[data-analyst-runtime/data-analyst-runtime-service]"
}

locals {
  data_analyst_runtime_service_accounts = {
    "data-analyst-runtime-service" = {
      "name"                 = "data-analyst-runtime-service"
      "namespace"            = "data-analyst-runtime"
      "service_account_name" = "data-analyst-runtime-service"
      "sa_email"             = google_service_account.data_analyst_runtime_gsa.email
    }
  }
}