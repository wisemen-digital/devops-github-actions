# Workflow: infra secret write

## Description

Adds or overwrites **one key** in an application's manual secret, without losing the other keys it
already holds, behind a human approval gate.

The secret is `<project>-<environment>-secrets-manual`, created empty by Terraform with
`prevent_destroy` and managed by hand from then on. External Secrets Operator rebuilds the
Kubernetes secret from its sources on every sync, so a write that dropped a key would take that
variable out of the running pods. The workflow therefore reads the current version, merges the one
new key into it, and writes the result as a new version.

Three jobs:

1. **preflight** validates the key and the value, resolves the project and the secret, and proves
   the write can succeed. Nothing is written and nobody is asked to approve a request that cannot
   work.
2. **approval** opens an issue and waits for one of the listed approvers to comment. This stands in
   for GitHub's required reviewers, which need Enterprise on a private repository. The job holds no
   vendor credential and declares no environment, so the only thing it can reach is its own issue.
3. **write** does the read-merge-write. It is the only job holding a credential that can write.

The gate stops mistakes, not people with push access: anyone who can dispatch the workflow can also
change its definition. Point `write-environment` at an environment with a protected-branch policy,
which refuses the write job unless the ref is a protected branch. What is left depends on that
branch's own protection rules.

## Caller requirements

Two things are not optional.

**The dispatch input holding the value must be named `value`.** The mask step reads it out of the
event payload, because putting it in a step's `env:` would print it to the log before the mask
exists.

**Secrets must be mapped explicitly, not inherited.** `SECRET_VALUE` is not a repository secret, so
`secrets: inherit` cannot supply it.

```yaml
name: Add manual secret

on:
  workflow_dispatch:
    inputs:
      project:
        description: Application
        type: choice
        required: true
        options:
          - my-app
      environment:
        description: Environment
        type: choice
        required: true
        default: development
        options:
          - development
          - staging
          - production
      key:
        description: Variable name, e.g. STRIPE_SECRET_KEY
        type: string
        required: true
      value:
        description: Secret value
        type: string
        required: true

permissions: {}

jobs:
  add-manual-secret:
    uses: wisemen-digital/devops-github-actions/.github/workflows/infra-secret-write.yml@v1
    with:
      vendor: scaleway
      project: ${{ inputs.project }}
      environment: ${{ inputs.environment }}
      key: ${{ inputs.key }}
      approvers: alice,bob
    secrets:
      SECRET_VALUE: ${{ inputs.value }}
      SCALEWAY_ACCESS_KEY: ${{ secrets.SCALEWAY_ACCESS_KEY }}
      SCALEWAY_SECRET_KEY: ${{ secrets.SCALEWAY_SECRET_KEY }}
```

## Inputs

### Common Inputs

| Input | Description | Required |
| ----- | ----------- | -------- |
| `vendor` | The vendor to communicate with. Only `scaleway` is supported, see Vendor support below | Yes |
| `project` | Application name, the prefix of the vendor project | Yes |
| `environment` | Environment name, the suffix of the vendor project | Yes |
| `key` | Variable name to add or overwrite. Letters, digits and underscores, not starting with a digit | Yes |
| `approvers` | Comma-separated GitHub logins allowed to approve. Usernames, never a team slug | Yes |
| `write-environment` | Environment the write job runs in, for its branch policy. Defaults to `secret-write-approval` | No |

`approvers` must be usernames. The approval action resolves each entry as a team slug before falling
back to a username, so a team works for approving but the audit record cannot name who decided, and
reporting that correctly would need an org-read token this workflow deliberately does not hold.

### Variables & Secrets

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `SECRET_VALUE` | The value to store. Minimum 8 characters | Secret | Yes |
| `RUNNER_INFRA` | The CI runner for infra actions. Defaults to `ubuntu-latest` | Variable | No |

### Vendor-Specific Inputs

Only provide the following for your chosen vendor.

#### Scaleway

<details>
<summary>Click to expand Scaleway-specific inputs</summary>

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `SCALEWAY_ACCESS_KEY` | Scaleway API key ID | Secret | Yes |
| `SCALEWAY_SECRET_KEY` | Scaleway API key secret | Secret | Yes |
| `SCALEWAY_ORGANIZATION_ID` | Scaleway organization ID | Variable | Yes |
| `SCALEWAY_PROJECT_ID` | Scaleway project ID for the CLI profile. The organization's `default` project, not the app's | Variable | Yes |
| `SCALEWAY_REGION` | Scaleway region. Defaults to `nl-ams` | Variable | No |

</details>

## Vendor support

Only `scaleway` works. The other two are blocked by the vendors, not by this code:

- **DigitalOcean** has no managed secret manager, and External Secrets Operator has no DigitalOcean
  provider, so there is nothing to write to.
- **Azure Key Vault** holds one value per secret, so there is nothing to merge. Supporting it means a
  different algorithm, not a different backend.

Both are rejected explicitly rather than falling through to `Unsupported vendor`, so the message
says why.

### Adding a vendor

Both actions follow `infra/common/setup`: a `case` listing the implemented vendors, then that
vendor's steps behind `if: ${{ inputs.vendor == '<name>' }}`. Add the arm and the steps in the same
change, or the vendor skips every step and reports success having written nothing.

Already neutral: the key must be a valid environment variable name, the minimum value length, and the
value-inside-key check. The workflow itself is neutral throughout.

The vendor's: resolving the target name, the value-inside-target-name check, the CLI setup, and
proving the target exists. A vendor with stricter naming adds that check too, Key Vault allowing no
underscores where this key rule requires them.

Every output of `secrets/preflight` reads a Scaleway step id, so a second vendor's outputs come back
empty until each one falls back across both: `${{ steps.a.outputs.x || steps.b.outputs.x }}`.

## Validation

The write is refused before anything happens if:

- the key is not a valid environment variable name. It reaches the pod through `envFrom`, which
  silently skips an invalid name
- the value is shorter than 8 characters. Masking is literal replacement, so a short value is
  recoverable from its own redaction
- the value occurs inside the key or the secret name, for the same reason
- the vendor project does not exist. The error lists the environments that do
- the secret does not exist, is not `key_value`, or more than one secret shares its name

If the secret exists but every version of it is disabled, the write proceeds from an empty object
and the approver is warned in the issue and in both summaries, because the disabled versions survive
and can be re-enabled.

## Concurrency

The write job takes a lock per project and environment, with `cancel-in-progress: false`.
Read-merge-write is not atomic and there is no compare-and-swap, so two overlapping runs would both
read the same version and the second would discard the first key.

The lock is on the job rather than the workflow, so it is held for the seconds the write takes and
not for the hour the approval may wait. Note that GitHub queues only one pending run per group, so a
third concurrent request cancels the second while it is pending.
