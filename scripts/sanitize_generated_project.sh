#!/usr/bin/env bash
set -euo pipefail

project_file="${1:-__PROJECT_NAME__.xcodeproj/project.pbxproj}"

if [ ! -f "$project_file" ]; then
  echo "Expected generated project file at $project_file" >&2
  exit 1
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

# Recent Tuist versions can emit unsupported Mac Catalyst bundle-id settings in generated projects.
perl -0pe 's/\n[ \t]*DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER = YES;//g' "$project_file" > "$tmp_file"
mv "$tmp_file" "$project_file"
