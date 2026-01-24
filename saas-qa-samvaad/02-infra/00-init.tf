data "google_client_config" "main" {}

# Using explicit locals to avoid dependency on remote-state outputs
# (remote state prefixes differ across modules in this workspace).
locals {
  project_id                        = "s-0-000236-188"
  region                            = "asia-south1"
  zone                              = "asia-south1-a"
  env_prefix                        = "prod"
  default_labels                    = {}

  # Network values (match current 01-network configuration)
  network_name                      = "moa-sarvam-ai-pri"
  subnets_names                     = {
    "moa-sarvam-ai-pri-sub" = { name = "moa-sarvam-ai-pri-sub" }
    "proxy-only-subnet"     = { name = "proxy-only-subnet" }
  }
  gke_subnet_name                   = "moa-sarvam-ai-pri-sub"
  gke_pods_secondary_range_name     = "gke-pods"
  gke_services_secondary_range_name = "gke-services"
  vpc_subnet_prefix                 = "10.10"
}