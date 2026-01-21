resource "kubernetes_storage_class_v1" "clickhouse_retain_zrs" {
  metadata {
    name = "clickhouse-retain-zrs"
  }

  storage_provisioner = "pd.csi.storage.gke.io"

  parameters = {
    type = "pd-ssd"
    replication-type = "regional-pd"
  }

  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_storage_class_v1" "redis_ssd_regional" {
  metadata {
    name = "redis-ssd-regional"
  }

  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type             = "pd-ssd"
    replication-type = "regional-pd"
  }
}