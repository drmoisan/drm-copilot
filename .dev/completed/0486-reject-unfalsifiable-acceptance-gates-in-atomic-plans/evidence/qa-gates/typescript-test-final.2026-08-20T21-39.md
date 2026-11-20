# Final QC — Full TypeScript Suite in Coverage Mode (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P4-T8]
Working directory: `extensions/drm-copilot`

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

EXIT_CODE: 0

Raw output:

```
=============================== Coverage summary ===============================
Statements   : 96.65% ( 42960/44447 )
Branches     : 90% ( 6099/6776 )
Functions    : 89.65% ( 1257/1402 )
Lines        : 96.65% ( 42960/44447 )
================================================================================

Test Suites: 193 passed, 193 total
Tests:       2645 passed, 2645 total
Snapshots:   0 total
Time:        7.444 s
Ran all test suites.
```

## Per-module figures, read from `extensions/drm-copilot/coverage/lcov.info`

| Module | LF | LH | Line % | BRF | BRH | Branch % |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-rules.ts` | 437 | 427 | **97.71%** | 67 | 60 | **89.55%** |
| `src/lib/validate/plan-gate-discrimination.ts` | 269 | 269 | **100.00%** | 48 | 47 | **97.92%** |

## Threshold and baseline verdicts

| Module | Metric | Required | Observed | [P0-T4] baseline | Equal to baseline | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| `plan-gate-rules.ts` | Line | >= 85% | 97.71% | 97.71% | yes | PASS |
| `plan-gate-rules.ts` | Branch | >= 75% | 89.55% | 89.55% | yes | PASS |
| `plan-gate-discrimination.ts` | Line | >= 85% | 100.00% | 100.00% | yes | PASS |
| `plan-gate-discrimination.ts` | Branch | >= 75% | 97.92% | 97.92% | yes | PASS |

Output Summary: **193 of 193 suites and 2645 of 2645 tests passed, 0 failed.** Every per-module line
percentage is at or above 85 and every per-module branch percentage is at or above 75. All four
per-module values equal their [P0-T4] baseline exactly (identical `LF`/`LH`/`BRF`/`BRH` counters),
as required, because no TypeScript file was modified this cycle. Repo-wide TypeScript coverage is
also unchanged from baseline at 96.65% statements / 90% branches / 96.65% lines over the same
42960/44447 and 6099/6776 counters. No `coverageThreshold` entry was weakened and no coverage
`exclude` was added for any production path.
