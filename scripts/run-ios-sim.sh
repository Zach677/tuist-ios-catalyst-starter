#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/tuist-common.sh"

ensure_dependencies_installed
ensure_xcode_cache_setup
ensure_external_cache_warmed
ensure_generated_workspace

args=(
  run "$STARTER_PROJECT_NAME"
  --path "$STARTER_REPO_ROOT"
  --device "$STARTER_IOS_SIMULATOR_DEVICE"
  -C "$STARTER_CONFIGURATION"
)

if [ -n "$STARTER_IOS_SIMULATOR_OS" ]; then
  args+=(-o "$STARTER_IOS_SIMULATOR_OS")
fi

run_tuist "${args[@]}"
