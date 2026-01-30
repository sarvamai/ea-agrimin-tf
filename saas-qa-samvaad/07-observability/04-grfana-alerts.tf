locals {

  cnpg_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "cnpg.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  kafka_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "kafka.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  clickhouse_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "clickhouse.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  kong_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "kong.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  redis_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "redis.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  k8s_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "k8s.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  certificate_alerts_by_folder = {
    for folder in local.alerts_sub_folders : folder => flatten([
      for file in fileset("${local.alerts_path}/${folder}", "certificate.json") : jsondecode(file("${local.alerts_path}/${folder}/${file}"))
    ])
  }

  interval_seconds_30s = 30
  interval_seconds_5m  = 10 * local.interval_seconds_30s
  interval_ms          = 1000
  max_data_points      = 43200

  # Common rule group settings
  rule_group_common = {
    disable_provenance = true
    interval_seconds   = local.interval_seconds_30s
  }

  # Common rule settings
  rule_common = {
    condition_ref_id          = "C"
    no_data_state             = "KeepLast"
    exec_err_state            = "KeepLast"
    expression_datasource_uid = "__expr__"
  }

  threshold_expr_data = {
    condition_data = {
      operator = {
        type = "and"
      },
      query = {
        params = ["C"]
      },
      reducer = {
        params = [],
        type   = "last"
      },
      type = "query"
    }
    expression    = "B"
    intervalMs    = local.interval_ms
    maxDataPoints = local.max_data_points
    refId         = "C"
    type          = "threshold"
  }


  reduce_expr_data = {
    ref_id         = "B"
    datasource_uid = "__expr__"
    model = jsonencode({
      datasource = {
        type = "__expr__",
        uid  = "__expr__"
      }
      conditions = [
        {
          evaluator = {
            params = [],
            type   = "gt"
          },
          operator = {
            type = "and"
          },
          query = {
            params = ["B"]
          },
          reducer = {
            params = [],
            type   = "last"
          },
          type = "query"
        }
      ]
      expression = "A"
      refId      = "B"
      reducer    = "last"
      type       = "reduce"
      settings = {
        mode = "dropNN"
      }
    })
  }
}
#############
# CNPG Alerts
#############
resource "grafana_rule_group" "cnpg_rules" {
  provider           = grafana.selfhosted
  for_each           = local.cnpg_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-cnpg-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = lookup(rule.value, "legendFormat", "__auto")
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = lookup(rule.value, "no_data_state", local.rule_common.no_data_state)
      exec_err_state = lookup(rule.value, "exec_err_state", local.rule_common.exec_err_state)
      for            = rule.value.for
    }
  }
}

################
# Kafka Alerts
################
resource "grafana_rule_group" "kafka_rules" {
  provider = grafana.selfhosted

  for_each           = local.kafka_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-kafka-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = "__auto"
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = local.rule_common.no_data_state
      exec_err_state = local.rule_common.exec_err_state
      for            = rule.value.for
    }
  }
}

resource "grafana_rule_group" "clickhouse_rules" {
  provider = grafana.selfhosted

  for_each           = local.clickhouse_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-clickhouse-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s

  dynamic "rule" {
    for_each = each.value
    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = grafana_data_source.datasource_clickhouse_samvaad.uid
        model = jsonencode({
          datasource = {
            type = "grafana-clickhouse-datasource"
            uid  = grafana_data_source.datasource_clickhouse_samvaad.uid
          },
          editorMode    = "code",
          format        = 1, # Integer, not string
          rawSql        = rule.value.expression,
          intervalMs    = local.interval_ms,
          maxDataPoints = local.max_data_points,
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression,
          intervalMs    = local.threshold_expr_data.intervalMs,
          maxDataPoints = local.threshold_expr_data.maxDataPoints,
          refId         = local.threshold_expr_data.refId,
          type          = local.threshold_expr_data.type
        })
      }

      no_data_state  = lookup(rule.value, "no_data_state", local.rule_common.no_data_state)
      exec_err_state = lookup(rule.value, "exec_err_state", local.rule_common.exec_err_state)
      is_paused      = rule.value.is_paused
      for            = rule.value.for
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
        }
      )
      labels = {
        team = each.key
      }
    }
  }
}


resource "grafana_rule_group" "kong_rules" {
  provider = grafana.selfhosted

  for_each           = local.kong_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-kong-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = "__auto"
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = lookup(rule.value, "no_data_state", local.rule_common.no_data_state)
      exec_err_state = lookup(rule.value, "exec_err_state", local.rule_common.exec_err_state)
      for            = rule.value.for
    }
  }
}

resource "grafana_rule_group" "redis_rules" {
  provider           = grafana.selfhosted
  for_each           = local.redis_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-redis-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = "__auto"
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = lookup(rule.value, "no_data_state", local.rule_common.no_data_state)
      exec_err_state = lookup(rule.value, "exec_err_state", local.rule_common.exec_err_state)
      for            = rule.value.for
    }
  }
}

resource "grafana_rule_group" "k8s_rules" {
  provider           = grafana.selfhosted
  for_each           = local.k8s_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-k8s-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = "__auto"
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = "OK"
      exec_err_state = local.rule_common.exec_err_state
      for            = rule.value.for
    }
  }
}


resource "grafana_rule_group" "x509_certificate_rules" {
  provider           = grafana.selfhosted
  for_each           = local.certificate_alerts_by_folder
  disable_provenance = true
  name               = "${local.env_prefix}-${each.key}-certificate-rules"
  folder_uid         = grafana_folder.sh_alert_folders[each.key].uid
  interval_seconds   = local.interval_seconds_30s
  dynamic "rule" {
    for_each = each.value

    content {
      name      = rule.value.name
      condition = local.rule_common.condition_ref_id

      data {
        ref_id = "A"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "P5DCFC7561CCDE821"
        model = jsonencode({
          datasource = {
            type = "prometheus"
            uid  = "P5DCFC7561CCDE821"
          }
          editorMode    = "code"
          expr          = rule.value.expression
          intervalMs    = local.interval_ms
          range         = false
          instant       = true
          legendFormat  = "__auto"
          maxDataPoints = local.max_data_points
          refId         = "A"
        })
      }

      data {
        ref_id = local.reduce_expr_data.ref_id
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = local.reduce_expr_data.datasource_uid
        model          = local.reduce_expr_data.model
      }

      data {
        ref_id = "C"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.rule_common.expression_datasource_uid
        model = jsonencode({
          conditions = [
            merge(local.threshold_expr_data.condition_data, {
              evaluator = {
                params = [rule.value.threshold],
                type   = rule.value.condition
              },
            })
          ],
          datasource = {
            type = local.rule_common.expression_datasource_uid,
            uid  = local.rule_common.expression_datasource_uid
          },
          expression    = local.threshold_expr_data.expression
          intervalMs    = local.threshold_expr_data.intervalMs
          maxDataPoints = local.threshold_expr_data.maxDataPoints
          refId         = local.threshold_expr_data.refId
          type          = local.threshold_expr_data.type
        })
      }
      is_paused = rule.value.is_paused
      annotations = merge(
        lookup(rule.value, "annotations", {}),
        {
          environment = local.env_prefix
          severity    = lookup(rule.value, "severity", "warning")
          doc         = lookup(rule.value, "doc", "")
        }
      )
      labels = {
        team     = each.key
        severity = lookup(rule.value, "severity", "warning")
      }
      no_data_state  = "OK"
      exec_err_state = local.rule_common.exec_err_state
      for            = rule.value.for
    }
  }
}
