# Workflow: web build & test

## Description

This workflow will lint, build & test a Vue application.

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.


### Typecheck

Same as with lint, this presumes there's a `type-check` package command.

### Test

This will use your `.env.test` as environment.

Note that the tests are run using the `vitest` tool.

## Inputs

| Input | Description |
| ----- | ----------- |
| `node-version` | Node version to use, defaults to `lts` |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |

## Outputs

The build job will generate an artifact with the contents of the `dist` folder.
