# Workflow: infra k8s rollout

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/k8s-rollout-filters.yaml` file)
- Use the provided `cluster-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified cluster using the configuration stored in that folder.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `vendor` | The vendor to communicate with (azure, digitalocean, scaleway) | Yes |
| `cluster-deployments` | List of deployments to rollout, separated by commas. You can provide the "magic" value of `_all_` to trigger all deployments. | No |

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `K8S_CLUSTER_ID` | Target cluster ID | Variable | Yes |
| `K8S_MODULES_SECRET` | Github token to access the private modules repository | Secret | Yes |
| `RUNNER_DEFAULT` | The CI runner for default actions. Defaults to `ubuntu-latest` | Variable | No |
| `RUNNER_INFRA` | The CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |

### Vendor-Specific Inputs

Only provide the following for your chosen vendor.

#### Azure

<details>
<summary>Click to expand Azure-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `AZURE_CLIENT_ID` | Azure client ID for login with an Azure service principal | Secret | Yes |
| `AZURE_RESOURCE_GROUP` | Azure resource group (like a project or namespace) | Variable | Yes |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID for login with an Azure service principal | Secret | Yes |
| `AZURE_TENANT_ID` | Azure tenant ID for login with an Azure service principal | Secret | Yes |

</details>

#### DigitalOcean

<details>
<summary>Click to expand DigitalOcean-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `DIGITALOCEAN_API_TOKEN` | DigitalOcean API token | Secret | Yes |

</details>

#### Scaleway

<details>
<summary>Click to expand Scaleway-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | Yes |
| `SCALEWAY_ORGANIZATION_ID` | Scaleway organisation ID (i.e. account) | Variable | Yes |
| `SCALEWAY_PROJECT_ID` | Scaleway project ID (i.e. environment) | Variable | Yes |
| `SCALEWAY_REGION` | Scaleway region identifier (such as `fr-par`) | Variable | Yes |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | Yes |

</details>

## Outputs

_None_
