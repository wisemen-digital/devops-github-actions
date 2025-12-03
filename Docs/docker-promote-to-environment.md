# Workflow: docker promote to environment

## Description

This workflow will grab the existing docker image & tag, and re-deploy it to the given environment (kubernetes rollout). It essentially just re-tags an image and rolls it out. If kubernetes labels are provided, the list of deployments will **not** be used.

If you don't provide a source environment to deploy "from", it will calculate it based on the "target" environment. This will be done based on the usual order of `development -> test -> staging -> production`.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `vendor` | The vendor to communicate with (azure, digitalocean, scaleway) | Yes |
| `environment-source` | Source environment to deploy from | Yes |
| `environment-target` | Target environment to deploy to | Yes |
| `environment-map` | Custom environment mapping (JSON object) | Yes |
| `image` | Image name. Defaults to repository name | No |
| `image-variants` | List of variants to build (folders in monorepo, separated by commas) | No |

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `CONTAINER_REGISTRY_ENDPOINT` | Container registry endpoint. Defaults to `docker.io` | Variable | No |
| `K8S_CLUSTER_ID` | Target cluster ID | Variable | Yes |
| `K8S_DEPLOYMENTS` | List of deployments to rollout, separated by commas or spaces | Variable | No |
| `K8S_LABELS` | List of labels to rollout, separated by commas or spaces | Variable | No |
| `K8S_NAMESPACE` | Target cluster namespace | Variable | Yes |
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
| `AZURE_CR_TOKEN` | Azure container registry token | Secret | Yes |
| `AZURE_CR_USER` | Azure container registry user | Secret | Yes |
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
| `DIGITALOCEAN_API_USER` | DigitalOcean API user (e-mail address) | Secret | Yes |

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
