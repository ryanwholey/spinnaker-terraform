resource "kubernetes_namespace" "spinnaker_operator" {
  metadata {
    name = "spinnaker-operator"
  }
}
resource "helm_release" "spinnaker_operator" {
  name       = "spinnaker-operator"
  namespace  = kubernetes_namespace.spinnaker_operator.metadata[0].name
  repository = "https://armory.jfrog.io/artifactory/charts/" 
  chart      = "armory-spinnaker-operator"

  values = [
    jsonencode({

    })
  ]
}

resource "aws_s3_bucket" "spinnaker_storage" {
  bucket = "wholey-spinnaker-storage"
}

resource "kubectl_manifest" "spinnaker" {
  yaml_body = yamlencode({
    apiVersion = "spinnaker.armory.io/v1alpha2"
    kind = "SpinnakerService"
    metadata = {
      name = "spinnaker"
    }
    spec = {
      spinnakerConfig = {
        config = {
          version = "2.17.1"
          persistentStorage = {
            persistentStoreType = "s3"
            s3 = {
              bucket = aws_s3_bucket.spinnaker_storage.bucket
              rootFolder = "front50" # Change me
            }
          }
        }
        profiles = {
          clouddriver = {}
          deck = {
            "settings-local.js" = <<-EOF
              window.spinnakerSettings.feature.kustomizeEnabled = true;
            EOF
          }
          echo = {}    # Contents of ~/.hal/default/profiles/echo.yml
          fiat = {}    # Contents of ~/.hal/default/profiles/fiat.yml
          front50 = {} # Contents of ~/.hal/default/profiles/front50.yml
          gate = {}    # Contents of ~/.hal/default/profiles/gate.yml
          igor = {}    # Contents of ~/.hal/default/profiles/igor.yml
          kayenta = {} # Contents of ~/.hal/default/profiles/kayenta.yml
          orca = {}    # Contents of ~/.hal/default/profiles/orca.yml
          rosco = {}   # Contents of ~/.hal/default/profiles/rosco.yml
        }
        "service-settings" = {
          clouddriver = {}
          deck = {}
          echo = {}
          fiat = {}
          front50 = {}
          gate = {}
          igor = {}
          kayenta = {}
          orca = {}
          rosco = {}
        }
        files = {}
      }
      expose = {
        type = "service"
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = aws_acm_certificate_validation.eks.certificate_arn
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "80,443"
            "external-dns.alpha.kubernetes.io/hostname"                     = "spinnaker.${var.hosted_zone}."
          }
          overrides = {}
        }
      }
      validation = {}
    }
  })
}
