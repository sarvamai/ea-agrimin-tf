# data "kubernetes_secret" "openbao_ca_secret" {
#   metadata {
#     name      = "openbao-server-tls"
#     namespace = "openbao"
#   }
# }

# resource "kubernetes_secret" "openbao_ca_secret" {
#   metadata {
#     name      = "openbao-server-tls"
#     namespace = "external-secrets"
#   }

#   data = {
#     "openbao.ca" = data.kubernetes_secret.openbao_ca_secret.data["openbao.ca"]
#   }

#   type = "Opaque"

# }

# resource "kubernetes_manifest" "cluster_secret_store" {
#   manifest = {
#     apiVersion = "external-secrets.io/v1"
#     kind       = "ClusterSecretStore"
#     metadata = {
#       name = "open-bao-store"
#       labels = {
#         app = "openbao"
#       }
#     }
#     spec = {
#       provider = {
#         vault = {
#           server    = "https://openbao-internal.openbao.svc.cluster.local:8200"
#           path      = "kv"
#           version   = "v2"
#           namespace = "saas-qa-samvaad"
#           caProvider = {
#             type      = "Secret"
#             name      = "openbao-server-tls"
#             key       = "openbao.ca"
#             namespace = "external-secrets"
#           }
#           auth = {
#             kubernetes = {
#               mountPath = "kubernetes"
#               role      = "eso-role"
#               serviceAccountRef = {
#                 name      = "eso-service-account"
#                 namespace = "external-secrets"
#               }
#             }
#           }
#         }
#       }
#     }
#   }
#   depends_on = [
#     kubernetes_secret.openbao_ca_secret,
#   ]
# }


###########################
# GCP Cluster secret store
###########################
resource "kubernetes_manifest" "gcp_cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "gcp-secret-manager"
      labels = {
        app = "gcp-secret-manager"
      }
    }
    spec = {
      provider = {
        gcpsm = {
          projectID = local.project_id
          auth = {
            workloadIdentity = {
              clusterLocation = local.region
              clusterName = local.cluster_name
              serviceAccountRef = {
                name = "eso-service"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }
}


