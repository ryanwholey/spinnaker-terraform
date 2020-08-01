provider "spinnaker" {
  server = data.terraform_remote_state.platform.outputs.spinnaker_gateway_dns
}
