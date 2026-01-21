
resource "kubernetes_secret_v1" "argocd_github_app_auth" {
  metadata {
    name      = "github-app-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    type                    = "git"
    url                     = ""
    githubAppPrivateKey     = ""
    githubAppID             = ""
    githubAppInstallationID = ""
  }
}

# example

resource "kubernetes_secret_v1" "sarvam_stt_repo" {
  metadata {
    name      = "stt-service"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url  = ""
  }
}

# Cluster authentication
resource "kubernetes_secret_v1" "agrimini_production" {
  metadata {
    name      = "agrimini-production-cluster-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      "env"                            = "agrmini-production"
    }
  }

  type = "Opaque"

  data = {
    "name"   = "agrmini-production"
    "server" = "https://kubernetes.default.svc"

    "config" = jsonencode({
      tlsClientConfig = {
        insecure = false
        caData   = local.cluster_ca_certificate # get it from outputs
      }
      bearerToken = data.kubernetes_secret.argocd_svc_token_data.data.token
    })
  }
}
