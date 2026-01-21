module "samvaad_node_pool_1" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "samvaad-pool-1"

  autoscaling = {
    min_node_count = 10
    max_node_count = 20
  }

  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "384"

    taints = [
      {
        key    = "role"
        value  = "agents"
        effect = "NO_SCHEDULE"
      }
    ]

    # Labels: Used by the DaemonSet and Postgres Affinity
    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "agents"
      "role"          = "agents"
    }
        tags = ["fw-route"]
  }
}

module "samvaad_node_pool_2" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "samvaad-pool-2"

  autoscaling = {
    min_node_count = 10
    max_node_count = 20
  }

  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "384"

    taints = [
      {
        key    = "role"
        value  = "agents"
        effect = "NO_SCHEDULE"
      }
    ]

    # Labels: Used by the DaemonSet and Postgres Affinity
    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "agents"
      "role"          = "agents"
    }
        tags = ["fw-route"]
  }
}

module "pg_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "pg-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 2
  }

  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "UBUNTU_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    # NVMe Configuration: only can use [0, 1, 2, 4, 8, 16, 24] with n2d
    local_nvme_ssd_block_config = {
      local_ssd_count = 4
    }
    disk_type = "pd-balanced"

    # Taints: Prevents random pods from eating your NVMe IOPS
    taints = [
      {
        key    = "role"
        value  = "pg"
        effect = "NO_SCHEDULE"
      }
    ]

    # Labels: Used by the DaemonSet and Postgres Affinity
    labels = {
      "role" = "pg"
    }
        tags = ["fw-route"]
  }
}

module "operator_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "operator-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 5
  }


  node_config = {
    machine_type    = "n2d-standard-2"
    image_type      = "UBUNTU_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type = "pd-balanced"

    taints = [
      {
        key    = "role"
        value  = "operator"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "role" = "operator"
    }
        tags = ["fw-route"]
  }
}

module "clickhouse_samvaad_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "chi-samvaad-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 2
  }

  node_config = {
    machine_type    = "n2d-custom-16-32768"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "chisamvaad"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "chisamvaad"
      "role"          = "chisamvaad"
      "chi-node"      = "true"
      "chk-node"      = "true"
    }
        tags = ["fw-route"]
  }
}

module "clickhouse_keeper_samvaad_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = ["asia-south1-c"]
  cluster        = module.gke.cluster_name
  name           = "chk-samvaad-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 2
  }

  node_config = {
    machine_type    = "n2d-standard-2"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "chksamvaad"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "chksamvaad"
      "role"          = "chksamvaad"
      "chk-node"      = "true"
    }
        tags = ["fw-route"]
  }
}

module "redis_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "redis-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 2
  }

  node_config = {
    machine_type    = "n2d-highmem-4"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "redis"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "redis"
      "role"          = "redis"
    }
        tags = ["fw-route"]
  }
}

module "openbao_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b", "asia-south1-c"]
  cluster        = module.gke.cluster_name
  name           = "openbao-pool"

  autoscaling = {
    min_node_count = 2
    max_node_count = 3
  }

  node_config = {
    machine_type    = "n2d-standard-2"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "openbao"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "openbao"
      "role"          = "openbao"
    }
        tags = ["fw-route"]
  }
}

module "gateway_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b", "asia-south1-c"]
  cluster        = module.gke.cluster_name
  name           = "gateway-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 3
  }

  node_config = {
    machine_type    = "n2d-standard-4"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "gateway"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "gateway"
      "role"          = "gateway"
    }
        tags = ["fw-route"]
  }
}

module "monitoring_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b"]
  cluster        = module.gke.cluster_name
  name           = "monitoring-pool"

  autoscaling = {
    min_node_count = 3
    max_node_count = 5
  }


  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "monitoring"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "monitoring"
      "role"          = "monitoring"
    }
        tags = ["fw-route"]
  }
}

module "kafka_node_pool" {
  source = "../modules/gke-node-pool"


  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, "asia-south1-b", "asia-south1-c"]
  cluster        = module.gke.cluster_name
  name           = "kafka-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 3
  }

  node_config = {
    machine_type    = "n2d-highmem-4"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "kafka"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "kafka"
      "role"          = "kafka"
    }
        tags = ["fw-route"]
  }
}

module "flagsmith_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone]
  cluster        = module.gke.cluster_name
  name           = "flagsmith-pool"

  autoscaling = {
    min_node_count = 2
    max_node_count = 5
  }

  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "flagsmith"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "flagsmith"
      "role"          = "flagsmith"
    }
        tags = ["fw-route"]
  }
}

module "argocd_node_pool" {
  source = "../modules/gke-node-pool"

  project_id     = local.project_id
  location       = local.region
  node_locations = [local.zone, local.zone, "asia-south1-b", "asia-south1-c"]
  cluster        = module.gke.cluster_name
  name           = "argocd-pool"

  autoscaling = {
    min_node_count = 1
    max_node_count = 2
  }

  node_config = {
    machine_type    = "n2d-standard-8"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_node_sa.email

    disk_type    = "pd-balanced"
    disk_size_gb = "128"

    taints = [
      {
        key    = "role"
        value  = "argocd"
        effect = "NO_SCHEDULE"
      }
    ]

    labels = {
      "nodepool-type" = "user"
      "nodepoolos"    = "linux"
      "product"       = "argocd"
      "role"          = "argocd"
    }
        tags = ["fw-route"]
  }
}

