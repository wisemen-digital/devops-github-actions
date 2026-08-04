# Workflow: laravel build & test

## Description

This workflow will build & test a Laravel application.

### Build

After building, this will also optimize a bit by generating the events, routes and views caches.

### Test

This will use your `.env.example` as environment, but will override the database connection settings .

For the test job, it will set up:
- A MySQL database, the credentials of which will be injected by ENV.

Note that the tests are run using the `pest` tool.

## Inputs & Secrets

| Input | Description | Type | Required |
| ----- | ----------- | ---- | -------- |
| `php-version` | PHP version to use, defaults to `8.3` | Input | Yes |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) | Input | No |
| `test-mysql-image` | MySQL image to use for the tests, defaults to MySQL 8 | Input | No |
| `COMPOSER_AUTH` | JSON for access to private Composer packages | Secret | No |
| `EXTRA_NPMRC` | Snippet to place in `.npmrc` to access private packages | Secret | No |

## Outputs

The build job will generate an artifact with the contents of the app folder, including installed dependencies.
