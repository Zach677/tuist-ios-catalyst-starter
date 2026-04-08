# __PROJECT_NAME__ Catalyst Template

This repository is a public Tuist starter template for an iOS app with Mac Catalyst support.

It is meant to be consumed by the future `bootstrap-tuist-mobile-project` skill and `zach-mobile-init` CLI, which will replace placeholders such as:

- `__PROJECT_NAME__`
- `__BUNDLE_ID__`
- `__FULL_HANDLE__`
- `__IOS_SIMULATOR_DEVICE__`

## Included Workflow

- `mise run run-macos`
- `mise run run-ios-sim`
- `mise run build-ios-sim`
- `mise run test-macos`
- `mise run test-ios`
- `mise run warm-external-cache`
- `mise run share-ios-preview`

## Template Notes

- This repository intentionally contains placeholder values.
- The starter code is minimal by design so downstream projects can replace it quickly.
- The generated project is expected to use Tuist, `mise`, Codex actions, external binary cache warming, and Tuist Xcode cache setup.
