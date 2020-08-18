data "terraform_remote_state" "kubernetes" {
  backend = "local"

  config = {
    path = "${path.module}/../kubernetes/terraform.tfstate"
  }
}
