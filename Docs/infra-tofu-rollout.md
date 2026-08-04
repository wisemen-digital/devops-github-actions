# Workflow: infra tofu rollout

## Description

Applies Terragrunt/OpenTofu infrastructure. It first ensures the S3 state bucket
exists, then runs `terragrunt run-all apply -auto-approve` across every stack in
dependency order (`scw/infras → scw/environments/* → hoop + github`).

Call it from a `push` (to `main`) or `workflow_dispatch` workflow with `secrets: inherit`.

```yaml
jobs:
  apply:
    uses: wisemen-digital/devops-github-actions/.github/workflows/infra-tofu-rollout.yml@v2
    secrets: inherit
```

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `working-dir` | Terragrunt working directory. Defaults to `terraform` | No |
| `state-bucket` | State bucket name. Defaults to `<repo>-tf-state-1a2b3` | No |

### Variables & Secrets

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `K8S_MODULES_SECRET` | Token with read access to the private Terraform module repositories | Secret | Yes |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | Yes |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | Yes |
| `HOOP_API_KEY` | Hoop API key (`TF_VAR_hoop_api_key`) | Secret | No |
| `GH_TERRAFORM_PRIVATE_KEY` | GitHub App PEM for the terraform github provider | Secret | No |
| `GH_KUBECONFIGS_PRIVATE_KEY` | GitHub App PEM for kubeconfig writes | Secret | No |
| `SCALEWAY_REGION` / `SCALEWAY_ORGANIZATION_ID` / `SCALEWAY_PROJECT_ID` / `SCALEWAY_ZONE` | Scaleway targeting | Variable | Yes |
| `HOOP_API_URL` | Hoop API URL (`TF_VAR_hoop_api_url`) | Variable | No |
| `RUNNER_INFRA` | CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |

## Outputs

_None_
