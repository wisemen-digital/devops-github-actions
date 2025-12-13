#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 3 ]; then
  echo >&2 "Usage:"
  echo "  $0 <changes-matrix-file> <all-matrix-file> <stack-config-file>"
  exit 1
fi
CHANGES_MATRIX_FILE=$1
ALL_MATRIX_FILE=$2
STACK_CONFIG_FILE=$3

# Post process the given matrix by:
# - Adding missing entries
# - Merging in config data for each entry
jq -cn '
  $changes[0] | map(.path) as $changed_paths |

  # Process all (add skip property, only keep missing)
  (
    # Add skip properties
    $all[0] | map(. + {skip: true})
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
  --slurpfile config "$STACK_CONFIG_FILE"
