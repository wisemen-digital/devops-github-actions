# Workflow: nuxt build & test

## Description

This workflow will lint, build & test a Nuxt application.

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.

### Test

This will use your `.env.test` as environment.

Note that the tests are run using the `vitest` tool.

## Inputs

| Variable | Description |
| -------- | ----------- |
| `node-version` | Node version to use, defaults to `lts` |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |

## Outputs

The build job will generate an artifact with the contents of the `.output` folder.
