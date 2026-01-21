# output "cluster_id" {
#   description = "Cluster ID"
#   value       = module.gke.cluster_id
# }
output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.cluster_name
}

# output "location" {
#   description = "Cluster location (region if regional cluster, zone if zonal cluster)"
#   value       = module.gke.location
# }

# output "node_locations" {
#   description = "The list of zones in which the cluster's nodes are located."
#   value       = module.gke.node_locations
# }

# output "endpoint" {
#   description = "Cluster endpoint"
#   value       = module.gke.endpoint
# }

output "endpoint_dns" {
  description = "Cluster endpoint DNS"
  value       = module.gke.endpoint_dns
}

# output "min_master_version" {
# output "logging_service" {
#   description = "Logging service used"
#   value       = module.gke.logging_service
# }




output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.gke.ca_certificate
}
# }
#   value       = module.gke.vertical_pod_autoscaling_enabled
#   value       = module.gke.identity_service_enabled
#   value       = module.gke.intranode_visibility_enabled
#   value       = module.gke.secret_manager_addon_enabled
# }

output "postgres_backup_bucket_name" {
  value = google_storage_bucket.postgres_backup_storage.name
}

output "clickhouse_backup_bucket_name" {
  value = google_storage_bucket.clickhouse_backup.name
}

output "thanos_bucket_name" {
  value = google_storage_bucket.thanos_storage.name
}

output "kafka_bucket_name" {
  value = google_storage_bucket.kafka_storage.name
}

output "app_storage_name" {
  value = google_storage_bucket.app_storage.name
}

output "openbao_backup_bucket_name" {
  value = google_storage_bucket.openbao_backup_storage.name
}

output "publicaccess_storage_name" {
  value = google_storage_bucket.publicaccess_storage.name
}

output "ces_storage_name" {
  value = google_storage_bucket.ces_storage.name
}

output "kb_storage_name" {
  value = google_storage_bucket.kb_storage.name
}

output "public_app_storage_name" {
  value = google_storage_bucket.public_app_storage.name
}

output "failed_events_storage_name" {
  value = google_storage_bucket.failed_events_storage.name
}
