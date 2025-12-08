#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 2 ]; then
  echo >&2 "Usage:"
  echo "  $0 <input-file> <output-file>"
  exit 1
fi
INPUT_FILE=$1
OUTPUT_FILE=$2

# Replace placeholders and remove empty services
jq -c '
  # Replace placeholders (strings starting with …)
  walk(
    if type == "string" and test("^PLACEHOLDER_") then
      env[.]
    else
      .
    end
  )

  # Remove empty services
  | walk(
    if type == "object" and has("services") then
      .services |= with_entries(
        select(.value.image != null and .value.image != "")
      )
    else
      .
    end
  )
  ' "$INPUT_FILE" > "$OUTPUT_FILE"
