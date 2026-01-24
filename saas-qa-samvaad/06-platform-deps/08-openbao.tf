# data "kubernetes_secret" "openbao_tls_secret" {
#   metadata {
#     name      = "openbao-server-tls"
#     namespace = "openbao"
#   }
# }

# resource "kubernetes_secret" "openbao_ca_internal_secret" {
#   metadata {
#     name      = "openbao-internal-ca"
#     namespace = "openbao"
#   }

#   data = {
#     "ca.crt" = data.kubernetes_secret.openbao_tls_secret.data["openbao.ca"]
#   }
# }

# resource "kubernetes_manifest" "openbao_ingress" {
#   manifest = {
#     "apiVersion" = "networking.k8s.io/v1"
#     "kind"       = "Ingress"
#     "metadata" = {
#       "name"      = "openbao-ingress"
#       "namespace" = "openbao"
#       "annotations" = {
#         "kubernetes.io/ingress.class"    = "kong"
#         "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
#       }
#     }
#     "spec" = {
#       "ingressClassName" = "kong"
#       "tls" = [
#         {
#           "hosts"      = ["vault.saas-qa-samvaad.sarvam.ai"]
#           "secretName" = "openbao-tls"
#         }
#       ]
#       "rules" = [
#         {
#           "host" = "vault.saas-qa-samvaad.sarvam.ai"
#           "http" = {
#             "paths" = [
#               {
#                 "path"     = "/"
#                 "pathType" = "Prefix"
#                 "backend" = {
#                   "service" = {
#                     "name" = "openbao-ui"
#                     "port" = { "number" = 8200 }
#                   }
#                 }
#               }
#             ]
#           }
#         }
#       ]
#     }
#   }
# }
