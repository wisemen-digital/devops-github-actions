# Workflow: promote to environment (scaleway)

## Description

This workflow will grab the existing docker image & tag, and re-deploy it to the given environment (kubernetes rollout). It essentially just re-tags an image and rolls it out. If kubernetes labels are provided, the list of deployments will **not** be used.

If you don't provide a source environment to deploy "from", it will calculate it based on the "target" environment. This will be done based on the usual order of `development -> test -> staging -> production`.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `environment-source` | Source environment to deploy from |
| `environment-target` | Target environment to deploy to |
| `environment-map` | Custom environment mapping (JSON object) |
| `image` | Image name (fallback to repository name) |
| `image-variants` | List of variants to roll out (folders in monorepo, separated by commas) |

| Secret | Description |
| ------ | ----------- |
| `SCALEWAY_ACCESS_KEY` | Target environment to deploy to, usually `development` |
| `SCALEWAY_SECRET_KEY` | Scaleway API key ID |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `CONTAINER_REGISTRY_ENDPOINT` | Container registry endpoint |
| `K8S_CLUSTER_ID` | Target cluster ID |
| `K8S_DEPLOYMENTS` | List of deployments to rollout, separated by commas or spaces |
| `K8S_LABELS` | List of labels to rollout, separated by commas or spaces |
| `K8S_NAMESPACE` | Target cluster namespace |
| `SCALEWAY_ORGANIZATION_ID` | Scaleway organization ID |
| `SCALEWAY_PROJECT_ID` | Scaleway project ID, the same as org. ID for default projects |
| `SCALEWAY_REGION` | Target deployment region (such as `nl-ams`) |

## Outputs

_None_
