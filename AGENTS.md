# Repository Guidelines

## Project Scope

This repository is a public Tuist starter template for an iOS app that also supports Mac Catalyst.

- Prefer modern Apple APIs and platform conventions for `iOS 26.0+`.
- Keep the starter reusable and product-neutral.
- Treat this repository as template infrastructure, not as a finished app.

## Template Rules

- Placeholder values such as `__PROJECT_NAME__`, `__BUNDLE_ID__`, and `__FULL_HANDLE__` are intentional.
- Keep the template generic. Do not reintroduce product-specific names or business logic.
- If you change a script, make sure the Codex actions and `README.md` still describe the same command flow.

## Tuist Workflow

- Use Tuist as the source of truth for project generation.
- Prefer these commands after the template is materialized:
  - `mise run run-macos`
  - `mise run run-ios-sim`
  - `mise run build-ios-sim`
  - `mise run test-macos`
  - `mise run test-ios`
  - `mise run warm-external-cache`
  - `mise run share-ios-preview`
- The scripted workflow scopes Tuist's cache home into `.cache/tuist`, ensures Tuist's Xcode cache daemon is configured for the repo `fullHandle`, warms external binary cache with the `only-external` profile, and regenerates when manifests or dependency inputs change.
- Use `mise exec -- tuist generate --configuration Debug --cache-profile only-external --no-open __PROJECT_NAME__ __TEST_SCHEME__` for manual regeneration.

## Coding Style

- Use 4-space indentation.
- Prefer clear `UpperCamelCase` type names and small SwiftUI starter views.
- Keep the template sample code intentionally minimal and easy to replace.
