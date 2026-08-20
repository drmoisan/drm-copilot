# TypeScript Coverage Baseline — Remediation Cycle 2 ([P0-T3])

Timestamp: 2026-08-20T16-38

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

Working directory: `extensions/drm-copilot`

EXIT_CODE: 0

Output Summary:

- Test Suites: 193 passed, 193 total. Tests: 2645 passed, 2645 total. 0 failed.
- Repository-wide coverage summary:

```
Statements   : 96.65% ( 42960/44447 )
Branches     : 90% ( 6099/6776 )
Functions    : 89.65% ( 1257/1402 )
Lines        : 96.65% ( 42960/44447 )
```

- Per-file figures for the two TypeScript gate modules, read from `extensions/drm-copilot/coverage/lcov.info`:

| File | LH/LF | Line % | BRH/BRF | Branch % |
| --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-rules.ts` | 427/437 | **97.712%** | 60/67 | **89.552%** |
| `src/lib/validate/plan-gate-discrimination.ts` | 269/269 | **100.000%** | 47/48 | **97.917%** |

- No TypeScript production file is modified during this cycle, so [P4-T8] must reproduce both rows unchanged. Any deviation is a regression to investigate, not an expected result.
