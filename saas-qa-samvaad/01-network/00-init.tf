data "terraform_remote_state" "setup" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = ""
  }
}

data "google_client_config" "main" {}

# Add remote state for infra
data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = var.backend_bucket_name
    prefix = "02-infra"
  }
}

locals {
  project_id               = var.project_id
  region                   = "asia-south1"
  zone                     = "asia-south1-a"
  env_prefix               = var.env_prefix
  default_labels           = {}
  vm_service_account_email = ""
  # Add locals for infra outputs
  cluster_name                  = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_dns_endpoint          = data.terraform_remote_state.infra.outputs.endpoint_dns
  ca_certificate                = data.terraform_remote_state.infra.outputs.ca_certificate
  postgres_backup_bucket_name   = data.terraform_remote_state.infra.outputs.postgres_backup_bucket_name
  clickhouse_backup_bucket_name = data.terraform_remote_state.infra.outputs.clickhouse_backup_bucket_name
  openbao_backup_bucket_name    = data.terraform_remote_state.infra.outputs.openbao_backup_bucket_name
  thanos_bucket_name            = data.terraform_remote_state.infra.outputs.thanos_bucket_name
  kafka_bucket_name             = data.terraform_remote_state.infra.outputs.kafka_bucket_name
  app_storage_name              = data.terraform_remote_state.infra.outputs.app_storage_name
  publicaccess_storage_name     = data.terraform_remote_state.infra.outputs.publicaccess_storage_name
  ces_storage_name              = data.terraform_remote_state.infra.outputs.ces_storage_name
  kb_storage_name               = data.terraform_remote_state.infra.outputs.kb_storage_name
  public_app_storage_name       = data.terraform_remote_state.infra.outputs.public_app_storage_name
  failed_events_storage_name    = data.terraform_remote_state.infra.outputs.failed_events_storage_name
}
