# Workflow: promote to environment (digitalocean)

## Description

This workflow will grab the existing docker image & tag, and re-deploy it to the given environment (kubernetes rollout). It essentially just re-tags an image and rolls it out. If kubernetes labels are provided, the list of deployments will **not** be used.

If you don't provide a source environment to deploy "from", it will calculate it based on the "target" environment. This will be done based on the usual order of `development -> test -> staging -> production`.

Note: this workflow is meant for deployments to **DigitalOcean**.

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
| `DIGITALOCEAN_API_USER` | DigitalOcean API user (e-mail address) |
| `DIGITALOCEAN_API_TOKEN` | DigitalOcean API token |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `CONTAINER_REGISTRY_ENDPOINT` | Container registry endpoint |
| `K8S_CLUSTER_ID` | Target cluster ID |
| `K8S_DEPLOYMENTS` | List of deployments to rollout, separated by commas or spaces |
| `K8S_LABELS` | List of labels to rollout, separated by commas or spaces |
| `K8S_NAMESPACE` | Target cluster namespace |

## Outputs

_None_
