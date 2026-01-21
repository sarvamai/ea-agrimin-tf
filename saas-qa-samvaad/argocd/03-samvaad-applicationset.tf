locals {
  saas_qa_samvaad_gcp_dir_path = "gcp/samvaad/saas-qa-samvaad"
}

resource "kubectl_manifest" "saas_qa_gcp_samvaad_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name       = "saas-qa-samvaad-gcp"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      description = "Saas Qa Samvaad GCP"
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


resource "kubectl_manifest" "saas_qa_samvaad_gcp_applciationset" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "saas-qa-samvaad-gcp"
      namespace = "argocd"
    }
    spec = {
      goTemplate        = true
      goTemplateOptions = ["missingkey=error"]
      generators = [
        {
          matrix = {
            generators = [
              {
                git = {
                  repoURL  = "https://github.com/sarvamai/sarvam-helm-charts.git"
                  revision = "saas-qa-samvaad"
                  files = [
                    {
                      path = "${local.saas_qa_samvaad_gcp_dir_path}/services.yaml"
                    }
                  ]
                }
              },
              {
                clusters = {
                  selector = {
                    matchLabels = {
                      env = "saas-qa-samvaad"
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
          name      = "{{.name}}-saas-qa-gcp"
          namespace = "argocd"
        }
        spec = {
          project = "saas-qa-samvaad-gcp"
          destination = {
            server    = "{{.server}}"
            namespace = "apps-runtime"
          }
          sources = [
             {
              repoURL        = "https://github.com/sarvamai/sarvam-helm-charts.git"
              targetRevision = "saas-qa-samvaad"
              path           = "${local.saas_qa_samvaad_gcp_dir_path}/{{.name}}"
              helm = {
                releaseName = "{{.name}}"
              }
            }
          ]
          syncPolicy = {
            syncOptions = [
              "CreateNamespace=true"
            ]
          }
        }
      }
    }
  })

  depends_on = [kubectl_manifest.saas_qa_gcp_samvaad_project]
}
