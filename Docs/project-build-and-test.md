# Workflow: project build & test

## Description

This workflow will lint, build & test one or more projects in a monorepo. It supports these stacks:

- NestJS
- Nuxt
- Payload
- Vue.js

You must provide a `.github/monorepo-rollout-filters.yaml` file so the workflow can check which projects changed in a PR (so we can run only what's needed). In the file, each key must be annotated with the stack for that project. For example:

```yaml
nest|api:
  - …
vue|web:
  - …
```

### Check for leaks

Simply runs `gitleaks` with a default configuration, see the [docs](https://github.com/gitleaks/gitleaks).

### Danger

Runs [Danger](https://danger.systems/js/) with our own rules setup, see the [docs](https://github.com/wisemen-digital/wisemen-core/tree/main/packages/dev-ops/danger) for more information.
Set `danger-enabled` to `false` to skip the Danger job.

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.

### Test

This will use your `.env.test` as environment.

Note that the tests are run depending on the stack:

- NestJS: native Node test runner, invokes `test:setup` and `test:run` package commands.
- Nuxt: uses `nuxi prepare` and then `vitest`.
- Payload: uses `vitest` for unit tests.
- Vue.js: uses `vitest` for unit tests, and playwright for E2E tests.

## Shared pnpm cache

To reuse dependencies across pull requests, call `project-warm-pnpm-cache.yml` on a trusted push to the default branch. It installs the workspace with the same setup action as the checks. Pass the same `node-runtime`. If tests run in a Playwright container, also pass the same `test-playwright-image` to warm its separate archive.

```yaml
on:
  push:
    branches: [main]
    paths:
      - pnpm-lock.yaml
      - pnpm-workspace.yaml
      - package.json
      - .github/workflows/warm-pnpm-cache.yml
  workflow_dispatch:

jobs:
  warm:
    if: github.ref == format('refs/heads/{0}', github.event.repository.default_branch)
    uses: wisemen-digital/devops-github-actions/.github/workflows/project-warm-pnpm-cache.yml@v1
    with:
      node-runtime: node@24
```

Set `cache-mode: read` on the PR job that calls `project-build-and-test.yml`. This applies to all GitHub Actions caches in the called jobs. Checks still perform a frozen install and fetch any packages missing from the store. Use the manual dispatch to refill an evicted archive.

## Inputs

| Input | Description |
| ----- | ----------- |
| `danger-enabled` | Whether to run Danger checks (defaults to `true`) |
| `node-runtime` | Node runtime to use, defaults to `node@lts` |
| `turbo-cache-enabled` | Enable Turbo remote cache; requires `TURBO_TOKEN` unless set to `false` (defaults to `true`) |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |
| `test-mssql-enabled` | Whether or not to create the MS SQL service (defaults to `false`) |
| `test-mssql-image` | MS SQL image to use for the tests, defaults to `mcr.microsoft.com/mssql/server:2022-latest` |
| `test-mysql-enabled` | Whether or not to create the MySQL service (defaults to `false`) |
| `test-mysql-image` | MySQL image to use for the tests, defaults to `mysql:8` |
| `test-nats-enabled` | Whether or not to create the NATS service (defaults to `false`) |
| `test-nats-image` | NATS image to use for the tests, defaults to `ghcr.io/wisemen-digital/test-nats:latest` |
| `test-playwright-image` | Playwright image to use for E2E tests, defaults to `mcr.microsoft.com/playwright:v1.57.0` |
| `test-postgres-enabled` | Whether or not to create the PostgreSQL service (defaults to `true`) |
| `test-postgres-image` | PostgreSQL image to use for the tests, defaults to `postgis/postgis` |
| `test-redis-enabled` | Whether or not to create the Redis service (defaults to `false`) |
| `test-redis-image` | Redis image to use for the tests, defaults to `redis:alpine` |
| `test-typesense-enabled` | Whether or not to create the Typesense service (defaults to `false`) |
| `test-typesense-image` | Typesense image to use for the tests, defaults to `typesense/typesense:26.0` |

## Outputs

The build job will generate an artifact with the contents of the usual build folders (`.output`, `_build`, `dist`).
