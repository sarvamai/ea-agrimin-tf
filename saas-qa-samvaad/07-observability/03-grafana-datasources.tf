
data "kubernetes_secret_v1" "clickhouse_samvaad_grafana_password" {
  metadata {
    name      = "clickhouse-samvaad-grafana-secret"
    namespace = "clickhouse-samvaad"
  }
}

#####################################
# Official Grafana ClickHouse Plugin
# Requires: ClickHouse 22.7+ for ad hoc filters
# Note: Readonly user must have max_execution_time changeable_in_readonly

resource "grafana_data_source" "datasource_clickhouse_samvaad" {
  provider = grafana.selfhosted

  type = "grafana-clickhouse-datasource"
  name = "clickhouse-samvaad-datasource"

  url         = "clickhouse-service.clickhouse-samvaad"
  access_mode = "proxy"

  json_data_encoded = jsonencode({
    defaultDatabase = "default"
    secure          = false
    host            = "clickhouse-service.clickhouse-samvaad"
    logs = {
      contextColumns       = []
      defaultTable         = "otel_logs"
      otelVersion          = "latest"
      selectContextColumns = true
    }
    pdcInjected = false
    traces = {
      defaultTable = "otel_traces"
      durationUnit = "nanoseconds"
      otelVersion  = "latest"
    }
    version  = "4.11.1"
    port     = "8123"
    protocol = "http"
    username = "grafana"
  })

  secure_json_data_encoded = jsonencode({
    password = nonsensitive(
     data.kubernetes_secret_v1.clickhouse_samvaad_grafana_password.data["CLICKHOUSE_DB_GRAFANA_SECRET"]
    )
  })
}

########################################
# Altinity ClickHouse Datasource Plugin
# https://grafana.com/grafana/plugins/vertamedia-clickhouse-datasource/
# Note: User has readonly permissions
########################################
resource "grafana_data_source" "datasource_clickhouse_altinity" {
  provider = grafana.selfhosted

  type = "vertamedia-clickhouse-datasource"
  name = "clickhouse-samvaad-altinity"

  url         = "http://clickhouse-service.clickhouse-samvaad.svc.cluster.local:8123"
  access_mode = "proxy"

  json_data_encoded = jsonencode({
    defaultDatabase = "default"
    usePOST         = true
  })

  basic_auth_enabled  = true
  basic_auth_username = "grafana"

  secure_json_data_encoded = jsonencode({
    basicAuthPassword = nonsensitive(
      data.kubernetes_secret_v1.clickhouse_samvaad_grafana_password.data["CLICKHOUSE_DB_GRAFANA_SECRET"]
    )
  })
}