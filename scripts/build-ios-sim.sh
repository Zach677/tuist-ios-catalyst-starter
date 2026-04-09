#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/tuist-common.sh"

readonly DERIVED_DATA_PATH="$STARTER_REPO_ROOT/.xcodebuild/build-ios-sim"

ensure_dependencies_installed
ensure_xcode_cache_setup
ensure_external_cache_warmed
ensure_generated_workspace

run_tuist xcodebuild build \
  -workspace "$STARTER_WORKSPACE_PATH" \
  -scheme "$STARTER_PROJECT_NAME" \
  -configuration "$STARTER_CONFIGURATION" \
  -destination "$(ios_simulator_destination)" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO
