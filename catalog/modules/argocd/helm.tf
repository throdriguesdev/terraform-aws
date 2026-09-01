resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        domain = var.ingress_host
      }

      configs = {
        params = {
          # ArgoCD serves HTTP internally — ALB terminates TLS
          "server.insecure" = true
        }
      }

      server = {
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"     = "ip"
            "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443},{\"HTTP\":80}]"
            "alb.ingress.kubernetes.io/ssl-redirect"      = "443"
            "alb.ingress.kubernetes.io/certificate-arn"  = var.acm_certificate_arn
            "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
            "external-dns.alpha.kubernetes.io/hostname"   = var.ingress_host
          }
          tls = true
        }
      }
    })
  ]
}
