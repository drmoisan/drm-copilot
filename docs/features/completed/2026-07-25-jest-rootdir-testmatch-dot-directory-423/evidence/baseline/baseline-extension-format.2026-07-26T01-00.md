# Baseline — Extension Format

Timestamp: 2026-07-26T01-00

Task: [P0-T9]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

## Invocation 1 — Formatter (write mode)

Command: `npm --prefix extensions/drm-copilot run format`
Resolved script: `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
EXIT_CODE: 0

Output Summary (invocation 1): Prettier processed 316 files across `src/**/*.ts`, `test/**/*.ts`,
`*.json`, and `*.cjs`. **Every single file was reported `(unchanged)`** — no file was rewritten.
Notable in-scope entries all reported unchanged: `jest.config.cjs` (4ms, unchanged) and
`run-jest.cjs` (2ms, unchanged). Files on the forbidden list that fall inside the extension package's
prettier globs — `tsconfig.json` (1ms, unchanged) and `tsconfig.jest.json` (1ms, unchanged) — were
also unchanged, as was `package.json` (2ms, unchanged) and `package-lock.json` (36ms, unchanged).

## Invocation 2 — Git status after formatter

Command: `git status --porcelain -- extensions/drm-copilot`
EXIT_CODE: 0

Output: (empty — zero entries)

## Verification

- Formatter exit code: **0**.
- Formatter produced a diff: **No**. Prettier reported `(unchanged)` for all 316 processed files, and
  the subsequent `git status --porcelain -- extensions/drm-copilot` returned zero entries, confirming
  no file under `extensions/drm-copilot` was modified by the write-mode formatter.
- No forbidden file was modified by the write-mode invocation.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run format` exits 0 and modified no file;
`git status --porcelain -- extensions/drm-copilot` is empty afterwards. The extension package is
Prettier-clean at baseline, establishing the reference state for the [P4-T5] before/after comparison.
