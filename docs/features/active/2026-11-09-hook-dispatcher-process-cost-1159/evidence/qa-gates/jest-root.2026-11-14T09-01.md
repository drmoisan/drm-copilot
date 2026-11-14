# Remediation cycle 2 — final root Jest gate ([P1-T6])

Timestamp: 2026-11-14T09-01
Command: sh SCRATCH/issue-1159-jest-root.sh (from the worktree root: npm run test:unit:coverage, i.e. node run-jest.cjs --coverage, normal parallel workers)
EXIT_CODE: 0
Output Summary: Test Suites: 346 passed, 346 total. Tests: 5574 passed, 5574 total (0 failed). Repo-wide coverage ("All files" row, v8): statements 98.29%, branches 93.68%, functions 92.29%, lines 98.29%. coverage/lcov.info written by this run.

## Comparison with the Phase 0 baseline (jest-root.2026-11-14T08-48.md)

| Measure | Baseline | Final | Change |
|---|---|---|---|
| Suites | 345 (1 failed) | 346 (0 failed) | +1 suite (real-bundle-filesystem.test-helpers.test.ts) |
| Tests | 5571 (1 failed) | 5574 (0 failed) | +3 tests, failure fixed |
| Lines | 98.29% | 98.29% | no drop |
| Branches | 93.67% | 93.68% | no drop |

"publishes every registered hook and its dot-source closure in typescript pack mode" passes (failing at the baseline with Expected > 21, Received 10). The three [P1-T3] cases ("returns every PreToolUse hook path named by a registry command", "skips a registry hook whose command names no .codex/hooks script", "returns no path for a registry without PreToolUse groups") pass; the run reports no failing test.
