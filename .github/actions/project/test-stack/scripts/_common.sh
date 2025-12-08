#!/usr/bin/env bash

# Fail on first error
set -euo pipefail

# Verify tools installed
if ! [ -x "$(command -v pnpm)" ]; then
  echo >&2 'Error: pnpm is not installed.'
  exit 1
fi

# -- Helper functions --

# Run code if debug flag is set
function if_not_debug() {
  if [ "${RUNNER_DEBUG:-}" != '1' ]; then
    "$@"
  fi
}

# Invoke PNPM with filters
function pnpm_filtered() {
  pnpm --recursive $FILTER_ARGS "$@"
}

# Push the app directory
function pushd_app() {
  pushd "apps/$APP" > /dev/null
}

# Start a log group (to bundle on github action logs)
function start_log_group() {
  echo "::group::${1}"
}

# End log group
function stop_log_group() {
  echo "::endgroup::"
}
