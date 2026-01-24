resource "kubernetes_secret" "gcs_service_account_secret" {
  metadata {
    name      = "gcs-service-account-secret"
    namespace = "kafka"
  }

  type = "Opaque"

  data = {
    "gcs_credentials.json" = base64decode(local.kafka_sink_sa_key)
  }
}

resource "kubernetes_secret" "gcs_key_secret" {
  metadata {
    name      = "gcs-key-secret"
    namespace = "kafka"
  }
  lifecycle {
    ignore_changes = [data]
  }
}

resource "google_service_account" "docker_puller" {
  account_id   = "docker-image-puller"
  display_name = "Docker Image Puller SA"
}

# 2. Give it Reader access to Artifact Registry
resource "google_project_iam_member" "docker_puller_access" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.docker_puller.email}"
}

# 3. Generate a JSON Key (Security Warning: State file will contain this key)
resource "google_service_account_key" "docker_puller_key" {
  service_account_id = google_service_account.docker_puller.name
}

# 4. Create the Kubernetes Secret (Equivalent to your Azure code)
# Only use this if your Helm charts explicitly require 'imagePullSecrets'
resource "kubernetes_secret" "docker_config" {
  for_each = toset(local.namespaces) # Ensure local.namespaces is defined in your variables

  metadata {
    name      = "gcp-registry-credentials"
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        # The registry domain (e.g., asia-south1-docker.pkg.dev)
        "${local.registry_location}-docker.pkg.dev" = {
          username = "_json_key"
          password = base64decode(google_service_account_key.docker_puller_key.private_key)
          email    = google_service_account.docker_puller.email
          auth     = base64encode("_json_key:${base64decode(google_service_account_key.docker_puller_key.private_key)}")
        }
      }
    })
  }
}
