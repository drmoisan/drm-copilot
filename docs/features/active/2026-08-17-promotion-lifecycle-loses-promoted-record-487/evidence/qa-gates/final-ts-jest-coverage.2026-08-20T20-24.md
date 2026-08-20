# Final QC — TypeScript Tests and Coverage (Jest) [P7-T5]

Timestamp: 2026-08-20T20-24

Command: `npm run test:coverage`

Underlying command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b/extensions/drm-copilot`

EXIT_CODE: 0

Loop iteration: TypeScript loop iteration 2. This is the final stage of the TypeScript loop; all four executed stages of iteration 2 (format, lint, type-check, architecture, test) completed without a failure or a file rewrite, so iteration 2 is a single consecutive clean pass.

Wrapper note: `npm run test:coverage` invokes the repo-sanctioned `run-jest.cjs` wrapper, which supplies `--config jest.config.cjs` and enforces the issue-#423 prohibited-flag guard. A bare `npx jest` invocation bypasses both and was not used. The exit code was captured directly from the command process with no pipe.

## Raw Output (tail)

```
> drm-copilot@1.0.26 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.66% ( 43055/44542 )
Branches     : 90.04% ( 6122/6799 )
Functions    : 89.67% ( 1259/1404 )
Lines        : 96.66% ( 43055/44542 )
================================================================================

Test Suites: 195 passed, 195 total
Tests:       2654 passed, 2654 total
Snapshots:   0 total
Time:        8.488 s
Ran all test suites.
```

## Output Summary

**PASS, exit code 0 as required.**

Suite counts: **195 test suites passed, 195 total; 2654 tests passed, 2654 total; 0 failed; 0 snapshots.**

Numeric `text-summary` headline percentages:

| Metric | Post-change | Covered / Total |
| --- | --- | --- |
| Statements | **96.66%** | 43055 / 44542 |
| Branches | **90.04%** | 6122 / 6799 |
| Functions | **89.67%** | 1259 / 1404 |
| Lines | **96.66%** | 43055 / 44542 |

Both uniform thresholds are met: line 96.66% >= 85% and branch 90.04% >= 75%.

## Comparison with Baseline

| Metric | Baseline (P0-T15) | Post-change (P7-T5) | Delta |
| --- | --- | --- | --- |
| Test suites | 193 | 195 | +2 |
| Tests | 2645 | 2654 | +9 |
| Statements | 96.65% | 96.66% | +0.01 pp |
| Branches | 90% | 90.04% | +0.04 pp |
| Functions | 89.65% | 89.67% | +0.02 pp |
| Lines | 96.65% | 96.66% | +0.01 pp |

Every metric moved up or held. The +2 suites are `flow.promoted-disposition.test.ts` and `promotion-lifecycle-sequence.test.ts`; the +9 tests are the three cases in the first, the one case in the second, the three cases added to `new-active-feature-folder-service-call.test.ts`, and the two cases added to `potential-to-issue-service-call.test.ts`. The full delta analysis, including per-file and changed-line figures derived from `extensions/drm-copilot/coverage/lcov.info`, is recorded at P7-T11.

The `lcov` reporter wrote `extensions/drm-copilot/coverage/lcov.info`, which is the per-file source P7-T11 consumes; `text-summary` reports global totals only and is not sufficient for the per-file requirement.
