#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

if_not_debug export TEST_REPORTER="--reporter=junit --outputFile=${APP}-test-report-junit.xml"

pushd_app
if test -f '.env.test'; then
  cp -f '.env.test' '.env'
fi
touch .env

start_log_group "Run Nuxt tests"
pnpm nuxi prepare
pnpm vitest --run $TEST_REPORTER
stop_log_group
