# Workflow: infra s3 rollout

## Description

This workflow will either:
- *By default:* Check which folders have changed (using the `.github/k8s-rollout-filters.yaml` file)
- Use the provided `bucket-deployments` list (comma separated)

Using either list, it will trigger a rollout to the specified bucket using the configuration stored in that folder.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `vendor` | The vendor to communicate with (azure, digitalocean, scaleway) | Yes |
| `bucket-deployments` | List of buckets to rollout, separated by commas. You can provide the "magic" value of `_all_` to trigger all deployments. | No |

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `RUNNER_DEFAULT` | The CI runner for default actions. Defaults to `ubuntu-latest` | Variable | No |
| `RUNNER_INFRA` | The CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |

### Vendor-Specific Inputs

Only provide the following for your chosen vendor.

#### DigitalOcean

<details>
<summary>Click to expand DigitalOcean-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `DIGITALOCEAN_ACCESS_KEY` | DigitalOcean API access key | Secret | Yes |
| `DIGITALOCEAN_REGION`| DigitalOcean region identifier | Variable | Yes |
| `DIGITALOCEAN_SECRET_KEY` | DigitalOcean API secret key | Secret | Yes |

</details>

#### Scaleway

<details>
<summary>Click to expand Scaleway-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | Yes |
| `SCALEWAY_REGION` | Scaleway region identifier (such as `fr-par`) | Variable | Yes |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | Yes |

</details>

## Outputs

_None_
