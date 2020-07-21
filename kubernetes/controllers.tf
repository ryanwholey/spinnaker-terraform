data "aws_iam_policy_document" "cluster_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster}-cluster"

  assume_role_policy = data.aws_iam_policy_document.cluster_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = module.network.public_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]

  version = "1.17"
}

resource "local_file" "kubeconfig" {
    content  = templatefile("${path.module}/templates/kubeconfig", {
      cluster_arn = aws_eks_cluster.cluster.arn
      ca_data = aws_eks_cluster.cluster.certificate_authority[0].data
      endpoint = aws_eks_cluster.cluster.endpoint
      cluster_name = var.cluster
      aws_profile = var.aws_profile
      aws_region = var.aws_default_region
    })
    filename = "${path.module}/build/kubeconfig"
}
