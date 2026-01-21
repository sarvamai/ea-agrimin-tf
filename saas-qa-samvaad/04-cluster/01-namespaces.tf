locals {
  namespaces = [
    "apps-runtime",
    "apps-authoring",
    "data-analyst-runtime",
    "linkerd",
    "external-secrets",
    "argocd",
    "cert-manager",
    "signoz",
    "openbao",
    "keda",
    "milvus",
    "kong",
    "postgres",
    "openebs",
    "clickhouse-samvaad",
    "redis",
    "openbao",
    "monitoring",
    "platform",
    "kafka",
  ]
}

resource "kubernetes_namespace_v1" "this" {
  for_each = toset(local.namespaces)

  metadata {
    name = each.value
  }
}