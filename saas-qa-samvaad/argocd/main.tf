resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.3.0"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  
  wait             = true
  timeout          = 600

  values = [
    file("./values/argo-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.ingress_nginx,
    kubectl_manifest.issuer_prod
  ]
}


resource "kubernetes_manifest" "argocd_ingress" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "argo-ingress"
      "namespace" = "argocd"
      "annotations" = {
        "kubernetes.io/ingress.class"    = "kong"
        "konghq.com/preserve-host"    = "true"
      }
    }
    "spec" = {
      "ingressClassName" = "kong"
      "rules" = [
        {
          "host" = "<domain>"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Prefix"
                "backend" = {
                  "service" = {
                    "name" = "argocd-server"
                    "port" = { "number" = 80 }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}
