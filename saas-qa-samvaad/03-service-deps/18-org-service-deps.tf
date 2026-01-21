resource "google_service_account" "org_service_gsa" {
  account_id = "org-service"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_iam_member" "org_service_workload_identity_binding" {
  service_account_id = google_service_account.org_service_gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[apps-authoring/org-service]"
}

locals {
  org_service_accounts = {
    "org-service-authoring" = {
      "name"                 = "org-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "org-service"
      "sa_email"             = google_service_account.org_service_gsa.email
    }
  }
}