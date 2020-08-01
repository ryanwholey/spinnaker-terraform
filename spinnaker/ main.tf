resource "spinnaker_application" "test_app" {
  application = "test-app"
  email       = "rjwholey@gmail.com"
}

resource "spinnaker_pipeline" "test_pipeline" {
  application = spinnaker_application.test_app.application
  name        = "Test Pipeline"
  pipeline    = jsonencode({
    expectedArtifacts = []
    stages            = []
    triggers          = [
      {
        account      = "dockerhub"
        enabled      = true
        organization = "library"
        registry     = "index.docker.io"
        repository   = "library/nginx"
        tag          = "latest"
        type         = "docker"
      }
    ]
  })
}
