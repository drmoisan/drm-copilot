# Baseline TypeScript Static (P0-T3)

Timestamp: 2026-11-19T08-34
Command: sh SCRATCH/issue-1050-static.sh ts (in extensions/drm-copilot: npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; npm run lint; npm run typecheck)
EXIT_CODE: 0
Output Summary: All three steps pass before any edit.

| Step | Command | Exit code | Findings |
| --- | --- | --- | --- |
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | 0 (`All matched files use Prettier code style!`) |
| Lint | `npm run lint` | 0 | 0 |
| Type check | `npm run typecheck` | 0 | 0 (`error TS` count 0) |
