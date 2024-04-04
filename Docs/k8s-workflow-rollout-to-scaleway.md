# Workflow: k8s rollout (scaleway)

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/rollout-filters.yaml` file)
- Use the provided `cluster-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified cluster using the configuration stored in that folder.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `scaleway-organization-id` | Scaleway organization ID |
| `scaleway-project-id` | Scaleway project ID, the same as org. ID for default projects |
| `scaleway-region` | Target deployment region (such as `nl-ams`) |
| `scaleway-cluster-id` | Target cluster ID |
| `cluster-deployments` | List of deployments to rollout, separated by commas |

| Secret | Description |
| -------- | ----------- |
| `SCALEWAY_ACCESS_KEY` | Target environment to deploy to, usually `development` |
| `SCALEWAY_SECRET_KEY` | Scaleway API key ID |

## Outputs

_None_
