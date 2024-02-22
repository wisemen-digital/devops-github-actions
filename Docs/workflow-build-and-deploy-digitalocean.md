# Workflow: build & deploy (digitalocean)

## Description

This workflow will build the docker image and deploy it to the given environment (kubernetes rollout).

Note: this workflow is meant for deployments to **DigitalOcean**.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `environment` | Target environment to deploy to, usually `development` |
| `digitalocean-container-registry` | Container registry endpoint |
| `digitalocean-cluster-id` | Target cluster ID (name) |
| `cluster-deployments` | List of deployments to rollout, separated by spaces |

| Secret | Description |
| -------- | ----------- |
| `DIGITALOCEAN_API_USER` | DigitalOcean API user (e-mail address) |
| `DIGITALOCEAN_API_TOKEN` | DigitalOcean API token |

## Outputs

_None_
