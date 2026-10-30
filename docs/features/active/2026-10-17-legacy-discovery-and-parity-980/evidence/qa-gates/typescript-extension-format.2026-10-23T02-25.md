# P11-T3 TypeScript extension format gate

Timestamp: 2026-10-23T02-25
Command: npm --prefix extensions/drm-copilot exec -- prettier --check "extensions/drm-copilot/src/**/*.ts" "extensions/drm-copilot/test/**/*.ts" "extensions/drm-copilot/*.json" "extensions/drm-copilot/*.cjs"
EXIT_CODE: 0
Output Summary: The check-mode form of the extension `format` script globs: "All matched files use Prettier code style!". No file was rewritten, so the loop did not restart.
