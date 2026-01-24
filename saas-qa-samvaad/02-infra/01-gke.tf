locals {
  master_ipv4_cidr_block = "172.16.0.0/28"
  default_workload_pool  = "${local.project_id}.svc.id.goog"
}

resource "google_service_account" "gke_node_sa" {
  account_id   = "${local.env_prefix}-gke-node-sa"
  display_name = "GKE Autopilot Node Service Account"
  project      = local.project_id
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset([
    "roles/container.defaultNodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader"
  ])
  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/gke-standard-cluster"
  version = "43.0.0"

  project_id = local.project_id
  name       = "moa-sarvam-ai-gke-cluster"
  location   = local.region

  network    = local.network_name
  subnetwork = local.gke_subnet_name

  ip_allocation_policy = {
    cluster_secondary_range_name  = local.gke_pods_secondary_range_name
    services_secondary_range_name = local.gke_services_secondary_range_name
  }

  # Production Security: Master Authorized Networks
  # Only these IPs can talk to the K8s API
  master_authorized_networks_config = {
    cidr_blocks = [
      {
        cidr_block   = "0.0.0.0/0"
        display_name = "ArgoCD"
      },
      {
        cidr_block   = "${local.vpc_subnet_prefix}.0.0/16"
        display_name = "VPC-Internal"
      }
    ]
  }

  private_cluster_config = {
    enable_private_endpoint = false # Set to true if you ONLY want access via VPN/Interconnect
    enable_private_nodes    = true
    master_global_access_config = {
      enabled = false
    }
  }

  control_plane_endpoints_config = {
    dns_endpoint_config = {
      allow_external_traffic = true
    }
  }

  # Standard Mode Node Management Strategy
  remove_default_node_pool = true
  initial_node_count       = 1

  # Production Guardrails
  release_channel = {
    channel = "REGULAR"
  }
  deletion_protection = false

  workload_identity_config = {
    workload_pool = local.default_workload_pool
  }

  #cluster_autoscaling = {}

  maintenance_policy = {
    recurring_window = {
      start_time = "2026-01-01T00:00:00Z"
      end_time   = "2026-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  gateway_api_config = {
    channel = "CHANNEL_STANDARD"
  }

  addons_config = {
    gke_backup_agent_config = { enabled = true }
    secret_manager_config   = { enabled = true }
    dns_cache_config        = { enabled = true }
  }

  secret_manager_config = {
    enabled = true
  }

  logging_config = {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config = {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  datapath_provider          = "ADVANCED_DATAPATH"
  private_ipv6_google_access = "PRIVATE_IPV6_GOOGLE_ACCESS_DISABLED"

}
