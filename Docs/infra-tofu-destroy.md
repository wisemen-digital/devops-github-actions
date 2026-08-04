# Workflow: infra tofu destroy

## Description

Guarded teardown of Terragrunt/OpenTofu infrastructure. A `confirm` input must equal
the string `destroy` or the run fails before touching anything. It then runs
`terragrunt run-all destroy -auto-approve`, which walks the dependency graph in
**reverse** (`hoop + github → scw/environments/* → scw/infras`).

Call it from a `workflow_dispatch` workflow with `secrets: inherit`, forwarding the
confirmation input.

```yaml
on:
  workflow_dispatch:
    inputs:
      confirm:
        description: 'Type "destroy" to confirm.'
        required: true
        type: string
jobs:
  destroy:
    uses: wisemen-digital/devops-github-actions/.github/workflows/infra-tofu-destroy.yml@v2
    with:
      confirm: ${{ inputs.confirm }}
    secrets: inherit
```

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `confirm` | Must equal `destroy` or the run fails | Yes |
| `working-dir` | Terragrunt working directory. Defaults to `terraform` | No |

### Variables & Secrets

Same as [`infra-tofu-rollout.yml`](infra-tofu-rollout.md).

## Outputs

_None_
