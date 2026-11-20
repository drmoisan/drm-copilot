# TypeScript Static Baseline - Remediation Cycle 2 (P0-T3)

Timestamp: 2026-11-13T16-55
Command: sh SCRATCH/issue-1157-c2-static.sh base
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: root format:check exit 1 on exactly the three inherited fixtures; extension Prettier check prints "All matched files use Prettier code style!"; root and extension lint and typecheck exit 0 with zero findings.

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Root format check | `npm --prefix <worktree root> run format:check` | 1 | 3 files |
| Root lint | `npm --prefix <worktree root> run lint` | 0 | 0 |
| Root typecheck | `npm --prefix <worktree root> run typecheck` | 0 | 0 |
| Extension Prettier check | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (in `<worktree root>/extensions/drm-copilot`) | 0 | 0 |
| Extension lint | `npm run lint` (in `<worktree root>/extensions/drm-copilot`) | 0 | 0 |
| Extension typecheck | `npm run typecheck` (in `<worktree root>/extensions/drm-copilot`; runs `tsc -p ./ --noEmit` and `typecheck:test`) | 0 | 0 |

## Root format:check reported files (the P0-T3 set)

- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json`

Prettier summary line: `Code style issues found in 3 files. Run Prettier with --write to fix.` The set equals the three fixtures of `## Baseline-Dependent Acceptance`, so the task proceeds.

## Extension Prettier check output

`All matched files use Prettier code style!`
