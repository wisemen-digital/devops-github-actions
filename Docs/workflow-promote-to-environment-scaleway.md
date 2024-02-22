# Workflow: promote to environment (scaleway)

## Description

This workflow will grab the existing docker image & tag, and re-deploy it to the given environment (kubernetes rollout). It essentially just re-tags an image and rolls it out.

If you don't provide a source environment to deploy "from", it will calculate it based on the "target" environment. This will be done based on the usual order of `development -> test -> staging -> production`.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `environment-source` | Source environment to deploy from |
| `environment-target` | Target environment to deploy to |
| `scaleway-container-registry` | Container registry endpoint |
| `scaleway-organization-id` | Scaleway organization ID |
| `scaleway-project-id` | Scaleway project ID, the same as org. ID for default projects |
| `scaleway-region` | Target deployment region (such as `nl-ams`) |
| `scaleway-cluster-id` | Target cluster ID |
| `cluster-deployments` | List of deployments to rollout, separated by spaces |
| `environment-map` | Custom environment mapping (JSON object) |

| Secret | Description |
| -------- | ----------- |
| `SCALEWAY_ACCESS_KEY` | Target environment to deploy to, usually `development` |
| `SCALEWAY_SECRET_KEY` | Scaleway API key ID |

## Outputs

_None_
