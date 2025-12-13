#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

pushd_app
if test -f '.env.test'; then
  cp -f '.env.test' '.env'
fi
touch .env

# Run Tests

start_log_group "Run Nuxt tests"
(
  JUNIT_REPORT_FILE=${APP}-test-report-junit.xml
  TEST_REPORTER_OPTIONS=()
  if_not_debug && TEST_REPORTER_OPTIONS+=(
    --reporter=junit
    --outputFile=$JUNIT_REPORT_FILE
  )

  pnpm nuxi prepare
  pnpm vitest --run "${TEST_REPORTER_OPTIONS[@]}"

  # Fix node test reporter not setting a 'testsuites.name' (VITEST_JUNIT_SUITE_NAME is obsolete)
  if [ -f "$JUNIT_REPORT_FILE" ]; then
    sed -i "s/name=\"vitest tests\"/name=\"${APP} Tests\">/" "$JUNIT_REPORT_FILE"
  fi
)
stop_log_group
