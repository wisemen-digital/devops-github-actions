# Workflow: node build & test

## Description

This workflow will lint, build & test a Node application.

### Lint

This job presumes there's a `lint` package command, which usually invokes `eslint` with some file filters.

### Test

This will use your `.env.test` as environment.

For the test job, it will set up:
- A PostgreSQL database running on port `5432`, user `postgres`, password `password`, db `test_db`.
- An (optional) NATS service running on port `4222`.
- An (optional) Redis database running on port `6379`.
- An (optional) Typesense service running on port `8108` with as API key `api_key`.

## Inputs

| Input | Description |
| ----- | ----------- |
| `node-version` | Node version to use, defaults to `lts` |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |
| `test-nats-enabled` | Whether or not to create the NATS service (defaults to `false`) |
| `test-nats-image` | NATS image to use for the tests, defaults to `ghcr.io/wisemen-digital/test-nats:latest` |
| `test-postgres-image` | PostgreSQL image to use for the tests, defaults to `postgis/postgis` |
| `test-redis-enabled` | Whether or not to create the Redis service (defaults to `false`) |
| `test-redis-image` | Redis image to use for the tests, defaults to `redis:alpine` |
| `test-typesense-enabled` | Whether or not to create the Typesense service (defaults to `false`) |
| `test-typesense-image` | Typesense image to use for the tests, defaults to `typesense/typesense:26.0` |

## Outputs

The build job will generate an artifact with the contents of the `dist` and `_build` folders.
