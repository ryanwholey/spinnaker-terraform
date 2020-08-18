resource "spinnaker_application" "test_app" {
  application = "test-app"
  email       = "rjwholey@gmail.com"
}

resource "spinnaker_pipeline" "test_app" {
  application = spinnaker_application.test_app.application
  name        = "Terraform Test App"
  pipeline = <<-EOF
    {
      "expectedArtifacts": [
        {
          "defaultArtifact": {
            "artifactAccount": "${var.s3_helm_chart_bucket}",
            "id": "186ff6dd-76f0-4b44-a164-83bf6933e717",
            "reference": "s3://${var.s3_helm_chart_bucket}/test-app-helm-0.0.2.tgz",
            "type": "s3/object"
          },
          "displayName": "test-app-helm-chart-0.0.2",
          "id": "8072c2a7-b333-4297-81af-cfefd3487db1",
          "matchArtifact": {
            "artifactAccount": "${var.s3_helm_chart_bucket}",
            "id": "e28b73e1-67a8-43eb-a63a-7f4ed0f27316",
            "name": "s3://${var.s3_helm_chart_bucket}/test-app-helm-0.0.2.tgz",
            "type": "s3/object"
          },
          "useDefaultArtifact": true,
          "usePriorArtifact": false
        },
        {
          "defaultArtifact": {
            "artifactAccount": "docker-registry",
            "id": "cc0678fd-9393-4655-a135-4c597193ac0e",
            "name": "ryanwholey/test-app",
            "reference": "ryanwholey/test-app",
            "type": "docker/image"
          },
          "displayName": "test-app-docker",
          "id": "cf0f5743-2107-4470-af6b-9f656fb9d4bd",
          "matchArtifact": {
            "artifactAccount": "docker-registry",
            "id": "572df4da-d725-47fb-b85d-aff50651e109",
            "name": "ryanwholey/test-app",
            "type": "docker/image"
          },
          "useDefaultArtifact": true,
          "usePriorArtifact": false
        }
      ],
      "keepWaitingPipelines": false,
      "lastModifiedBy": "anonymous",
      "limitConcurrent": true,
      "spelEvaluator": "v4",
      "stages": [
        {
          "expectedArtifacts": [
            {
              "defaultArtifact": {
                "customKind": true,
                "id": "255e1869-c834-403d-b360-ad27fc83951f"
              },
              "displayName": "test-app-manifest",
              "id": "71b2e98f-9a25-4eb3-a349-10220b33824e",
              "matchArtifact": {
                "id": "fc58b8d4-e91b-403a-84ce-446001ad71bd",
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
              "id": "8072c2a7-b333-4297-81af-cfefd3487db1"
            }
          ],
          "name": "Bake (Manifest)",
          "outputName": "test-app",
          "overrides": {
            "image.tag": "$${trigger['tag']}"
          },
          "notifications": [
            {
              "address": "${var.slack_channel}",
              "level": "stage",
              "type": "slack",
              "when": [
                "stage.starting"
              ]
            }
          ],
          "refId": "1",
          "requisiteStageRefIds": [],
          "templateRenderer": "HELM3",
          "type": "bakeManifest",
          "sendNotifications": true
        },
        {
          "failPipeline": true,
          "instructions": "Approve this judgement",
          "isNew": true,
          "judgmentInputs": [],
          "name": "Manual Judgment",
          "notifications": [
            {
              "address": "${var.slack_channel}",
              "level": "stage",
              "type": "slack",
              "when": [
                "manualJudgment"
              ]
            }
          ],
          "refId": "2",
          "requisiteStageRefIds": [
            "1"
          ],
          "sendNotifications": true,
          "type": "manualJudgment"
        },
        {
          "account": "ryans-context",
          "cloudProvider": "kubernetes",
          "manifestArtifactAccount": "embedded-artifact",
          "manifestArtifactId": "71b2e98f-9a25-4eb3-a349-10220b33824e",
          "moniker": {
            "app": "test-app"
          },
          "name": "Deploy (Manifest)",
          "notifications": [
            {
              "address": "${var.slack_channel}",
              "level": "stage",
              "type": "slack",
              "when": [
                "stage.complete",
                "stage.failed"
              ]
            }
          ],
          "refId": "3",
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
          "type": "deployManifest",
          "sendNotifications": true
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
      ]
    }
  EOF
}


