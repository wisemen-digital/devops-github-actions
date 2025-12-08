#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

if_not_debug export UNIT_TEST_REPORTER="--reporter=junit --outputFile=${APP}-unit-test-report-junit.xml"
if_not_debug export PLAYWRIGHT_JUNIT_OUTPUT_NAME="${APP}-e2e-test-report-junit.xml"

pushd_app
if test -f '.env.test'; then
  cp -f '.env.test' '.env'
fi
touch .env

# Run Unit Tests

sed -i -e 's/ENVIRONMENT=.*/ENVIRONMENT=ci-test-unit/g' '.env'
start_log_group "Run Vue Unit tests"
pnpm vitest --run $UNIT_TEST_REPORTER
stop_log_group

# Run E2E Tests

sed -i -e 's/ENVIRONMENT=.*/ENVIRONMENT=ci-test-e2e/g' '.env'
start_log_group "Run Vue E2E tests"
pnpm exec playwright test --reporter=junit
stop_log_group
