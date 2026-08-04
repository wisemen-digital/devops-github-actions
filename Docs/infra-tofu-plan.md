# Workflow: infra tofu plan

## Description

PR check for Terragrunt/OpenTofu infrastructure. It runs `terragrunt run-all plan`
across **every** stack (so drift from `sysops-tf-modules` bumps is caught, even when
no repo file changed) and posts a **sticky PR comment showing only what changed**:
per stack a `+add ~change -destroy` summary plus a collapsible `tofu show` diff. The
backend-init / provider-download / state-refresh noise is stripped, and stacks with
no changes are listed compactly at the bottom.

Call it from a `pull_request`-triggered workflow with `secrets: inherit`.

```yaml
jobs:
  plan:
    uses: wisemen-digital/devops-github-actions/.github/workflows/infra-tofu-plan.yml@v2
    secrets: inherit
```

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `working-dir` | Terragrunt working directory. Defaults to `terraform` | No |

### Variables & Secrets

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `K8S_MODULES_SECRET` | Token with read access to the private Terraform module repositories | Secret | Yes |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | No |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | No |
| `HOOP_API_KEY` | Hoop API key (`TF_VAR_hoop_api_key`) | Secret | No |
| `GH_TERRAFORM_PRIVATE_KEY` | GitHub App PEM for the terraform github provider | Secret | No |
| `GH_KUBECONFIGS_PRIVATE_KEY` | GitHub App PEM for kubeconfig writes | Secret | No |
| `SCALEWAY_REGION` / `SCALEWAY_ORGANIZATION_ID` / `SCALEWAY_PROJECT_ID` / `SCALEWAY_ZONE` | Scaleway targeting | Variable | Yes |
| `HOOP_API_URL` | Hoop API URL (`TF_VAR_hoop_api_url`) | Variable | No |
| `RUNNER_DEFAULT` | CI runner. Defaults to `ubuntu-latest` | Variable | No |

## Outputs

_None_ (posts/updates a PR comment tagged `tofu-plan`).
