# Workflow: k8s rollout (digitalocean)

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/k8s-rollout-filters.yaml` file)
- Use the provided `cluster-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified cluster using the configuration stored in that folder.

Note: this workflow is meant for deployments to **DigitalOcean**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `cluster-deployments` | List of deployments to rollout, separated by commas |

| Secret | Description |
| ------ | ----------- |
| `DIGITALOCEAN_ACCESS_KEY` | DigitalOcean API key ID |
| `DIGITALOCEAN_SECRET_KEY` | DigitalOcean API key secret |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `DIGITALOCEAN_REGION` | Target deployment region (such as `nl-ams`) |

## Outputs

_None_
