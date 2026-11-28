#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

pushd_app
if test -f '.env.test'; then
  cp -f '.env.test' '.env'
fi
touch .env

if test -f 'playwright.config.ts'; then
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
else
  echo "Skipping Playwright tests, not configured."
fi
