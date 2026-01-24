# variable "peering_index" {
#   type = number
# }
variable "backend_bucket_name" {
  description = "The GCS bucket name for the Terraform backend"
  type        = string
}
variable "env_prefix" {
  type = string
}
variable "project_id" {
  type = string
}