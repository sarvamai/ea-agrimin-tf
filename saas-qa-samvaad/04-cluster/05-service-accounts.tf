resource "kubernetes_service_account_v1" "this" {
  for_each = local.service_accounts
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.sa_email
    }
  }
  depends_on = [ kubernetes_namespace_v1.this ]
}