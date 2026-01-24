locals {
  repositories = [
    "samvaad",
    "samvaad-charts",
    "kafka-connect-gcp"
  ]
}

resource "google_artifact_registry_repository" "this" {
  for_each      = toset(local.repositories)
  location      = "asia-south1"
  repository_id = each.value
  description   = "Docker repository for application images"
  format        = "DOCKER"
  project       = local.project_id

  docker_config {
    immutable_tags = false
  }
}
