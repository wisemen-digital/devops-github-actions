# Workflow: k8s rollout (scaleway)

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/k8s-rollout-filters.yaml` file)
- Use the provided `cluster-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified cluster using the configuration stored in that folder.

Note: this workflow is meant for deployments to **Scaleway**.

## Inputs

| Input | Description |
| ----- | ----------- |
| `cluster-deployments` | List of deployments to rollout, separated by commas |

| Secret | Description |
| ------ | ----------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret |

This workflow also depends on the following "variables" to be defined:

| Variable | Description |
| -------- | ----------- |
| `K8S_CLUSTER_ID` | Target cluster ID |
| `SCALEWAY_ORGANIZATION_ID` | Scaleway organization ID |
| `SCALEWAY_PROJECT_ID` | Scaleway project ID, the same as org. ID for default projects |
| `SCALEWAY_REGION` | Target deployment region (such as `nl-ams`) |

## Outputs

_None_
