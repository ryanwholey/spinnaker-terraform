resource "spinnaker_application" "test_app" {
  application = "test-app"
  email       = "rjwholey@gmail.com"
}

resource "spinnaker_pipeline" "test_app" {
  application = spinnaker_application.test_app.application
  name        = "Test App"
  pipeline = <<-EOF
{
    "appConfig": {},
    "expectedArtifacts": [],
    "lastModifiedBy": "anonymous",
    "stages": [
      {
        "account": "ryans-context",
        "cloudProvider": "kubernetes",
        "manifests": [
          {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
              "labels": {
                "app.kubernetes.io/name": "manual-test-app"
              },
              "name": "manual-test-app"
            },
            "spec": {
              "replicas": 3,
              "selector": {
                "matchLabels": {
                  "app.kubernetes.io/name": "manual-test-app",
                  "component": "server"
                }
              },
              "template": {
                "metadata": {
                  "labels": {
                    "app.kubernetes.io/name": "manual-test-app",
                    "component": "server"
                  }
                },
                "spec": {
                  "containers": [
                    {
                      "image": "ryanwholey/test-app:2786764ffe67f4bd4e980465982ae7b44dd7f935",
                      "imagePullPolicy": "IfNotPresent",
                      "name": "manual-test-app",
                      "ports": [
                        {
                          "containerPort": 3000
                        }
                      ]
                    }
                  ]
                }
              }
            }
          }
        ],
        "moniker": {
          "app": "test-app"
        },
        "name": "Deploy (Manifest)",
        "refId": "1",
        "requisiteStageRefIds": [],
        "skipExpressionEvaluation": false,
        "source": "text",
        "trafficManagement": {
          "enabled": false,
          "options": {
            "enableTraffic": false,
            "services": []
          }
        },
        "type": "deployManifest"
      }
    ],
    "triggers": [
      {
        "account": "dockerhub",
        "description": "(Docker Registry) dockerhub: ryanwholey/test-app",
        "enabled": true,
        "organization": "ryanwholey",
        "registry": "index.docker.io",
        "repository": "ryanwholey/test-app",
        "tag": "",
        "type": "docker"
      }
    ],
    "updateTs": "1596841456000"
  }
EOF
}

#   pipeline    = jsonencode({
#     expectedArtifacts = []
#     stages            = []
#     triggers          = [
#       {
#         account      = "dockerhub"
#         enabled      = true
#         organization = "library"
#         registry     = "index.docker.io"
#         repository   = "ryanwholey/test-app"
#         tag          = "latest"
#         type         = "docker"
#       }
#     ]
#   })