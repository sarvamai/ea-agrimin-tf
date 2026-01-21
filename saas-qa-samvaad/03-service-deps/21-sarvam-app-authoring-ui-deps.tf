resource "google_service_account" "sarvam_authoring_ui_gsa" {
  account_id = "sarvam-authoring-ui"
}

locals {
  sarvam_authoring_ui_service_account = {
    "sarvam-authoring-ui-service" = {
      "name"                 = "sarvam-authoring-ui"
      "namespace"            = "apps-authoring"
      "service_account_name" = "sarvam-authoring-ui"
      "sa_email"             = google_service_account.sarvam_authoring_ui_gsa.email
    }
  }
}
