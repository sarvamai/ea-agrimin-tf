resource "kubernetes_cluster_role_binding" "openbao_auth_reviewer" {
  metadata {
    name = "openbao-auth-reviewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "openbao-sa"
    namespace = "openbao"
  }
}

resource "kubernetes_secret" "openbao_reviewer_token" {
  metadata {
    name      = "openbao-reviewer-token"
    namespace = "openbao"
    annotations = {
      "kubernetes.io/service-account.name" = "openbao-sa"
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [kubernetes_cluster_role_binding.openbao_auth_reviewer]
}