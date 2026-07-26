# Baseline — Root Format Check

Timestamp: 2026-07-26T00-58

Task: [P0-T6]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm run format:check`
Resolved script: `node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern --check "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" ".vscode-test.mjs" "tsconfig*.json" "run-*.cjs"`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.0 format:check
> node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern --check "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" ".vscode-test.mjs" "tsconfig*.json" "run-*.cjs"

Checking formatting...
All matched files use Prettier code style!
EXIT_CODE=0
```

## Note on Prettier Glob Scope (file-ownership relevance)

The root `format:check` glob set includes `tsconfig*.json` and `.vscode-test.mjs`, both of which are
on this feature's FORBIDDEN file list (owned by parallel orchestrations). At baseline these files are
already Prettier-clean, so a future write-mode `npm run format` invocation has no reason to modify
them. [P4-T1] re-verifies this: if write-mode format is ever needed, the artifact must confirm those
files remain byte-identical to base `fb483b84`.

The glob set also includes `jest.config.cjs` and `run-*.cjs`, which ARE in scope for this feature, so
the root formatter does cover the edits made in Phases 1 and 2.

Output Summary: PASS. Root `npm run format:check` exits 0 — all matched files use Prettier code
style at baseline. Clean base confirmed for the root formatting gate.
