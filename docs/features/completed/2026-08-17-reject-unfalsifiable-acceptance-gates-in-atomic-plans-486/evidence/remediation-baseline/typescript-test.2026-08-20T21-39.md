# TypeScript Coverage Baseline — Remediation Cycle 3 (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P0-T4]
Working directory: `extensions/drm-copilot`

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

EXIT_CODE: 0

Repo-wide coverage summary as reported:

```
Statements   : 96.65% ( 42960/44447 )
Branches     : 90% ( 6099/6776 )
Functions    : 89.65% ( 1257/1402 )
Lines        : 96.65% ( 42960/44447 )

Test Suites: 193 passed, 193 total
Tests:       2645 passed, 2645 total
Snapshots:   0 total
```

Per-file figures for the two gate modules, read from the `lcov` reporter output at
`extensions/drm-copilot/coverage/lcov.info`:

| Module | LF | LH | Line % | BRF | BRH | Branch % |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-rules.ts` | 437 | 427 | **97.71%** | 67 | 60 | **89.55%** |
| `src/lib/validate/plan-gate-discrimination.ts` | 269 | 269 | **100.00%** | 48 | 47 | **97.92%** |

Output Summary: **193 suites passed, 2645 tests passed, 0 failed.** Numeric per-module baselines are
`plan-gate-rules.ts` at 97.71% line / 89.55% branch and `plan-gate-discrimination.ts` at 100.00%
line / 97.92% branch. No TypeScript file is modified this cycle, so [P4-T8] must reproduce these
figures unchanged.
