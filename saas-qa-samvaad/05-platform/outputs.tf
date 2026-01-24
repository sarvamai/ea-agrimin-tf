output "grafana_db_password" {
  value     = random_password.grafana_db_password.result
  sensitive = true
}
