# Workflow: docker build & deploy

## Description

This workflow builds a Docker image, pushes it with the environment tag, and triggers either a cluster rollout or a serverless redeploy.

### K8S Cluster Rollout

A rollout on a cluster in the given namespace. If kubernetes labels are provided, the list of deployments will **not** be used.

### Serverless Container Redeploy

A redeploy on one or more existing Serverless Containers. Serverless redeploys start after all image variants have been built and pushed. The workflow does not create or update Serverless Container configuration. Every target container must already exist and already be configured to pull an image tag that this workflow publishes.

For multiple containers, set `SERVERLESS_CONTAINER_IDS` to a comma-separated value such as `web-container-id,api-container-id`.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `vendor` | The vendor to communicate with (azure, digitalocean, scaleway) | Yes |
| `environment` | Target environment to deploy to, usually `development` | Yes |
| `image` | Image name. Defaults to repository name | No |
| `image-variants` | List of variants to build (folders in monorepo, separated by commas) | No |

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `CONTAINER_PLATFORMS` | Comma separated list of platforms (architectures) to build for. Defaults to `linux/amd64` | Variable | No |
| `CONTAINER_REGISTRY_ENDPOINT` | Container registry endpoint. Defaults to `docker.io` | Variable | No |
| `K8S_CLUSTER_ID` | Target cluster ID | Variable | No |
| `K8S_DEPLOYMENTS` | List of deployments to rollout, separated by commas or spaces | Variable | No |
| `K8S_LABELS` | List of labels to rollout, separated by commas or spaces | Variable | No |
| `K8S_NAMESPACE` | Target cluster namespace | Variable | Yes |
| `RUNNER_DEFAULT` | The CI runner for default actions. Defaults to `ubuntu-latest` | Variable | No |
| `RUNNER_INFRA` | The CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |
| `SERVERLESS_CONTAINER_ID` | Target Serverless Container ID to redeploy (legacy single-container variable) | Variable | No |
| `SERVERLESS_CONTAINER_IDS` | Target Serverless Container IDs to redeploy, separated by commas. Takes precedence over `SERVERLESS_CONTAINER_ID` | Variable | No |

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
