####################################
# private github repo auth template
###################################
data "google_secret_manager_secret_version" "github_app_id" {
  secret  = "argo-github-app-id"
  project = local.project_id
}

# Fetching the Installation ID
data "google_secret_manager_secret_version" "github_installation_id" {
  secret  = "argo-github-app-installation-id"
  project = local.project_id
}

# Fetching the Private Key
data "google_secret_manager_secret_version" "github_private_key" {
  secret  = "argo-github-app-privatekey"
  project = local.project_id
}

# Github auth
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
    url                     = "https://github.com/sarvamai"
    githubAppPrivateKey     = data.google_secret_manager_secret_version.github_private_key.secret_data
    githubAppID             = data.google_secret_manager_secret_version.github_app_id.secret_data
    githubAppInstallationID = data.google_secret_manager_secret_version.github_installation_id.secret_data
  }
}

resource "kubernetes_secret_v1" "agrimin_helm_charts_repo" {
  metadata {
    name      = "agrimin-helm-charts"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url  = "https://github.com/sarvamai/agrimin-helm-charts.git"
  }
}

# Oci auth
resource "kubernetes_secret_v1" "argocd_gar_repo" {
  metadata {
    name      = "gar-helm-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name      = "sarvam-gar"
    type      = "helm"
    enableOCI = "true"
    url       = "asia-south1-docker.pkg.dev/${local.project_id}/samvaad-charts"
    username  = "_json_key"
    password  = base64decode(local.gar_connect_sa_private_key)
  }
}


# CLuster Auth
data "kubernetes_secret_v1" "argocd_svc_token_data" {
  metadata {
    name      = "argocd-svc-token"
    namespace = "argocd"
  }
}

resource "kubernetes_secret_v1" "agrimin_prod_cluster_auth" {
  metadata {
    name      = "saas-qa-samvaad-cluster-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      "env"                            = "agrimin-prod"
    }
  }

  type = "Opaque"

  data = {
    "name"   = "agrimin-prod"
    "server" = "https://kubernetes.default.svc"

    "config" = jsonencode({
      tlsClientConfig = {
        insecure = false
        caData   = local.ca_certificate
      }
      bearerToken = data.kubernetes_secret_v1.argocd_svc_token_data.data.token
    })
  }
}

###############
# projects
###############

resource "kubectl_manifest" "agrimin_prod_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "agri-ministry-prod-fabric"
      namespace = "argocd"
      #If this is present, deleting the project deletes the database/kafka.
      #finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      description = "Agrimini Prod GCP"
      sourceRepos = ["*"]
      destinations = [
        {
          namespace = "*"
          server    = "*"
        }
      ]
    }
  })
}

resource "kubectl_manifest" "agrimin_prod_sarvam_os_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "agri-ministry-prod-sarvam-os"
      namespace = "argocd"
      #finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      description = "Sarvam OS releases for Agrimini Prod"
      sourceRepos = ["*"]
      destinations = [
        {
          namespace = "*"
          server    = "*"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "apiextensions.k8s.io"
          kind  = "CustomResourceDefinition"
        },
        {
          group = "rbac.authorization.k8s.io"
          kind  = "ClusterRole"
        },
        {
          group = "rbac.authorization.k8s.io"
          kind  = "ClusterRoleBinding"
        },
        {
          group = "storage.k8s.io"
          kind  = "StorageClass"
        },
        {
          group = "storage.k8s.io"
          kind  = "CSIDriver"
        },
        {
          group = "scheduling.k8s.io"
          kind  = "PriorityClass"
        },
        {
          group = "admissionregistration.k8s.io"
          kind  = "MutatingWebhookConfiguration"
        },
        {
          group = "admissionregistration.k8s.io"
          kind  = "ValidatingWebhookConfiguration"
        },
        {
          group = "external-secrets.io"
          kind  = "ClusterSecretStore"
        },
        {
          group = "networking.k8s.io"
          kind  = "IngressClass"
        },
        {
          group = "cert-manager.io"
          kind  = "ClusterIssuer"
        },
      ]
    }
  })
}

locals {
  agrimini_dir_path = "gcp/samvaad/agri-ministry-prod-fabric"
}

# Fabric Applicationset
resource "kubectl_manifest" "samvaad_platform" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "samvaad-platform"
      namespace = "argocd"
    }
    spec = {
      syncPolicy = {
        preserveResourcesOnDeletion = true
      }
      goTemplate        = true
      goTemplateOptions = ["missingkey=error"]
      generators = [
        {
          matrix = {
            generators = [
              {
                git = {
                  repoURL  = "https://github.com/sarvamai/agrimin-helm-charts"
                  revision = "main"
                  files = [
                    {
                      path = "${local.agrimini_dir_path}/services.yaml"
                    }
                  ]
                }
              },
              {
                clusters = {
                  selector = {
                    matchLabels = {
                      env = "agrimin-prod"
                    }
                  }
                }
              }
            ]
          }
        }
      ]
      template = {
        metadata = {
          name      = "{{.name}}-agrimin"
          namespace = "apps-runtime"
        }
        spec = {
          project = "agri-ministry-prod-fabric"
          destination = {
            server    = "{{.server}}"
            namespace = "apps-runtime"
          }
          sources = [
            {
              repoURL        = "https://github.com/sarvamai/agrimin-helm-charts"
              targetRevision = "main"
              path           = "gcp/samvaad/agri-ministry-prod-fabric/{{.name}}"
              helm = {
                releaseName = "{{.name}}"
              }
            }
          ]
          syncPolicy = {
            syncOptions = [
              "CreateNamespace=true",
              "Prune=false"
            ]
            
          }
        }
      }
    }
  })

  depends_on = [kubectl_manifest.agrimin_prod_project]
}

resource "kubectl_manifest" "agri_ministry_prod_sarvam_os_application_set" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "agri-ministry-prod-sarvam-os"
      namespace = "argocd"
    }
    spec = {
      syncPolicy = {
        preserveResourcesOnDeletion = true
      }
      goTemplate        = true
      goTemplateOptions = ["missingkey=error"]
      generators = [
        {
          matrix = {
            generators = [
              {
                git = {
                  repoURL  = "https://github.com/sarvamai/agrimin-helm-charts"
                  revision = "main"
                  files = [
                    {
                      path = "gcp/samvaad/agri-ministry-prod-sarvam-os/release.yaml"
                    }
                  ]
                }
              },
              {
                clusters = {
                  selector = {
                    matchLabels = {
                      env = "agrimin-prod"
                    }
                  }
                }
              }
            ]
          }
        }
      ]
      template = {
        metadata = {
          name      = "{{.app_name}}-sarvam-os"
          namespace = "{{.namespace}}"
          annotations = {
            "argocd.argoproj.io/sync-wave" = "{{.sync_wave}}"
          }
        }
        spec = {
          project = "agri-ministry-prod-sarvam-os"
          destination = {
            server    = "{{.server}}"
            namespace = "{{.namespace}}"
          }
          sources = [
            {
              repoURL        = "asia-south1-docker.pkg.dev/${local.project_id}/samvaad-charts"
              chart          = "{{.chart}}"
              targetRevision = "{{.version}}"
              ref            = "{{.app_name}}"
              helm = {
                valueFiles = [
                  "$values-git/gcp/samvaad/agri-ministry-prod-sarvam-os/{{.app_name}}/values.yaml"
                ]
                releaseName = "{{.app_name}}"
              }
            },
            {
              repoURL        = "{{.repo_url}}"
              targetRevision = "{{.target_branch}}"
              ref            = "values-git"
            }
          ]
          syncPolicy = {
            syncOptions = [
              "ServerSideApply=true",
              "Prune=false"
            ]
          }
          ignoreDifferences = [
            {
              group        = "admissionregistration.k8s.io"
              kind         = "MutatingWebhookConfiguration"
              jsonPointers = ["/webhooks/0/clientConfig/caBundle"]
            },
            {
              group        = "admissionregistration.k8s.io"
              kind         = "ValidatingWebhookConfiguration"
              jsonPointers = ["/webhooks/0/clientConfig/caBundle"]
            }
          ]
        }
      }
    }
  })

  depends_on = [kubectl_manifest.agrimin_prod_sarvam_os_project]
}
