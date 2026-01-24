resource "google_service_account" "v2v_log_ui_gsa" {
  account_id = "v2v-log-ui"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_iam_member" "v2v_log_ui_workload_identity_binding" {
  service_account_id = google_service_account.v2v_log_ui_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-runtime/v2v-log-ui]"
}

locals {
  v2v_log_ui_service_accounts = {
    "v2v-log-ui-runtime" = {
      "name"                 = "v2v-log-ui"
      "namespace"            = "apps-runtime"
      "service_account_name" = "v2v-log-ui"
      "sa_email"             = google_service_account.v2v_log_ui_gsa.email
    }
  }
}