resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = module.network.public_subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.container_registry_policy,
  ]

  instance_types = ["t3.medium"]
}

data "aws_iam_policy_document" "assume_node_group" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_group" {
  name = "eks-node-group"

  assume_role_policy = data.aws_iam_policy_document.assume_node_group.json
}

resource "aws_iam_role_policy_attachment" "worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

data "aws_iam_policy_document" "external_dns_node_group" {
  statement {
    actions = [
      "route53:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_node_group" {
  name   = "external-dns-node-group"
  policy = data.aws_iam_policy_document.external_dns_node_group.json
}

resource "aws_iam_role_policy_attachment" "external_dns_node_group" {
  policy_arn = aws_iam_policy.external_dns_node_group.arn
  role       = aws_iam_role.node_group.name
}
