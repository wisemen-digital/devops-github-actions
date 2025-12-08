#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 2 ]; then
  echo >&2 "Usage:"
  echo "  $0 <matrix-file> <stack-config-file>"
  exit 1
fi
MATRIX_FILE=$1
STACK_CONFIG_FILE=$2

# Replace all string values that start with "PLACEHOLDER_" with their env value
jq -cn '
  $matrix[0]
  | map(. + ($config[0][.stack] // {}))
  ' \
  --slurpfile matrix "$MATRIX_FILE" \
  --slurpfile config "$STACK_CONFIG_FILE"
