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
    "expectedArtifacts": [
      {
        "defaultArtifact": {
          "artifactAccount": "wholey-helm-charts",
          "id": "2c884bec-4dc6-4e3c-b34f-6c1787da0ee6",
          "reference": "s3://wholey-helm-charts/test-app-helm-0.0.2.tgz",
          "type": "s3/object"
        },
        "displayName": "test-app-helm",
        "id": "e035a0fc-0ad3-420f-b8da-e73e81c22309",
        "matchArtifact": {
          "artifactAccount": "wholey-helm-charts",
          "id": "a44f4f31-3b4c-47d1-8c9d-3648b9623ae2",
          "name": "s3://wholey-helm-charts/test-app-helm-0.0.2.tgz",
          "type": "s3/object"
        },
        "useDefaultArtifact": true,
        "usePriorArtifact": false
      }
    ],
    "lastModifiedBy": "anonymous",
    "stages": [
      {
        "account": "ryans-context",
        "cloudProvider": "kubernetes",
        "manifestArtifactAccount": "embedded-artifact",
        "manifestArtifactId": "3547af64-d836-4340-bb32-f57112536e67",
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
        "requiredArtifactIds": [],
        "requiredArtifacts": [],
        "requisiteStageRefIds": [
          "2"
        ],
        "skipExpressionEvaluation": false,
        "source": "artifact",
        "trafficManagement": {
          "enabled": false,
          "options": {
            "enableTraffic": false,
            "services": []
          }
        },
        "type": "deployManifest"
      },
      {
        "expectedArtifacts": [
          {
            "defaultArtifact": {
              "customKind": true,
              "id": "2cde68c9-5164-4611-8173-4799fdb6438e"
            },
            "displayName": "test-app-manifest",
            "id": "3547af64-d836-4340-bb32-f57112536e67",
            "matchArtifact": {
              "id": "834251fd-e337-4f7a-b14a-5e13259f6e0b",
              "name": "test-app-manifest",
              "type": "embedded/base64"
            },
            "useDefaultArtifact": false,
            "usePriorArtifact": false
          }
        ],
        "inputArtifacts": [
          {
            "account": "wholey-helm-charts",
            "id": "e035a0fc-0ad3-420f-b8da-e73e81c22309"
          }
        ],
        "name": "Bake (Manifest)",
        "namespace": "default",
        "outputName": "test-app",
        "overrides": {
          "image.tag": "$${trigger['tag']}"
        },
        "refId": "2",
        "requisiteStageRefIds": [],
        "templateRenderer": "HELM3",
        "type": "bakeManifest"
      }
    ],
    "triggers": [
      {
        "account": "dockerhub",
        "enabled": true,
        "organization": "ryanwholey",
        "registry": "index.docker.io",
        "repository": "ryanwholey/test-app",
        "type": "docker"
      }
    ],
    "updateTs": "1597121227000"
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