# TypeScript Coverage-Enabled Test Baseline — [P0-T9]

Timestamp: 2026-08-07T18-08

Feature: 2026-08-07-parallel-schema-validators-444 (issue #444)
Task: [P0-T9]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e\extensions\drm-copilot`
Branch: `feature/parallel-schema-validators-444`
State captured: PRE-CHANGE baseline

Command: `npm run test:coverage` (in `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary: 169 test suites passed of 169 total; 2061 tests passed of 2061 total; 0 failed,
0 skipped, 0 snapshots; completed in 7.85 seconds. Baseline LINE coverage: **96.34%**
(37,718 of 39,147 lines). Baseline BRANCH coverage: **89.27%** (5,220 of 5,847 branches). Statements
96.34% (37,718/39,147); Functions 89.51% (1,101/1,230). All configured per-file `coverageThreshold`
gates in `extensions/drm-copilot/jest.config.cjs` passed, as evidenced by the zero exit code. Both
headline figures satisfy the uniform repository thresholds (line >= 85%, branch >= 75%). No
pre-existing TypeScript test failure was observed. The missing worktree `node_modules` that blocked
[P0-T7] did not block this command; Jest resolved from the ancestor repo-root install.

## Precise Coverage Totals

| Metric | Percentage | Covered / Total |
| --- | --- | --- |
| Line coverage | 96.34% | 37718 / 39147 |
| Branch coverage | 89.27% | 5220 / 5847 |
| Statement coverage | 96.34% | 37718 / 39147 |
| Function coverage | 89.51% | 1101 / 1230 |

Threshold check against `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`:
line 96.34% >= 85% (PASS); branch 89.27% >= 75% (PASS).

## Raw Output

```
> drm-copilot@1.0.21 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.34% ( 37718/39147 )
Branches     : 89.27% ( 5220/5847 )
Functions    : 89.51% ( 1101/1230 )
Lines        : 96.34% ( 37718/39147 )
================================================================================

Test Suites: 169 passed, 169 total
Tests:       2061 passed, 2061 total
Snapshots:   0 total
Time:        7.85 s
Ran all test suites.
```

## Known-Baseline Conditions

- The `text-summary` reporter emits aggregate totals only. Per-new-module TypeScript percentages
  required by [P7-T9] must be derived from `extensions/drm-copilot/coverage/lcov.info`, which the
  configured `lcov` reporter writes on every run. This is already anticipated by the [P7-T9] task text.
- No pre-existing TypeScript test failure exists on this branch. Any Jest failure observed in a later
  phase is attributable to this feature's changes.
