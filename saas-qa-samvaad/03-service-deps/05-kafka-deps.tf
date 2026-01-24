resource "google_service_account" "kafka_connect_sa" {
  account_id   = "kafka-connect-connect"
  display_name = "Kafka Connect GCS connect Service Account"
  project      = local.project_id
}

resource "google_storage_bucket_iam_member" "kafka_connect_iam" {
  bucket = local.kafka_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.kafka_connect_sa.email}"
}

resource "google_service_account_key" "kafka_connect_sa_key" {
  service_account_id = google_service_account.kafka_connect_sa.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_service_account_iam_member" "kafka_workload_binding" {
  service_account_id = google_service_account.kafka_connect_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[kafka/kafka-connect-connect]"
}