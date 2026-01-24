module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 13.0"

  project_id   = local.project_id
  network_name = "moa-sarvam-ai-pri"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "moa-sarvam-ai-pri-sub"
      subnet_ip             = "10.10.150.0/24"
      subnet_region         = local.region
      subnet_private_access = "true"
    },
    # Proxy-Only Subnet for Internal Load Balancers
    {
      subnet_name   = "proxy-only-subnet"
      subnet_ip     = "10.10.153.0/24"
      subnet_region = local.region
      purpose       = "REGIONAL_MANAGED_PROXY"
      role          = "ACTIVE"
    }
  ]

  secondary_ranges = {
    "moa-sarvam-ai-pri-sub" = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "172.18.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "172.17.0.0/16"
      }
    ]
  }
}

###############################
# Private Service Access (PSA)
##############################
# What is it?
# creating a private IP range in your VPC and then peering your 
# VPC with Google-managed services so that services like Cloud SQL, Memorystore, Filestore, etc. get private IPs inside your VPC.
resource "google_compute_global_address" "private_service_access" {
  name          = "google-managed-services-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  address       = "10.10.152.0"
  network       = module.vpc.network_id
  project       = local.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
}

################################
# Private Service Connect (PSC)
################################
# GCS and GCR are "Global" Google services. To access them privately, we use Private Service Connect (PSC).
# Private DNS Zones are used here
# it reservce a Global Internal IP address
module "private_service_connect" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 13.0"

  project_id                 = local.project_id
  network_self_link          = module.vpc.network_self_link
  private_service_connect_ip = "10.10.151.5"
  forwarding_rule_target     = "all-apis"
}
