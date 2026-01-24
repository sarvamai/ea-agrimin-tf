variable "backend_bucket_name" {
  description = "The GCS bucket name for the Terraform backend"
  type        = string
}
variable "env_prefix" {
  type = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "peering_index" {
  description = "The peering index (optional, for compatibility with other modules)"
  type        = number
  default     = 0
}