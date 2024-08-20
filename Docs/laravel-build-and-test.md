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

## Inputs

| Input | Description |
| ----- | ----------- |
| `php-version` | PHP version to use, defaults to `8.3` |
| `test-timeout` | Time in minutes after wich the test job will timeout (defaults to `5`) |
| `test-mysql-image` | MySQL image to use for the tests, defaults to MySQL 8 |

## Outputs

The build job will generate an artifact with the contents of the app folder, including installed dependencies.
