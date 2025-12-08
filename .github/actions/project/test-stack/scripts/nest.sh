#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

NODE_OPTIONS_ARRAY=(
  --test-reporter=tap
  --test-reporter-destination=stdout
  --test-reporter=junit
  --test-reporter-destination=${APP}-test-report-junit.xml
)
export NODE_OPTIONS="${NODE_OPTIONS_ARRAY[*]}"

start_log_group "Run Node tests"
pnpm_filtered test:setup
pnpm_filtered test:run
stop_log_group
