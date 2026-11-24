# Baseline: TypeScript static for extensions/drm-copilot (P0-T3)

Timestamp: 2026-11-24T05-17
Command: (in extensions/drm-copilot, through SCRATCH/issue-1233-ts-static.sh) npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" ; npx eslint --no-error-on-unmatched-pattern src test ; npx tsc -p ./ --noEmit ; npx tsc -p tsconfig.jest.json --noEmit
EXIT_CODE: 0
Output Summary:
- prettier --check: EXIT_CODE 0; "All matched files use Prettier code style!"; 0 [warn] lines (finding count 0).
- eslint: EXIT_CODE 0; no output (finding count 0).
- tsc -p ./ --noEmit: EXIT_CODE 0; 0 "error TS" lines (finding count 0).
- tsc -p tsconfig.jest.json --noEmit: EXIT_CODE 0; 0 "error TS" lines (finding count 0).

Environment: `npm --prefix extensions/drm-copilot ci` ran once before the first TypeScript command (exit 0), because node_modules was absent.
