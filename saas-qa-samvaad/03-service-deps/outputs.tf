output "service_accounts" {
  value = merge(
    local.openbao_service_account,
    local.openbao_backup_service_account,
    local.monitoring_service_account,
    local.app_runtime_service_account,
    local.authoring_service_accounts,
    local.scheduling_service_accounts,
    local.data_analyst_runtime_service_accounts,
    local.eval_service_accounts,
    local.auth_service_accounts,
    local.vad_service_accounts,
    local.code_execution_service_accounts,
    local.kb_service_accounts,
    local.v2v_log_api_service_accounts,
    local.v2v_log_ui_service_accounts,
    local.org_service_accounts,
    local.analytics_service_accounts,
    local.eso_service_account,
    local.sarvam_authoring_ui_service_account
  )
}
output "kafka_sink_sa_key" {
  value     = google_service_account_key.kafka_connect_sa_key.private_key
  sensitive = true
}

output "kafka_sa_email" {
  value = google_service_account.kafka_connect_sa.email
}

output "gar_connect_sa_private_key" {
  sensitive = true
  value     = google_service_account_key.gar_puller_key.private_key
}