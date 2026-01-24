output "project_id" {
  value = var.project_id
}
output "project_number" {
  value = var.project_number
}
data "google_client_config" "main" {
  provider = google
}
output "vm_service_account_email" {
  value = google_service_account.managment_vm_service_account.email
}
output "zone" {
  value = "asia-south1-a"
}
output "region" {
  value = var.region
}