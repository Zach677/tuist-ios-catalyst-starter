#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/tuist-common.sh"

readonly DERIVED_DATA_PATH="$STARTER_REPO_ROOT/.xcodebuild/test-macos"
readonly RESULT_BUNDLE_PATH="$DERIVED_DATA_PATH/TestResults/${STARTER_PROJECT_NAME}.xcresult"

ensure_dependencies_installed
ensure_xcode_cache_setup
ensure_external_cache_warmed
ensure_generated_workspace

mkdir -p "$(dirname "$RESULT_BUNDLE_PATH")"

run_tuist test "$STARTER_PROJECT_NAME" \
  --path "$STARTER_REPO_ROOT" \
  -C "$STARTER_CONFIGURATION" \
  -T "$RESULT_BUNDLE_PATH" \
  -- \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  "$@"
