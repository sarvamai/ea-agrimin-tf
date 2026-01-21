variable "backend_bucket_name" {
  description = "The GCS bucket name for the Terraform backend"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix (e.g., prod, qa)"
  type        = string
}
variable "project_id" {
  type = string
}
variable "group_name" {
  type = string
}
variable "default_labels" {
  type = map(string)
}
variable "vm_iam_roles" {
  description = "List of IAM roles to assign to the service account"
  type        = list(string)
  default = ["roles/iam.serviceAccountAdmin",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin",
  "roles/secretmanager.admin"]
}
variable "node_pool_iam_roles" {
  description = "List of IAM roles to assign to the service account"
  type        = list(string)
  default = ["roles/iam.serviceAccountAdmin",
  "roles/container.clusterAdmin", "roles/logging.logWriter", "roles/monitoring.metricWriter"]
}
variable "project_number" {
  type = string
}
variable "region" {
  type = string
}