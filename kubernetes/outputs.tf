output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "ca_cert" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}
