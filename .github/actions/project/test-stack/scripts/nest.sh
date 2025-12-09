#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Run Tests

start_log_group "Run Node tests"
(
  JUNIT_REPORT_FILE=${APP}-test-report-junit.xml
  NODE_OPTIONS_ARRAY=(
    --test-reporter=tap
    --test-reporter-destination=stdout
  )
  if_not_debug && NODE_OPTIONS_ARRAY+=(
    --test-reporter=junit
    --test-reporter-destination=$JUNIT_REPORT_FILE
  )
  export NODE_OPTIONS="${NODE_OPTIONS_ARRAY[*]}"

  pnpm_filtered test:setup
  pnpm_filtered test:run

  # Fix node test reporter not setting a 'testsuites.name' (there's no flag/variable)
  pushd_app
  if [ -f "$JUNIT_REPORT_FILE" ]; then
    sed -i "s/<testsuites>/<testsuites name=\"${APP} Tests\">/" "$JUNIT_REPORT_FILE"
  fi
)
stop_log_group
