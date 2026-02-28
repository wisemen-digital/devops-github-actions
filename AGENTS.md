# Repository Guidelines

## Project Structure & Module Organization
This repository hosts reusable GitHub Actions workflows and composite actions.

- `.github/workflows/`: reusable workflows (mostly `workflow_call`) for docker, infra, and project CI/CD.
- `.github/actions/`: composite actions grouped by domain:
  - `docker/`
  - `infra/` (`k8s`, `s3`)
  - `project/` (matrix generation, setup, stack tests, service wait)
- `Docs/`: workflow documentation. Keep docs aligned with workflow names (example: `project-build-and-test.yml` -> `Docs/project-build-and-test.md`).
- `README.md`: entry point listing supported workflows.

## Build, Test, and Development Commands
There is no single local build toolchain for this repo; validation is primarily CI-driven.

- `yamllint .github`: lint workflow/action YAML files.
- `hadolint <Dockerfile>`: lint Dockerfiles when touched.
- `bash -n .github/actions/**/scripts/*.sh`: syntax-check bash scripts.
- Open a PR to run the `Lint` workflow (triggered on PRs and pushes to `main`).

## Coding Style & Naming Conventions
- YAML: 2-space indentation, clear step names, and stable IDs.
- Filenames: use kebab-case for workflows/docs (example: `infra-k8s-rollout.yml`).
- Bash scripts: start with `#!/usr/bin/env bash` and `set -euo pipefail`; keep shared helpers in `_common.sh`.
- Inputs/outputs/vars: prefer explicit, descriptive names (example: `test-postgres-enabled`, `pnpm-filter-args`).

## Testing Guidelines
- Testing happens through workflows and composite actions rather than a standalone unit test suite in this repo.
- For project test flows, keep matrix generation and stack scripts in sync (`.github/actions/project/test-stack/scripts/{nest,nuxt,vue}.sh`).
- Preserve JUnit artifact naming conventions: `*-test-report-junit.xml` for report publishing.
- When changing workflow behavior, test via a branch PR and verify lint + affected workflow runs.

## Commit & Pull Request Guidelines
- Follow existing commit style seen in history: concise imperative subjects, often with prefixes like `fix:`, `Internal:`, or `BREAKING:`.
- Keep changes scoped; include matching doc updates in `Docs/` when workflow inputs/outputs/secrets change.
- PRs should include:
  - what changed and why,
  - impacted workflows/actions,
  - required variable/secret changes for consumers.

## Security & Configuration Tips
- Never hardcode credentials; use GitHub `secrets`/`vars`.
- Document new required secrets/variables in the corresponding `Docs/*.md`.
- Prefer least-privilege tokens and minimal permissions in workflow updates.
