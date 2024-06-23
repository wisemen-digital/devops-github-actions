# Workflow: build & deploy (digitalocean)

## Description

This workflow will build the docker image and deploy it to the given environment (kubernetes rollout). If kubernetes labels are provided, the list of deployments will **not** be used.

Note: this workflow is meant for deployments to **DigitalOcean**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `environment` | Target environment to deploy to, usually `development` |

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
