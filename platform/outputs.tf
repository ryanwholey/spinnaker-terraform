resource "null_resource" "spinnaker_health" {
  provisioner "local-exec" {
    command = "until [[ \"UP\" == $(curl -fsSL https://spinnaker-gateway.ryanwholey.com/health | jq -r '.status') ]] ; do echo \"not ready\" && sleep 5 ; done"
  }
  depends_on = [helm_release.spinnaker]
}

output "spinnaker_dns" {
  value = "https://spinnaker.${var.hosted_zone}"
  depends_on = [null_resource.spinnaker_health]
}

output "spinnaker_gateway_dns" {
  value = "https://spinnaker-gateway.${var.hosted_zone}"
  depends_on = [null_resource.spinnaker_health]
}
