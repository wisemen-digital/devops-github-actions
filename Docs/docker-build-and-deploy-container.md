# Workflow: docker build & deploy container

## Description

This workflow builds a Docker image, pushes it with the environment tag, and triggers a redeploy on an existing Scaleway Serverless Container.

It does not create or update the Serverless Container configuration. The target container must already exist and already be configured to pull the image tag that this workflow publishes.

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `environment` | Target environment to deploy to, usually `test` or `production` | Yes |
| `image` | Image name. Defaults to repository name | No |

### Variables & Secrets

These are always available for this workflow:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `CONTAINER_PLATFORMS` | Comma separated list of platforms (architectures) to build for. Defaults to `linux/amd64` | Variable | No |
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
  deploy:
    uses: wisemen-digital/devops-github-actions/.github/workflows/docker-build-and-deploy-container.yml@v1
    with:
      environment: test
    secrets:
      SCALEWAY_ACCESS_KEY: ${{ secrets.SCALEWAY_ACCESS_KEY }}
      SCALEWAY_SECRET_KEY: ${{ secrets.SCALEWAY_SECRET_KEY }}
```

## Outputs

_None_
