#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/tuist-common.sh"

readonly DERIVED_DATA_PATH="$STARTER_REPO_ROOT/.xcodebuild/run-ios-sim"
readonly APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/${STARTER_PROJECT_NAME}.app"

ensure_dependencies_installed
ensure_xcode_cache_setup
ensure_external_cache_warmed
ensure_generated_workspace

boot_ios_simulator

run_tuist xcodebuild build \
  -workspace "$STARTER_WORKSPACE_PATH" \
  -scheme "$STARTER_PROJECT_NAME" \
  -configuration "$STARTER_CONFIGURATION" \
  -destination "$(ios_simulator_destination)" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO

if [ ! -d "$APP_PATH" ]; then
  echo "Expected app bundle at $APP_PATH" >&2
  exit 1
fi

bundle_id="$(read_app_bundle_id "$APP_PATH")"

xcrun simctl install "$STARTER_IOS_SIMULATOR_UDID" "$APP_PATH"
xcrun simctl terminate "$STARTER_IOS_SIMULATOR_UDID" "$bundle_id" >/dev/null 2>&1 || true
xcrun simctl launch "$STARTER_IOS_SIMULATOR_UDID" "$bundle_id"
