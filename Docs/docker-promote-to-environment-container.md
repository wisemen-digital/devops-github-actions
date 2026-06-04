# Workflow: docker promote to environment container

## Description

This workflow grabs an existing Docker image tag, re-tags it for the target environment, and triggers a redeploy on an existing Scaleway Serverless Container.

If you do not provide a source environment to promote from, it calculates it using the default order `development -> test -> staging -> production`.

It does not create or update the Serverless Container configuration. The target container must already exist and already be configured to pull the image tag that this workflow publishes.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `environment-source` | Source environment to deploy from | No |
| `environment-target` | Target environment to deploy to | Yes |
| `environment-map` | Custom environment mapping (JSON object) | No |
| `image` | Image name. Defaults to repository name | No |

### Variables & Secrets

These are always available for this workflow:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `CONTAINER_REGISTRY_ENDPOINT` | Container registry endpoint. Defaults to `docker.io` | Variable | No |
| `RUNNER_INFRA` | The CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | Yes |
| `SCALEWAY_ORGANIZATION_ID` | Scaleway organisation ID (i.e. account) | Variable | Yes |
| `SCALEWAY_PROJECT_ID` | Scaleway project ID (i.e. environment) | Variable | Yes |
| `SCALEWAY_REGION` | Scaleway region identifier (such as `fr-par`) | Variable | Yes |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | Yes |
| `SCALEWAY_SERVERLESS_CONTAINER_ID` | Existing Scaleway Serverless Container ID to redeploy | Variable | Yes |

## Example

```yaml
jobs:
  promote:
    uses: wisemen-digital/devops-github-actions/.github/workflows/docker-promote-to-environment-container.yml@v1
    with:
      environment-target: production
    secrets:
      SCALEWAY_ACCESS_KEY: ${{ secrets.SCALEWAY_ACCESS_KEY }}
      SCALEWAY_SECRET_KEY: ${{ secrets.SCALEWAY_SECRET_KEY }}
```

## Outputs

_None_
