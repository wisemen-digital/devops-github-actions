# Workflow: infra k8s preview

## Description

This workflow will generate a preview of the k8s structure changes.

Values under `data`, `stringData` and `binaryData` of ConfigMaps and Secrets are replaced by `<redacted:xxxxxxxx>` (a hash keyed with a random per-run key) before diffing, so a changed value still shows up in the diff without exposing it. This requires [yq v4](https://github.com/mikefarah/yq) on the runner; without it, the preview is withheld.

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
