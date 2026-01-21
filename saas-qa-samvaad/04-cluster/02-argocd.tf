resource "kubernetes_service_account_v1" "argocd" {
  metadata {
    name      = "argocd"
    namespace = "argocd"
  }
}

resource "kubernetes_cluster_role_binding_v1" "argocd_binding" {
  metadata {
    name = "argocd-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd.metadata[0].name
    namespace = kubernetes_service_account_v1.argocd.metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "argocd_token_secret" {
  metadata {
    name      = "argocd-manager-token"
    namespace = kubernetes_service_account_v1.argocd.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

# data "kubernetes_secret_v1" "argocd_token_data" {
#   metadata {
#     name      = kubernetes_secret_v1.argocd_token_secret.metadata[0].name
#     namespace = kubernetes_secret_v1.argocd_token_secret.metadata[0].namespace
#   }
#   depends_on = [kubernetes_secret_v1.argocd_token_secret]
# }

# resource "google_secret_manager_secret" "cluster_ca" {
#   secret_id = "saas-qa-samvaad-ca-crt"
#   replication {
#     user_managed {
#       replicas {
#         location = "asia-south1"
#       }
#     }
#   }
# }

# resource "google_secret_manager_secret_version" "cluster_ca_version" {
#   secret      = google_secret_manager_secret.cluster_ca.id
#   secret_data = local.ca_certificate
# }

# resource "google_secret_manager_secret" "sa_token" {
#   secret_id = "saas-qa-samvaad-sa-token"
#   replication {
#     user_managed {
#       replicas {
#         location = "asia-south1"
#       }
#     }
#   }
# }

# resource "google_secret_manager_secret_version" "sa_token_version" {
#   secret      = google_secret_manager_secret.sa_token.id
#   secret_data = data.kubernetes_secret_v1.argocd_token_data.data.token
# }