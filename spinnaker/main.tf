resource "helm_release" "spinnaker" {
  name       = "spinnaker"
  repository = "https://kubernetes-charts.storage.googleapis.com" 
  chart      = "spinnaker"
  version    = "2.0.0-rc9"
}

resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://helm.nginx.com/stable" 
  chart      = "nginx-ingress"

  values = [
    jsonencode({
      controller = {
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = aws_acm_certificate_validation.eks.certificate_arn
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "https"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "https"
          }
        }
      }
    })
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami" 
  chart      = "external-dns"
}

data "kubernetes_service" "spin_deck" {
  metadata {
    name = "spin-deck"
  }
  depends_on = [helm_release.spinnaker]
}

resource "kubernetes_ingress" "spinnaker" {
  metadata {
    name = "spinnaker"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "spinnaker.${var.hosted_zone}"
      http {
        path {
          backend {
            service_name = data.kubernetes_service.spin_deck.metadata[0].name
            service_port = data.kubernetes_service.spin_deck.spec[0].port[0].port
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [
        "spinnaker.${var.hosted_zone}"
      ]
    }
  }
}

data "kubernetes_service" "spin_gate" {
  metadata {
    name = "spin-gate"
  }
  depends_on = [helm_release.spinnaker]
}

resource "kubernetes_ingress" "spinnaker_gateway" {
  metadata {
    name = "spinnaker-gateway"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "spinnaker-gateway.${var.hosted_zone}"
      http {
        path {
          backend {
            service_name = data.kubernetes_service.spin_gate.metadata[0].name
            service_port = data.kubernetes_service.spin_gate.spec[0].port[0].port
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [
        "spinnaker-gateway.${var.hosted_zone}"
      ]
    }
  }
}
