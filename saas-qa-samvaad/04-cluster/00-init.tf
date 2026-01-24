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

locals {
  gateway_ip_name            = data.terraform_remote_state.network.outputs.gateway_ip_name
  kong_gateway_cert_map_name = data.terraform_remote_state.network.outputs.kong_gateway_cert_map_name
  glb_cert_map_id            = data.terraform_remote_state.network.outputs.glb_cert_map_id
}

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "02-infra"
  }
}

locals {
  cluster_name                  = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_dns_endpoint          = data.terraform_remote_state.infra.outputs.endpoint_dns
  ca_certificate                = data.terraform_remote_state.infra.outputs.ca_certificate
}

data "terraform_remote_state" "service-deps" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "03-service-deps"
  }
}
locals {
  service_accounts  = data.terraform_remote_state.service-deps.outputs.service_accounts
}
