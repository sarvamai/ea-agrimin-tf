
data "kubernetes_secret_v1" "clickhouse_samvaad_grafana_password" {
  metadata {
    name      = "clickhouse-samvaad-grafana-secret"
    namespace = "clickhouse-samvaad"
  }
}

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