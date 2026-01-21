#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 5 ]; then
  echo >&2 "Usage:"
  echo "  $0 <changes-matrix-file> <all-matrix-file> <stack-config-file> <matrix-source-file> <output-file>"
  exit 1
fi
INPUT_CHANGES_MATRIX_FILE=$1
INPUT_ALL_MATRIX_FILE=$2
STACK_CONFIG_FILE=$3
MATRIX_SOURCE_FILE=$4
OUTPUT_FILE=$5

# Handle bash weirdness (process substitution files can only be read once)
CHANGES_MATRIX_FILE=`mktemp`
ALL_MATRIX_FILE=`mktemp`
cat "$INPUT_CHANGES_MATRIX_FILE" > "$CHANGES_MATRIX_FILE"
cat "$INPUT_ALL_MATRIX_FILE" > "$ALL_MATRIX_FILE"

# Validate matrices (stack must exist)
invalid_stacks=`jq -nr '
  ($changes[0] + $all[0]) | map(.stack) | unique |
  map(select(
    . as $stack |
    $config[0] | has($stack) | not
  )) |
  join(" ")
  ' \
  --slurpfile changes "$CHANGES_MATRIX_FILE" \
  --slurpfile all "$ALL_MATRIX_FILE" \
  --slurpfile config "$STACK_CONFIG_FILE"`
if [[ -n "$invalid_stacks" ]]; then
  echo "::error file=${MATRIX_SOURCE_FILE}::Unknown stacks: ${invalid_stacks}"
  exit 1
fi

# Post process the given matrix by:
# - Adding missing entries
# - Merging in config data for each entry
jq -cn '
  $changes[0] | map(.path) as $changed_paths |

  # Process all (add skip property, only keep missing)
  (
    # Add skip properties and enrich with config data
    $all[0] | map(. + {skip: true} + ($config[0][.stack] // {}))
    # Only keep items not present in "changes"
    | map(
      .path as $path |
      select($changed_paths | contains([$path]) | not)
    )
  ) as $missing_items |

  # Merge extra data from config into each "changes" entry (based on stack)
  $changes[0] | map(. + ($config[0][.stack] // {})) as $changes_enriched |
  
  # Add missing entries from all
  $changes_enriched + $missing_items
  ' \
  --slurpfile changes "$CHANGES_MATRIX_FILE" \
  --slurpfile all "$ALL_MATRIX_FILE" \
  --slurpfile config "$STACK_CONFIG_FILE" > "$OUTPUT_FILE"
