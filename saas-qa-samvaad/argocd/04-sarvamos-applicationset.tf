locals {
  environment_name = "saas-qa-samvaad"
}

resource "kubectl_manifest" "saas_qa_samvaad_sarvam_os_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name       = "saas-qa-samvaad-sarvam-os"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      description = "Sarvam OS releases for Saas QA Samvaad GCP"
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

resource "kubectl_manifest" "saas_qa_samvaad_sarvam_os_application_set" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "saas-qa-samvaad-sarvam-os"
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
                  repoURL  = "https://github.com/sarvamai/sarvam-gcp-common-gitops"
                  revision = "saas-qa-samvaad"
                  files = [
                    {
                      path = "${local.environment_name}/sarvam-os/release/release.yaml"
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
          name      = "{{.app_name}}-saas-qa-samvaad-gcp"
          namespace = "{{.namespace}}"
          annotations = {
            "argocd.argoproj.io/sync-wave" = "{{.sync_wave}}"
          }
        }
        spec = {
          project = "saas-qa-samvaad-sarvam-os"
          destination = {
            server    = "{{.server}}"
            namespace = "{{.namespace}}"
          }
          sources = [
            {
              repoURL        = "gitopsdocker.azurecr.io"
              chart          = "helm/{{.chart}}"
              targetRevision = "{{.version}}"
              ref            = "{{.app_name}}"
              helm = {
                valueFiles = [
                  "$values-git/${local.environment_name}/{{.values_path}}/sarvam-os/{{.app_name}}/values.yaml"
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
              "ServerSideApply=true" # ?????
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

  depends_on = [kubectl_manifest.saas_qa_samvaad_sarvam_os_project]
}
