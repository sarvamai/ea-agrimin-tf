resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.19.2"

  set = [
    {
      name  = "installCRDs"
      value = true
    }
  ]
}
