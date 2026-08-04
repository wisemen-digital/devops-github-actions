#!/usr/bin/env bash

# Fail on first error
set -euo pipefail

# Verify tools installed
if ! [ -x "$(command -v git)" ]; then
  echo >&2 'Error: git is not installed.'
  exit 1
fi

function git_fetch_release_branches() {
  local RELEASES=$(git ls-remote --heads origin \
    | grep -E 'refs/heads/release/[0-9]+\.[0-9]+$' \
    | sed 's#.*/release/##' \
    | sort -V -r \
    | head -n 2)
  LATEST_RELEASE=$(echo "$RELEASES" | head -n1)
  PREVIOUS_RELEASE=$(echo "$RELEASES" | sed '2q;d')
}

function git_fetch_latest_version() {
  git ls-remote --tags origin \
    | grep -E 'refs/tags/[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed 's#.*/##' \
    | sort -V -r \
    | head -n 1
}
