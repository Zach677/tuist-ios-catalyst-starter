#!/usr/bin/env bash
set -euo pipefail

readonly STARTER_REPO_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"
readonly STARTER_PROJECT_NAME="__PROJECT_NAME__"
readonly STARTER_TEST_TARGET_NAME="__TEST_SCHEME__"
readonly STARTER_CONFIGURATION="${STARTER_CONFIGURATION:-Debug}"
export TUIST_XDG_CACHE_HOME="${TUIST_XDG_CACHE_HOME:-$STARTER_REPO_ROOT/.cache/tuist}"
readonly STARTER_TUIST_STATE_DIR="$STARTER_REPO_ROOT/.xcodebuild/tuist"
readonly STARTER_TUIST_BINARIES_DIR="$TUIST_XDG_CACHE_HOME/tuist/Binaries"
readonly STARTER_TUIST_SWIFT_PATH="$STARTER_REPO_ROOT/Tuist.swift"
readonly STARTER_SANITIZE_SCRIPT_PATH="$STARTER_REPO_ROOT/scripts/sanitize_generated_project.sh"
readonly STARTER_INSTALL_STAMP="$STARTER_TUIST_STATE_DIR/install.stamp"
readonly STARTER_SETUP_CACHE_STAMP="$STARTER_TUIST_STATE_DIR/setup-cache.stamp"
readonly STARTER_GENERATE_STAMP="$STARTER_TUIST_STATE_DIR/generate-${STARTER_CONFIGURATION}.stamp"
readonly STARTER_EXTERNAL_CACHE_STAMP="$STARTER_TUIST_STATE_DIR/external-cache-${STARTER_CONFIGURATION}.stamp"
readonly STARTER_TUIST_DIR="$STARTER_REPO_ROOT/Tuist"
readonly STARTER_ROOT_PACKAGE_SWIFT_PATH="$STARTER_REPO_ROOT/Package.swift"
readonly STARTER_ROOT_PACKAGE_RESOLVED_PATH="$STARTER_REPO_ROOT/Package.resolved"
readonly STARTER_TUIST_PACKAGE_SWIFT_PATH="$STARTER_TUIST_DIR/Package.swift"
readonly STARTER_TUIST_PACKAGE_RESOLVED_PATH="$STARTER_TUIST_DIR/Package.resolved"
readonly STARTER_WORKSPACE_PATH="$STARTER_REPO_ROOT/${STARTER_PROJECT_NAME}.xcworkspace"
readonly STARTER_PROJECT_PATH="$STARTER_REPO_ROOT/${STARTER_PROJECT_NAME}.xcodeproj"
readonly STARTER_IOS_SIMULATOR_DEVICE="${STARTER_IOS_SIMULATOR_DEVICE:-__IOS_SIMULATOR_DEVICE__}"
readonly STARTER_IOS_SIMULATOR_OS="${STARTER_IOS_SIMULATOR_OS:-}"

resolve_tuist_full_handle() {
  if [ -e "$STARTER_TUIST_SWIFT_PATH" ]; then
    sed -n 's/.*fullHandle: "\(.*\)".*/\1/p' "$STARTER_TUIST_SWIFT_PATH" | head -n 1
  fi
}

readonly STARTER_TUIST_FULL_HANDLE="$(resolve_tuist_full_handle)"
readonly STARTER_TUIST_CACHE_SERVICE_SLUG="${STARTER_TUIST_FULL_HANDLE//\//_}"
readonly STARTER_TUIST_CACHE_SERVICE_LABEL="${STARTER_TUIST_FULL_HANDLE:+tuist.cache.$STARTER_TUIST_CACHE_SERVICE_SLUG}"
readonly STARTER_TUIST_CACHE_SOCKET_PATH="${STARTER_TUIST_FULL_HANDLE:+$HOME/.local/state/tuist/$STARTER_TUIST_CACHE_SERVICE_SLUG.sock}"
readonly STARTER_TUIST_CACHE_LAUNCH_AGENT_PATH="${STARTER_TUIST_FULL_HANDLE:+$HOME/Library/LaunchAgents/$STARTER_TUIST_CACHE_SERVICE_LABEL.plist}"

resolve_tuist_bin() {
  if command -v mise >/dev/null 2>&1; then
    (
      cd "$STARTER_REPO_ROOT"
      mise which tuist
    )
    return
  fi

  command -v tuist
}

readonly STARTER_TUIST_BIN="$(resolve_tuist_bin)"

mkdir -p "$TUIST_XDG_CACHE_HOME"

run_tuist() {
  (
    cd "$STARTER_REPO_ROOT"
    "$STARTER_TUIST_BIN" "$@"
  )
}

touch_stamp() {
  mkdir -p "$STARTER_TUIST_STATE_DIR"
  touch "$1"
}

inputs_newer_than_stamp() {
  local stamp_path="$1"
  shift

  if [ ! -f "$stamp_path" ]; then
    return 0
  fi

  while IFS= read -r path; do
    if [ "$path" -nt "$stamp_path" ]; then
      return 0
    fi
  done < <("$@" | sort -u)

  return 1
}

list_dependency_inputs() {
  local path

  for path in \
    "$STARTER_ROOT_PACKAGE_SWIFT_PATH" \
    "$STARTER_ROOT_PACKAGE_RESOLVED_PATH" \
    "$STARTER_TUIST_PACKAGE_SWIFT_PATH" \
    "$STARTER_TUIST_PACKAGE_RESOLVED_PATH"; do
    if [ -e "$path" ]; then
      printf '%s\n' "$path"
    fi
  done
}

list_cache_setup_inputs() {
  if [ -e "$STARTER_TUIST_SWIFT_PATH" ]; then
    printf '%s\n' "$STARTER_TUIST_SWIFT_PATH"
  fi
}

cache_binaries_present() {
  [ -d "$STARTER_TUIST_BINARIES_DIR" ] || return 1

  find "$STARTER_TUIST_BINARIES_DIR" -mindepth 2 -maxdepth 2 \
    \( -name '*.xcframework' -o -name '*.bundle' \) \
    -print -quit | grep -q .
}

list_generation_inputs() {
  local path

  for path in \
    "$STARTER_REPO_ROOT/Project.swift" \
    "$STARTER_REPO_ROOT/Tuist.swift" \
    "$STARTER_SANITIZE_SCRIPT_PATH" \
    "$STARTER_ROOT_PACKAGE_SWIFT_PATH" \
    "$STARTER_ROOT_PACKAGE_RESOLVED_PATH" \
    "$STARTER_TUIST_PACKAGE_SWIFT_PATH" \
    "$STARTER_TUIST_PACKAGE_RESOLVED_PATH"; do
    if [ -e "$path" ]; then
      printf '%s\n' "$path"
    fi
  done

  if [ -d "$STARTER_TUIST_DIR" ]; then
    find "$STARTER_TUIST_DIR" -type f \( -name '*.swift' -o -name 'Package.swift' -o -name 'Package.resolved' \)
  fi
}

xcode_cache_enabled() {
  [ -e "$STARTER_TUIST_SWIFT_PATH" ] || return 1
  rg -q 'enableCaching:\s*true' "$STARTER_TUIST_SWIFT_PATH"
}

tuist_logged_in() {
  run_tuist auth whoami >/dev/null 2>&1
}

xcode_cache_service_running() {
  [ -n "$STARTER_TUIST_CACHE_SERVICE_LABEL" ] || return 1

  local pid
  pid="$(launchctl list | awk -v label="$STARTER_TUIST_CACHE_SERVICE_LABEL" '$3 == label { print $1 }')"
  [ -n "$pid" ] && [ "$pid" != "-" ]
}

needs_xcode_cache_setup() {
  if ! xcode_cache_enabled; then
    return 1
  fi

  if [ -z "$STARTER_TUIST_FULL_HANDLE" ]; then
    return 1
  fi

  if [ ! -f "$STARTER_TUIST_CACHE_LAUNCH_AGENT_PATH" ]; then
    return 0
  fi

  if ! xcode_cache_service_running; then
    return 0
  fi

  if [ ! -S "$STARTER_TUIST_CACHE_SOCKET_PATH" ]; then
    return 0
  fi

  inputs_newer_than_stamp "$STARTER_SETUP_CACHE_STAMP" list_cache_setup_inputs
}

needs_dependency_install() {
  if ! list_dependency_inputs | grep -q .; then
    return 1
  fi

  if [ ! -d "$STARTER_TUIST_DIR/.build/checkouts" ] && [ ! -d "$STARTER_REPO_ROOT/.build/checkouts" ]; then
    return 0
  fi

  inputs_newer_than_stamp "$STARTER_INSTALL_STAMP" list_dependency_inputs
}

ensure_dependencies_installed() {
  if needs_dependency_install; then
    echo "Resolving Swift package dependencies with pinned Tuist..."
    run_tuist install
    touch_stamp "$STARTER_INSTALL_STAMP"
  else
    echo "Skipping tuist install; package graph is unchanged."
  fi
}

ensure_xcode_cache_setup() {
  if ! xcode_cache_enabled; then
    return
  fi

  if [ -z "$STARTER_TUIST_FULL_HANDLE" ]; then
    echo "Skipping Tuist Xcode cache setup because fullHandle is not configured."
    return
  fi

  if ! needs_xcode_cache_setup; then
    echo "Skipping Tuist Xcode cache setup; daemon is already configured."
    return
  fi

  if ! tuist_logged_in; then
    echo "Skipping Tuist Xcode cache setup because Tuist is not logged in."
    return
  fi

  echo "Ensuring Tuist Xcode cache is configured..."
  run_tuist setup cache --path "$STARTER_REPO_ROOT"

  if [ -f "$STARTER_TUIST_CACHE_LAUNCH_AGENT_PATH" ]; then
    launchctl bootstrap "gui/$(id -u)" "$STARTER_TUIST_CACHE_LAUNCH_AGENT_PATH" >/dev/null 2>&1 || true
    launchctl kickstart -k "gui/$(id -u)/$STARTER_TUIST_CACHE_SERVICE_LABEL" >/dev/null 2>&1 || true
  fi

  touch_stamp "$STARTER_SETUP_CACHE_STAMP"
}

external_cache_warming_enabled() {
  case "${STARTER_SKIP_EXTERNAL_CACHE_WARM:-0}" in
    1|true|TRUE|yes|YES)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

needs_external_cache_warm() {
  if [ "${STARTER_FORCE_EXTERNAL_CACHE_WARM:-0}" = "1" ]; then
    return 0
  fi

  if ! cache_binaries_present; then
    return 0
  fi

  inputs_newer_than_stamp "$STARTER_EXTERNAL_CACHE_STAMP" list_dependency_inputs
}

ensure_external_cache_warmed() {
  if ! external_cache_warming_enabled; then
    echo "Skipping external cache warm because STARTER_SKIP_EXTERNAL_CACHE_WARM is set."
    return
  fi

  if needs_external_cache_warm; then
    echo "Warming Tuist binary cache for external dependencies..."
    run_tuist cache warm \
      --path "$STARTER_REPO_ROOT" \
      --configuration "$STARTER_CONFIGURATION" \
      --external-only
    touch_stamp "$STARTER_EXTERNAL_CACHE_STAMP"
  else
    echo "Skipping external cache warm; dependency graph is unchanged."
  fi
}

needs_generation() {
  if [ ! -d "$STARTER_WORKSPACE_PATH" ] || [ ! -d "$STARTER_PROJECT_PATH" ]; then
    return 0
  fi

  if [ "$STARTER_EXTERNAL_CACHE_STAMP" -nt "$STARTER_GENERATE_STAMP" ]; then
    return 0
  fi

  inputs_newer_than_stamp "$STARTER_GENERATE_STAMP" list_generation_inputs
}

sanitize_generated_project() {
  if [ -f "$STARTER_SANITIZE_SCRIPT_PATH" ]; then
    "$STARTER_SANITIZE_SCRIPT_PATH"
  fi
}

ensure_generated_workspace() {
  if needs_generation; then
    echo "Generating workspace with cache-aware Tuist settings..."
    run_tuist generate \
      --path "$STARTER_REPO_ROOT" \
      --configuration "$STARTER_CONFIGURATION" \
      --cache-profile only-external \
      --no-open \
      "$STARTER_PROJECT_NAME" \
      "$STARTER_TEST_TARGET_NAME"
    sanitize_generated_project
    touch_stamp "$STARTER_GENERATE_STAMP"
  else
    echo "Skipping generate; manifests are unchanged."
  fi
}
