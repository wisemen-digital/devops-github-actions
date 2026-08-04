#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 1 ]; then
  echo >&2 "Usage:"
  echo "  $0 <output-file>"
  exit 1
fi
OUTPUT_FILE=$1

# For the `main` branch, always target `development`
if [[ "$GITHUB_REF" == 'refs/heads/main' ]]; then
  ENVIRONMENT='development'

# For `release` branches, only deploy on the latest one to `staging`
elif [[ "$GITHUB_REF" == refs/heads/release/* ]]; then
  BRANCH="${GITHUB_REF#refs/heads/}"
  git_fetch_release_branches

  if [[ "$BRANCH" == "release/$LATEST_RELEASE" ]]; then
    ENVIRONMENT='staging'
  elif [[ "$BRANCH" == "release/$PREVIOUS_RELEASE" ]]; then
    echo "::warning title=Invalid Env::Push on previous release branch '$BRANCH', skipping deployment…"
    exit 0
  else
    echo "::error title=Invalid Env::Push on old/unexpected release branch '$BRANCH'"
    exit 1
  fi

# For tags, only deploy on the latest one to `production`
elif [[ "$GITHUB_REF" == refs/tags/* ]]; then
  TAG=${GITHUB_REF#refs/tags/}

  if ! [[ "${TAG:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "::error title=Invalid Env::Tag '$TAG' is not semantic version 'x.y.z'"
    exit 1
  fi

  LATEST_TAG=$(git_fetch_latest_version)
  if [[ "$TAG" == "$LATEST_TAG" ]]; then
    ENVIRONMENT='production'
  else
    echo "::error title=Invalid Env::Tag $TAG is not the latest version, this is not allowed!"
    exit 1
  fi

# Otherwise throw an error
else
  echo "Unknown ref: $GITHUB_REF"
  exit 1
fi

echo "$ENVIRONMENT" >> $OUTPUT_FILE
