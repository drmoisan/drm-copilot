# Baseline — TypeScript Tests and Coverage (Jest) [P0-T15]

Timestamp: 2026-08-20T18-54

Command: `npm run test:coverage`

Underlying command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b/extensions/drm-copilot`

EXIT_CODE: 0

Wrapper note: `npm run test:coverage` invokes the repo-sanctioned `run-jest.cjs` wrapper, which supplies `--config jest.config.cjs` and enforces the issue-#423 prohibited-flag guard. A bare `npx jest` invocation bypasses both and was not used.

## Raw Output (tail)

```
> drm-copilot@1.0.26 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.65% ( 42960/44447 )
Branches     : 90% ( 6099/6776 )
Functions    : 89.65% ( 1257/1402 )
Lines        : 96.65% ( 42960/44447 )
================================================================================

Test Suites: 193 passed, 193 total
Tests:       2645 passed, 2645 total
Snapshots:   0 total
Time:        9.607 s
Ran all test suites.
```

Output Summary: **PASS.** Suite counts: **193 test suites passed, 193 total; 2645 tests passed, 2645 total; 0 failed; 0 snapshots.** Numeric `text-summary` headline percentages:

| Metric | Baseline | Covered / Total |
| --- | --- | --- |
| Statements | **96.65%** | 42960 / 44447 |
| Branches | **90%** | 6099 / 6776 |
| Functions | **89.65%** | 1257 / 1402 |
| Lines | **96.65%** | 42960 / 44447 |

Both uniform thresholds are met at baseline: line 96.65% >= 85% and branch 90% >= 75%. Exit code 0 was captured directly from the command process (no pipe). The `lcov` reporter wrote `extensions/drm-copilot/coverage/lcov.info`, which is the per-file source P7-T11 uses for the changed-line figures; `text-summary` reports global totals only and is not sufficient for the per-file requirement.
