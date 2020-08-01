data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.kubernetes.outputs.cluster_id
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.kubernetes.outputs.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.kubernetes.outputs.ca_cert)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.kubernetes.outputs.endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.kubernetes.outputs.ca_cert)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
