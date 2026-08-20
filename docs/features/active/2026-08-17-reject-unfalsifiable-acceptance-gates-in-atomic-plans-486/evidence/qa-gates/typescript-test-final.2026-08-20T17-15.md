# TypeScript Suite With Coverage — Final QC ([P4-T8])

Timestamp: 2026-08-20T17-15

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

Working directory: `extensions/drm-copilot`

EXIT_CODE: 0

Output Summary:

- Test Suites: **193 passed, 193 total**. Tests: **2645 passed, 2645 total**. 0 failed.
- Repository-wide coverage summary, byte-identical to the [P0-T3] baseline:

```
Statements   : 96.65% ( 42960/44447 )
Branches     : 90% ( 6099/6776 )
Functions    : 89.65% ( 1257/1402 )
Lines        : 96.65% ( 42960/44447 )
```

- Per-file figures for the two TypeScript gate modules, read from
  `extensions/drm-copilot/coverage/lcov.info`:

| File | LH/LF | Line % | Baseline line % | BRH/BRF | Branch % | Baseline branch % |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-rules.ts` | 427/437 | **97.712%** | 97.712% | 60/67 | **89.552%** | 89.552% |
| `src/lib/validate/plan-gate-discrimination.ts` | 269/269 | **100.000%** | 100.000% | 47/48 | **97.917%** | 97.917% |

- Each line percentage is at or above 85 and each branch percentage at or above 75.
- Every value equals its [P0-T3] baseline exactly (delta 0.000 on all four figures), which is the
  expected result because no TypeScript production file was modified this cycle. `git diff
  --name-only extensions/drm-copilot/src` returned empty output in [P3-T1].
- No jest `coverageThreshold` entry was weakened and no coverage `exclude` was added.
