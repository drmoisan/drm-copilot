# TypeScript Format Baseline

Timestamp: 2026-08-12T05-22

Working Directory: `extensions/drm-copilot`

Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

EXIT_CODE: 0

Output Summary: Prettier checked all extension source, test, JSON, and CommonJS files and reported that all matched files use Prettier formatting.

## Corrected initial invocation

Initial Command: `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

Initial EXIT_CODE: 1

Initial Output Summary: From the repository root, `npm exec` evaluated the globs relative to the root and reported that `test/**/*.ts` matched no files. The matched files had no formatting defects. The uninterrupted TypeScript loop restarted at the successful extension-local command above.
