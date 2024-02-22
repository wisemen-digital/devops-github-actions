# Workflow: build & deploy (scaleway)

## Description

This workflow will build the docker image and deploy it to the given environment (kubernetes rollout).

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `environment` | Target environment to deploy to, usually `development` |
| `scaleway-container-registry` | Container registry endpoint |
| `scaleway-organization-id` | Scaleway organization ID |
| `scaleway-project-id` | Scaleway project ID, the same as org. ID for default projects |
| `scaleway-region` | Target deployment region (such as `nl-ams`) |
| `scaleway-cluster-id` | Target cluster ID |
| `cluster-deployments` | List of deployments to rollout, separated by spaces |

| Secret | Description |
| -------- | ----------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret |

## Outputs

_None_
