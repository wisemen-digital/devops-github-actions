# Workflow: project build & test

## Description

This workflow will lint, build & test one or more projects in a monorepo. It supports these stacks:

- NestJS
- Nuxt
- Vue.js

You must provide a `.github/monorepo-rollout-filters.yaml` file so the workflow can check which projects changed in a PR (so we can run only what's needed). In the file, each key must be annotated with the stack for that project. For example:

```yaml
nest|api:
  - …
vue|web:
  - …
```

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.

### Test

This will use your `.env.test` as environment.

Note that the tests are run depending on the stack:

- NestJS: native Node test runner, invokes `test:setup` and `test:run` package commands.
- Nuxt: uses `nuxi prepare` and then `vitest`.
- Vue.js: uses `vitest` for unit tests, and playwright for E2E tests.

## Inputs

| Input | Description |
| ----- | ----------- |
| `node-version` | Node version to use, defaults to `lts` |
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
