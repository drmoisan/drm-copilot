# Final TypeScript Coverage Gate (Remediation Cycle 2)

Timestamp: 2026-10-16T05-20
Task: [P5-T11]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary
EXIT_CODE: 0
Output Summary:

- `Test Suites: 271 passed, 271 total`; `Tests: 4023 passed, 4023 total` (baseline 4020; +3 new cases). 0 failed suites and tests.
- Coverage-threshold failure messages: none. No "Coverage data ... was not found" (U-2) line appeared in this run's output.
- text-summary totals: Statements 97.28% (51397/52832); Branches 92.33% (7601/8232); Functions 91.69% (1534/1673); Lines 97.28% (51397/52832). Baseline: 97.27% lines, 92.32% branches.
- Per-file values from `extensions/drm-copilot/coverage/coverage-summary.json`:

| File | Baseline lines.pct | Post lines.pct | Baseline branches.pct | Post branches.pct |
| --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-scratch.ts` | 100 (207/207) | 100 (226/226) | 100 (31/31) | 100 (31/31) |
| `src/lib/validate/plan-gate-commands.ts` | 95.94 (426/444) | 95.94 (426/444) | 85.39 (76/89) | 85.39 (76/89) |
| `src/lib/validate/plan-gate-rules.ts` | 97.71 (427/437) | 98.16 (429/437) | 89.55 (60/67) | 91.17 (62/68) |

`plan-gate-scratch.ts` is at 100% lines and 100% branches. The `plan-gate-commands.ts` and `plan-gate-rules.ts` figures are not lower than baseline. `plan-gate-rules.ts` is not changed by this branch; its figure rose because the new U-1 TypeScript case exercises it.

- Changed-line coverage from `extensions/drm-copilot/coverage/lcov.info`: every `+` line of `git diff -U0 2b2b1580d27dd77080b223e95f00dc9cc64b13b0 HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` was checked against the `DA:` records.
  - `plan-gate-scratch.ts`: lines 22-24, 68-83, 86, 90, 101, 107, and 179 all have hit counts of at least 1 (for example `DA:90,830`, `DA:107,250`, `DA:179,410`).
  - `plan-gate-commands.ts`: lines 268-270 have `DA:...,272`.
  - Zero-hit records on changed lines: none. Changed-line coverage is 100%.
