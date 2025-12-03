# Workflow: infra lint

## Description

This workflow will lint the whole infra repository, checking S3 configuration, environment properties files, and all yaml files.

## Inputs

### Common Inputs

_None_

### Variables & Secrets

These are always available, regardless of vendor:

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `RUNNER_DEFAULT` | The CI runner for default actions. Defaults to `ubuntu-latest` | Variable | No |

## Outputs

_None_
