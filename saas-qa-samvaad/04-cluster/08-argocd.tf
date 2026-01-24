resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.3.0"
  namespace        = "argocd"
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    file("./values/argo-values.yaml")
  ]

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_secret" "argocd_svc_token_secret" {
  metadata {
    name      = "argocd-svc-token"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/service-account.name" = "argocd"
    }
  }
  type = "kubernetes.io/service-account-token"
}
