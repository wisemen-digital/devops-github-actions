# Workflow: flutter build & test

## Description

This workflow will format, build, analyze & test a Flutter application.

### Verify-formatting

This job runs a dart format command that uses formatting rules from `analysis_options.yaml`

### Generate-matrix

This requires a `package-filters.yaml` file in the `.github` folder of the repository. Generates a matrix for the listed options so the next steps can run async. 

The root app has to be defined as `.`

### Generate-code

Uses dart build runner to generate code used by packages. Creates artifacts that are combined in the next job.

### Merge

Merge generated artifacts because test job needs all generated code to be compilable.

### Test

Fixes artifact paths and runs tests with coverage. This job requires at least one test to be able to report coverage.

## Inputs

| Input | Description |
| ----- | ----------- |
| `build-timeout` | Time in minutes after which the generate-code job will timeout (defaults to `5`) |
| `test-timeout` | Time in minutes after which the test job will timeout (defaults to `5`) |
| `test-coverage` | Minimum required code coverage for test step to pass (defaults to `0`) |

## Outputs

The build job will generate an artifact with the contents of the `dist` and `_build` folders.
