# Workflow: promote to environment (digitalocean)

## Description

This workflow will grab the existing docker image & tag, and re-deploy it to the given environment (kubernetes rollout). It essentially just re-tags an image and rolls it out.

If you don't provide a source environment to deploy "from", it will calculate it based on the "target" environment. This will be done based on the usual order of `development -> test -> staging -> production`.

Note: this workflow is meant for deployments to **DigitalOcean**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `environment-source` | Source environment to deploy from |
| `environment-target` | Target environment to deploy to |
| `digitalocean-container-registry` | Container registry endpoint |
| `digitalocean-cluster-id` | Target cluster ID (name) |
| `cluster-deployments` | List of deployments to rollout, separated by spaces |
| `environment-map` | Custom environment mapping (JSON object) |

| Secret | Description |
| -------- | ----------- |
| `DIGITALOCEAN_API_USER` | DigitalOcean API user (e-mail address) |
| `DIGITALOCEAN_API_TOKEN` | DigitalOcean API token |

## Outputs

_None_
