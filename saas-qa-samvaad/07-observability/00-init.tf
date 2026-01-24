data "google_client_config" "main" {}

data "terraform_remote_state" "setup" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "setup.tfstate"
  }
}

locals {
  project_id                      = data.terraform_remote_state.setup.outputs.project_id
  region                          = data.terraform_remote_state.setup.outputs.region
  env_prefix                      = data.terraform_remote_state.setup.outputs.env_prefix
  default_labels                  = data.terraform_remote_state.setup.outputs.default_labels
  node_pool_service_account_email = data.terraform_remote_state.setup.outputs.node_pool_service_account_email
  zone                            = data.terraform_remote_state.setup.outputs.zone
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "01-network"
  }
}

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "02-infra"
  }
}

data "terraform_remote_state" "services-deps" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "03-service-deps"
  }
}

locals {
  cluster_name         = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_dns_endpoint = data.terraform_remote_state.infra.outputs.endpoint_dns
  ca_certificate       = data.terraform_remote_state.infra.outputs.ca_certificate
  thanos_bucket_name   = data.terraform_remote_state.infra.outputs.thanos_bucket_name
}

data "terraform_remote_state" "platform" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "05-platform"
  }
}

locals {
  grafana_db_password = data.terraform_remote_state.platform.outputs.grafana_db_password
}

locals {
  grafana_url = "grafana.agrimin.sarvam.ai"
}

locals {
  monitoring_namespace = "monitoring"
  alerts_path          = "${path.module}/alerts"
  alerts_sub_folders   = setsubtract(flatten([for k, _ in toset(fileset(local.alerts_path, "**")) : dirname(k)]), ["."])
}

data "google_secret_manager_secret_version" "slack_sarvamos_alerts_webhooks_secret" {
  secret  = "slack-sarvamos-alert-webhook-url"
  version = "latest"
}

locals {
  default_slack_channel = "sarvam-os-alerts"
  slack_webhooks = {
    "sarvam-os-alerts" = data.google_secret_manager_secret_version.slack_sarvamos_alerts_webhooks_secret.secret_data
  }
}

data "kubernetes_secret" "chi_grafana_secret" {
  metadata {
    name      = "clickhouse-samvaad-db-secrets"
    namespace = "clickhouse-samvaad"
  }
}

locals {
  chi_grafana_secret = data.kubernetes_secret.chi_grafana_secret.data["CLICKHOUSE_DB_GRAFANA_SECRET"]
}

data "google_secret_manager_secret_version" "grafana_svc_token_secret" {
  secret  = "grafana-service-token"
  version = "latest"
}
