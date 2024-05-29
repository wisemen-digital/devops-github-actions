# Workflow: s3 rollout (scaleway)

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/s3-rollout-filters.yaml` file)
- Use the provided `bucket-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified object storage using the configuration stored in that folder.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `bucket-deployments` | List of deployments to rollout, separated by commas |

| Secret | Description |
| ------ | ----------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `SCALEWAY_REGION` | Target deployment region (such as `nl-ams`) |

## Outputs

_None_
