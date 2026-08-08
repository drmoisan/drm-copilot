# Final QC — TypeScript Coverage-Enabled Test (P7-T8)

Timestamp: 2026-08-07T20-17

Command: `npm run test:coverage`

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e\extensions\drm-copilot`

Underlying command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary: 177 test suites passed of 177 total; 2363 tests passed of 2363 total; 0 failed,
0 skipped, 0 snapshots; completed in 5.79 seconds. Post-change LINE coverage: **96.49%**
(39,833 of 41,279 lines). Post-change BRANCH coverage: **89.75%** (5,582 of 6,219 branches).
Statements 96.49% (39,833/41,279); Functions 89.95% (1,155/1,284). Both headline figures satisfy the
uniform repository thresholds (line >= 85%, branch >= 75%) and both are above the P0-T9 baseline
(line 96.34%, branch 89.27%). All configured per-file `coverageThreshold` gates in
`extensions/drm-copilot/jest.config.cjs` passed, including the four entries added by P5-T5 for
`parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-orchestrator-state-core.ts`, and
`parallel-planner-state-core.ts` (`lines: 85`, `branches: 75` each); a threshold breach would have
produced a non-zero exit code.

## Precise Coverage Totals

| Metric | Percentage | Covered / Total |
| --- | --- | --- |
| Line coverage | 96.49% | 39833 / 41279 |
| Branch coverage | 89.75% | 5582 / 6219 |
| Statement coverage | 96.49% | 39833 / 41279 |
| Function coverage | 89.95% | 1155 / 1284 |

Threshold check against `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`:
line 96.49% >= 85% (PASS); branch 89.75% >= 75% (PASS).

## Suite and Test Deltas vs. Baseline

| Metric | Baseline (P0-T9) | Post-change (P7-T8) | Delta |
| --- | --- | --- | --- |
| Test suites | 169 | 177 | +8 |
| Tests | 2061 | 2363 | +302 |

The +8 suites are exactly the eight new TypeScript test files delivered by Phases 4 and 5. The
non-suite support module `test/lib/validate/parallel-state-test-support.ts` is correctly not collected
by `testMatch` and adds no suite, as required by P4-T5.

## Raw Output

```
> drm-copilot@1.0.21 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.49% ( 39833/41279 )
Branches     : 89.75% ( 5582/6219 )
Functions    : 89.95% ( 1155/1284 )
Lines        : 96.49% ( 39833/41279 )
================================================================================

Test Suites: 177 passed, 177 total
Tests:       2363 passed, 2363 total
Snapshots:   0 total
Time:        5.79 s
Ran all test suites.
```

## Per-New-Module Derivation

The `text-summary` reporter emits aggregate totals only. Per-new-module TypeScript line and branch
percentages are derived from `extensions/drm-copilot/coverage/lcov.info`, written by the configured
`lcov` reporter during this run, and are recorded in
`evidence/qa-gates/coverage-delta.2026-08-07T20-30.md` (P7-T9).

## Loop Status

TypeScript final-QC stages 1-4 (`npm run format`, `npm run lint`, `npm run typecheck`,
`npm run test:coverage`) all completed with exit code 0 in a single pass with zero file mutations.
The TypeScript loop does not restart.
