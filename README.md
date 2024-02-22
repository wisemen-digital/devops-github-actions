# Shared GitHub Actions

This repository contains a bunch of workflows, which can be reused accross our repositories.

## Deployment Workflows

| Workflow | Description |
| -------- | ----------- |
| [workflow-build-and-deploy-scaleway.yml](Docs/workflow-build-and-deploy-scaleway.md) | Build & deploy docker image to given environment (on Scaleway) |
| [workflow-promote-to-environment-scaleway.yml](Docs/workflow-promote-to-environment-scaleway.md) | Promote image to given environment (on Scaleway) |

## Verification Workflows

| Workflow | Description |
| -------- | ----------- |
| [laravel-build-and-test.yml](Docs/laravel-build-and-test.md) | Lint, build & test a Laravel app |
| [node-build-and-test.yml](Docs/node-build-and-test.md) | Lint, build & test a Node app |
| [web-build-and-test.yml](Docs/web-build-and-test.md) | Lint, build & test a Web app |
