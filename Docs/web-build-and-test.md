# Workflow: web build & test

## Description

This workflow will lint, build & test a Vue application.

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.


### Typecheck

Same as with lint, this presumes there's a `type-check` package command.

### Unit Tests

This will use your `.env.test` as environment, and set the `ENVIRONMENT` to `ci-test-unit`.

Note that the tests are run using the `vitest` tool.

### E2E Tests

This will use your `.env.test` as environment, and set the `ENVIRONMENT` to `ci-test-e2e`.

Note that the tests are run using the `playwright` tool.

## Inputs

| Input | Description |
| ----- | ----------- |
| `node-version` | Node version to use, defaults to `lts` |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |
| `test-playwright-image` | Image to use for Playwright testing (defaults to their prebuilt version) |

## Outputs

The build job will generate an artifact with the contents of the `dist` folder.
