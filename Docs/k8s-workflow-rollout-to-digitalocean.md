# Workflow: k8s rollout (digitalocean)

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/k8s-rollout-filters.yaml` file)
- Use the provided `cluster-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified cluster using the configuration stored in that folder.

Note: this workflow is meant for deployments to **DigitalOcean**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `digitalocean-cluster-id` | Target cluster ID (name) |
| `cluster-deployments` | List of deployments to rollout, separated by commas |

| Secret | Description |
| -------- | ----------- |
| `DIGITALOCEAN_API_TOKEN` | DigitalOcean API token |

## Outputs

_None_
