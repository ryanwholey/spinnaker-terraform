data "terraform_remote_state" "platform" {
  backend = "local"

  config = {
    path = "${path.module}/../platform/terraform.tfstate"
  }
}
