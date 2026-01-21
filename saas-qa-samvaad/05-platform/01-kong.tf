# Self-signed ClusterIssuer
resource "kubernetes_manifest" "selfsigned_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  }
}

# Self-signed CA Certificate
resource "kubernetes_manifest" "kong_selfsigned_ca" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "kong-selfsigned-ca"
      namespace = "kong"
    }
    spec = {
      isCA       = true
      commonName = "kong-selfsigned-ca"
      secretName = "root-secret"
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }

      duration    = "87600h"
      renewBefore = "8760h"

      issuerRef = {
        name  = "selfsigned-issuer"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.selfsigned_cluster_issuer
  ]
}

# Namespace Issuer using CA
resource "kubernetes_manifest" "kong_ca_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "kong-ca-issuer"
      namespace = "kong"
    }
    spec = {
      ca = {
        secretName = "root-secret"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.kong_selfsigned_ca
  ]
}

resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email"  = "harish@sarvam.ai"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-key"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "kong"
              }
            }
          }
        ]
      }
    }
  }
}

#####################
# Postgres Secret
#####################
resource "random_password" "kong_db_password" {
  length           = 24
  special          = true                   # TODO: change to false
  override_special = "!#$%&*()-_=+[]{}<>:?" # Avoid characters that break shell commands or SQL
}

resource "kubernetes_secret" "postgres_kong_secret" {
  metadata {
    name      = "kong-db-creds"
    namespace = "postgres"
    annotations = {
      "replicator.v1.mittwald.de/replicate-to" = "kong"
    }
  }

  data = {
    username = "kong"
    password = random_password.kong_db_password.result
  }
}

resource "kubernetes_secret" "kong_app_secret" {
  metadata {
    name      = "kong-db-user"
    namespace = "kong"
  }
  type = "Opaque"
  data = {
    username = "kong"
    password = random_password.kong_db_password.result
  }
}