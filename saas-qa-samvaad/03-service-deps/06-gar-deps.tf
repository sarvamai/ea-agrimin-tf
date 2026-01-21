resource "google_service_account" "gar_connect_sa" {
  account_id   = "gar-connect-connect"
  display_name = "gar Connect GCS connect Service Account"
  project      = local.project_id
}

resource "google_project_iam_member" "gar_puller_access" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gar_connect_sa.email}"
}

resource "google_service_account_key" "gar_puller_key" {
  service_account_id = google_service_account.gar_connect_sa.name
}