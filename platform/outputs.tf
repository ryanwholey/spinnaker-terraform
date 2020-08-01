# resource "null_resource" "spinnaker_health" {
#   provisioner "local-exec" {
#     command = "until [[ \"UP\" == $(curl -fsSL https://spinnaker-gateway.ryanwholey.com/health | jq -r '.status') ]] ; do echo \"not ready\" && sleep 5 ; done"
#   }
#   depends_on = [kubernetes_ingress.spinnaker]
# }

# output "spinnaker_dns" {
#   value = "https://${kubernetes_ingress.spinnaker.spec[0].rule[0].host}"
#   depends_on = [null_resource.spinnaker_health]
# }

# output "spinnaker_gateway_dns" {
#   value = "https://${kubernetes_ingress.spinnaker_gateway.spec[0].rule[0].host}"
#   depends_on = [null_resource.spinnaker_health]
# }
