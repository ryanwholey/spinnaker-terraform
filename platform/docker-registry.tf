resource "helm_release" "docker_registry" {
  name       = "docker-registry"
  repository = "https://kubernetes-charts.storage.googleapis.com" 
  chart      = "docker-registry"
}
