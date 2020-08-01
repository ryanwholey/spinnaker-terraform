data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "./modules/network"

  cidr   = "10.0.0.0/16"
  azs    = [for name in data.aws_availability_zones.available.names: name]
  prefix = var.cluster
}


# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "spinnaker"
#     namespace = "default"
#   }

#   data {
#     mapRoles = <<EOF
# - rolearn: ${aws_iam_role.tf-eks-node.arn}
#   username: spinnaker
#   groups:
#     - system:masters
# EOF
#   }
#   depends_on = [ aws_eks_cluster.cluster  ]
# }

# locals {
#   kubeconfig = <<EOF
# apiVersion: v1
# clusters:
# - cluster:
#     server: ${aws_eks_cluster.cluster.endpoint}
#     certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority[0].data}
#   name: ${var.cluster}
# contexts:
# - context:
#     cluster: ${var.cluster}
#     user: spinnaker
#   name: ${var.cluster}
# current-context: ${var.cluster}
# kind: Config
# preferences: {}
# users:
# - name: spinnaker
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1alpha1
#       command: aws-iam-authenticator
#       args:
#         - "token"
#         - "-i"
#         - "example"
# EOF
# }