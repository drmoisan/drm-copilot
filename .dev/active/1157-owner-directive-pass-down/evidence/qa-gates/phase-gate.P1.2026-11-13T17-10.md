# Phase Gate - Phase 1 (P1-T6, cycle 2)

Timestamp: 2026-11-13T17-01
Command: sh SCRATCH/issue-1157-c2-static.sh gate1; sh SCRATCH/issue-1157-c2-jest.sh gate1-root root; sh SCRATCH/issue-1157-c2-jest.sh gate1-ext ext
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: one clean pass judged by `## Baseline-Dependent Acceptance`: root format:check exit 1 with exactly the three P0-T3 fixtures; extension Prettier "All matched files use Prettier code style!"; root and extension lint and typecheck exit 0, 0 findings; root Jest 343/343 suites, 5493/5493 tests; extension Jest 340/340 suites, 5476/5476 tests; no restart needed.

The first recorded exit code is that of root `format:check` (1, the baseline-recorded state); every other stage exits 0.

## Stages

| Stage | Command | EXIT_CODE | Findings / failures |
|---|---|---|---|
| 1 Format (root) | `npm --prefix <worktree root> run format:check` | 1 | 3 files, equal to the P0-T3 set (below) |
| 1 Format (extension) | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `<worktree root>/extensions/drm-copilot` | 0 | 0; printed `All matched files use Prettier code style!` |
| 2 Lint (root) | `npm --prefix <worktree root> run lint` | 0 | 0 |
| 2 Lint (extension) | `npm run lint` in `<worktree root>/extensions/drm-copilot` | 0 | 0 |
| 3 Type check (root) | `npm --prefix <worktree root> run typecheck` | 0 | 0 |
| 3 Type check (extension) | `npm run typecheck` in `<worktree root>/extensions/drm-copilot` | 0 | 0 |
| 4 Architecture boundary | not applicable | n/a | no architecture-boundary tool is configured for these manifests |
| 5 Unit (root Jest) | `npm --prefix <worktree root> run test:unit` | 0 | Test Suites: 343 passed, 343 total; Tests: 5493 passed, 5493 total; 0 failed (P0-T4 record `none`) |
| 5 Unit (extension Jest) | `npm --prefix <worktree root>/extensions/drm-copilot run test` | 0 | Test Suites: 340 passed, 340 total; Tests: 5476 passed, 5476 total; 0 failed (P0-T5 record `none`) |
| 6 Contract checks | not applicable | n/a | no contract check reads a lockfile (plan `## Changed Behavior and Asserting Tests`) |

Root `format:check` reported files (identical to the P0-T3 set):

- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json`
- `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json`

The two Jest runs ran one after the other through Jest's normal parallel workers (OD-5). No stage failed or auto-fixed a file, so no restart was needed.
