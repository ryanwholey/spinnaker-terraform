resource "helm_release" "mydatabase" {
  name  = "spinnaker"
  chart = "stable/spinnaker"
}
