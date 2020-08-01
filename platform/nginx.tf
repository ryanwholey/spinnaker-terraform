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
