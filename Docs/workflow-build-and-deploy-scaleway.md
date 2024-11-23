# Workflow: build & deploy (scaleway)

## Description

This workflow will build the docker image and deploy it to the given environment (kubernetes rollout). If kubernetes labels are provided, the list of deployments will **not** be used.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `environment` | Target environment to deploy to, usually `development` |
| `image` | Image name (fallback to repository name) |
| `image-variants` | List of variants to build (folders in monorepo), separated by commas |

| Secret | Description |
| ------ | ----------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `CONTAINER_PLATFORMS` | Comma separated list of platforms (architectures) to build for. Defaults to `linux/amd64` |
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
