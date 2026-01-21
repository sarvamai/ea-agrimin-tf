data "google_client_config" "main" {}

data "terraform_remote_state" "setup" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "${var.env_prefix}/setup.tfstate"
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
    prefix = "${var.env_prefix}/network.tfstate"
  }
}

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "${var.env_prefix}/infra.tfstate"
  }
}

locals {
  clickhouse_backup_bucket_name = data.terraform_remote_state.infra.outputs.clickhouse_backup_bucket_name
}

data "terraform_remote_state" "service-deps" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "${var.env_prefix}/service-deps.tfstate"
  }
}

locals {
  cluster_name         = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_dns_endpoint = data.terraform_remote_state.infra.outputs.endpoint_dns
  ca_certificate       = data.terraform_remote_state.infra.outputs.ca_certificate
  kafka_sink_sa_key    = data.terraform_remote_state.service-deps.outputs.kafka_sink_sa_key
}

data "terraform_remote_state" "cluster" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "${var.env_prefix}/cluster.tfstate"
  }
}

locals {
  namespaces = data.terraform_remote_state.cluster.outputs.namespaces
}

locals {
  registry_location = "asia-south1"
}
