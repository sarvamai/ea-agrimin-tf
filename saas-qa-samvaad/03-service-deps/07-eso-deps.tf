resource "google_service_account" "eso_sa" {
  account_id   = "eso-service"
  display_name = "ESO Service Account"
  project      = local.project_id
}

resource "google_project_iam_member" "eso_secret_accessor" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_sa.email}"
}

resource "google_service_account_iam_member" "eso_workload_binding" {
  service_account_id = google_service_account.eso_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[external-secrets/eso-service]"
}

resource "google_project_iam_member" "eso_svc_token_generator" {
  project = local.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.eso_sa.email}"
}

locals {
  eso_service_account = {
    "eso-external-secrets-service" = {
      "name"                 = "eso-service"
      "namespace"            = "external-secrets"
      "service_account_name" = "eso-service"
      "sa_email"             = google_service_account.eso_sa.email
    }
    "eso-apps-runtime-service" = {
      "name"                 = "eso-service"
      "namespace"            = "apps-runtime"
      "service_account_name" = "eso-service"
      "sa_email"             = google_service_account.eso_sa.email
    }
    "eso-apps-authoring-service" = {
      "name"                 = "eso-service"
      "namespace"            = "apps-authoring"
      "service_account_name" = "eso-service"
      "sa_email"             = google_service_account.eso_sa.email
    }
    "eso-data-analyst-runtime-service" = {
      "name"                 = "eso-service"
      "namespace"            = "data-analyst-runtime"
      "service_account_name" = "eso-service"
      "sa_email"             = google_service_account.eso_sa.email
    }
    "eso-platform-service" = {
      "name"                 = "eso-service"
      "namespace"            = "platform"
      "service_account_name" = "eso-service"
      "sa_email"             = google_service_account.eso_sa.email
    }
  }
}
