resource "kubernetes_manifest" "grafana_ingress" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "grafana-ingress"
      "namespace" = "monitoring"
      "annotations" = {
        "kubernetes.io/ingress.class"    = "kong"
        "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      }
    }
    "spec" = {
      "ingressClassName" = "kong"
      "tls" = [
        {
          "hosts"      = [local.grafana_url]
          "secretName" = "grafana-tls"
        }
      ]
      "rules" = [
        {
          "host" = local.grafana_url
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Prefix"
                "backend" = {
                  "service" = {
                    "name" = "kube-prometheus-stack-grafana"
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