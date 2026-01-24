resource "grafana_message_template" "slack_title" {
  provider = grafana.selfhosted

  name     = "slack.title"
  template = <<-EOT
{{ define "slack.title" }}{{ if gt (len .Alerts.Firing) 0 }}🚨 ALERT: {{ end }}{{ if gt (len .Alerts.Resolved) 0 }}✅ RESOLVED: {{ end }}{{ .CommonLabels.alertname }}{{ end }}
EOT
}

resource "grafana_message_template" "slack_message" {
  provider = grafana.selfhosted

  name     = "slack.message"
  template = <<-EOT
{{ define "slack.message" }}{{ if gt (len .Alerts.Firing) 0 }}{{ range .Alerts.Firing }}*Severity:* {{ .Annotations.severity }}
<{{ .GeneratorURL }}|View in Grafana>
{{ if .Annotations.doc }}📖 <{{ .Annotations.doc }}|Docs>{{ end }}

{{ .Annotations.FiringAlertValues }}
━━━━━━━━━━━━━━━━━━━━━━
{{ end }}{{ end }}{{ if gt (len .Alerts.Resolved) 0 }}{{ range .Alerts.Resolved }}{{ .Annotations.ResolvedAlertValues }}
━━━━━━━━━━━━━━━━━━━━━━
{{ end }}{{ end }}{{ end }}
EOT
}

resource "grafana_contact_point" "slack_contact_points" {
  provider = grafana.selfhosted

  for_each = local.slack_webhooks
  name     = each.key

  slack {
    url                     = each.value
    title                   = "{{ template \"slack.title\" . }}"
    text                    = "{{ template \"slack.message\" . }}"
    disable_resolve_message = false
  }

  depends_on = [
    grafana_message_template.slack_title,
    grafana_message_template.slack_message
  ]
}

resource "grafana_notification_policy" "sh_team_notification_policies" {
  provider = grafana.selfhosted

  contact_point = grafana_contact_point.slack_contact_points[local.default_slack_channel].name

  disable_provenance = true

  group_by = ["..."]

  group_wait      = "1s"
  group_interval  = "1m"
  repeat_interval = "4h"

  dynamic "policy" {
    for_each = local.slack_webhooks

    content {
      contact_point = grafana_contact_point.slack_contact_points[policy.key].name

      matcher {
        label = "team"
        match = "="
        value = policy.key
      }
    }
  }
}

resource "grafana_folder" "sh_alert_folders" {
  provider = grafana.selfhosted

  for_each = local.alerts_sub_folders
  title    = each.key
}