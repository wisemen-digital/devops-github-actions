# Shared GitHub Actions

This repository contains a bunch of workflows, which can be reused accross our repositories.

## Project Workflows

Docker deployments:

| Workflow | Description |
| -------- | ----------- |
| [docker-build-and-deploy.yml](Docs/docker-build-and-deploy.md) | Build & deploy docker image to given environment |
| [docker-promote-to-environment.yml](Docs/docker-promote-to-environment.md) | Promote image to given environment |

Verification (PR check):

| Workflow | Description |
| -------- | ----------- |
| [laravel-build-and-test.yml](Docs/laravel-build-and-test.md) | Lint, build & test a Laravel app |
| [project-build-and-test.yml](Docs/project-build-and-test.md) | Lint, build & test a monorepo (Node-based) |

## Infra Workflows

Infra deployments:

| Workflow | Description |
| -------- | ----------- |
| [infra-k8s-rollout.yml](Docs/infra-k8s-rollout.md) | Apply k8s configuration for the given deployments |
| [infra-s3-rollout.yml](Docs/infra-s3-rollout.md) | Apply s3 configuration to the given buckets |

Verification (PR check):

| Workflow | Description |
| -------- | ----------- |
| [infra-k8s-preview.yml](Docs/infra-k8s-preview.md) | Generate a preview of the k8s changes |
| [infra-lint.yml](Docs/infra-lint.md) | Lint infra changes |
