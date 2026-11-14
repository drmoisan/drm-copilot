# TypeScript Final-QC Static - Remediation Cycle 2 (P2-T1)

Timestamp: 2026-11-13T17-11
Command: sh SCRATCH/issue-1157-c2-static.sh final
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: root format:check exit 1 with exactly the three P0-T3 fixtures (no new finding); extension Prettier "All matched files use Prettier code style!"; root and extension lint and typecheck exit 0 with finding count 0.

The first recorded exit code is that of root `format:check` (1, the baseline-recorded state); every other step exits 0.

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Root format check | `npm --prefix <worktree root> run format:check` | 1 | 3 (equal to the P0-T3 set) |
| Root lint | `npm --prefix <worktree root> run lint` | 0 | 0 |
| Root typecheck | `npm --prefix <worktree root> run typecheck` | 0 | 0 |
| Extension Prettier check | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `<worktree root>/extensions/drm-copilot` | 0 | 0 |
| Extension lint | `npm run lint` in `<worktree root>/extensions/drm-copilot` | 0 | 0 |
| Extension typecheck | `npm run typecheck` in `<worktree root>/extensions/drm-copilot` | 0 | 0 |

## Root format:check reported files

- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json`

Identical to the P0-T3 set in `evidence/remediation-baseline/typescript-static.2026-11-13T16-55.md`; no new finding.

## Extension Prettier check output

`All matched files use Prettier code style!`
