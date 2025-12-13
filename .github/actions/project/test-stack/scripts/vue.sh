#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

pushd_app
if test -f '.env.test'; then
  cp -f '.env.test' '.env'
fi
touch .env

# Run Unit Tests

start_log_group "Run Vue Unit tests"
(
  sed -i -e 's/ENVIRONMENT=.*/ENVIRONMENT=ci-test-unit/g' '.env'

  JUNIT_REPORT_FILE=${APP}-unit-test-report-junit.xml
  TEST_REPORTER_OPTIONS=()
  if_not_debug && TEST_REPORTER_OPTIONS+=(
    --reporter=junit
    --outputFile=$JUNIT_REPORT_FILE
  )

  pnpm vitest --run "${TEST_REPORTER_OPTIONS[@]}"

  # Fix node test reporter not setting a 'testsuites.name' (VITEST_JUNIT_SUITE_NAME is obsolete)
  if [ -f "$JUNIT_REPORT_FILE" ]; then
    sed -i "s/name=\"vitest tests\"/name=\"${APP} Unit Tests\"/" "$JUNIT_REPORT_FILE"
  fi
)
stop_log_group

# Run E2E Tests

start_log_group "Run Vue E2E tests"
(
  sed -i -e 's/ENVIRONMENT=.*/ENVIRONMENT=ci-test-e2e/g' '.env'

  JUNIT_REPORT_FILE=${APP}-e2e-test-report-junit.xml
  TEST_REPORTER_OPTIONS=()
  if_not_debug && TEST_REPORTER_OPTIONS+=(
    --reporter=junit
  )
  export PLAYWRIGHT_JUNIT_OUTPUT_NAME="$JUNIT_REPORT_FILE"
  export PLAYWRIGHT_JUNIT_SUITE_NAME="${APP} E2E Tests"

  pnpm exec playwright test "${TEST_REPORTER_OPTIONS[@]}"
)
stop_log_group
