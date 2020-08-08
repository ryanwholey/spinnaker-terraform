resource "kubernetes_service_account" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

resource "kubernetes_cluster_role_binding" "spinnaker" {
  metadata {
    name = "spinnaker"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.spinnaker.metadata[0].name
    namespace = kubernetes_service_account.spinnaker.metadata[0].namespace
  }
}

data "kubernetes_secret" "spinnaker" {
  metadata {
    name      = kubernetes_service_account.spinnaker.default_secret_name
    namespace = kubernetes_service_account.spinnaker.metadata[0].namespace
  }
}

resource "kubernetes_secret" "spinnaker_kubeconfig" {
  metadata {
    name = "spinnaker-kubeconfig"
  }

  data = {
    config = yamlencode({
      apiVersion = "v1"
      kind       = "Config"
      clusters = [
        {
          name = data.terraform_remote_state.kubernetes.outputs.cluster_id
          cluster = {
            "certificate-authority-data" = base64encode(data.kubernetes_secret.spinnaker.data["ca.crt"])
            server                       = data.terraform_remote_state.kubernetes.outputs.endpoint
          }
        }
      ]
      contexts = [
        {
          name = "ryans-context"
          context = {
            cluster   = data.terraform_remote_state.kubernetes.outputs.cluster_id
            namespace = "default"
            user      = kubernetes_service_account.spinnaker.metadata[0].name
          }
        }
      ]
      "current-context" = "ryans-context"
      users = [
        {
          name = kubernetes_service_account.spinnaker.metadata[0].name
          user = {
            token = data.kubernetes_secret.spinnaker.data.token
          }
        }
      ]
    })
  }
}

resource "helm_release" "spinnaker" {
  name       = "spinnaker"
  repository = "https://kubernetes-charts.storage.googleapis.com" 
  chart      = "spinnaker"
  version    = "2.0.0-rc9"

  values = [
    jsonencode({
      kubeConfig = {
        enabled           = true
        secretName        = kubernetes_secret.spinnaker_kubeconfig.metadata[0].name
        secretKey         = "config"
        deploymentContext = "ryans-context"
        contexts = [
          "ryans-context"
        ]
      }
      dockerRegistries = [
        {
          name    = "dockerhub"
          address = "index.docker.io"
          repositories = [
            "library/alpine",
            "library/ubuntu",
            "library/centos",
            "library/nginx",
            "ryanwholey/test-app"
          ]
        }
      ]
    })
  ]

  depends_on = [kubernetes_cluster_role_binding.spinnaker]
}

data "kubernetes_service" "spin_deck" {
  metadata {
    name      = "spin-deck"
    namespace = helm_release.spinnaker.metadata[0].namespace
  }
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
    name      = "spin-gate"
    namespace = helm_release.spinnaker.metadata[0].namespace
  }
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
