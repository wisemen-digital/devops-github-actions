# Workflow: infra k8s preview

## Description

This workflow will generate a preview of the k8s structure changes.

## Inputs

### Common Inputs

_None_

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `K8S_MODULES_SECRET` | Github token to access the private modules repository | Secret | Yes |
| `RUNNER_DEFAULT` | The CI runner for default actions. Defaults to `ubuntu-latest` | Variable | No |

## Outputs

_None_
