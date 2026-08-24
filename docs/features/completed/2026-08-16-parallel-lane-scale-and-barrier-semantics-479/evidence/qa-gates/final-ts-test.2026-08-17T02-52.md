# Final TypeScript Tests with Coverage (Issue #479, [P7-T8])

Timestamp: 2026-08-17T02-52

Command: `npm run test:coverage` (cwd `extensions/drm-copilot`; resolves to
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)

EXIT_CODE: 0

## Output Summary

### Test counts

`Test Suites: 185 passed, 185 total` / `Tests: 2555 passed, 2555 total` / `Snapshots: 0 total`.

Baseline was 2552 passing. Net +3: the three new `it.each([1, 4, 32])` in-range accept cases in
`parallel-planner-state-core.test.ts`, which had no in-range accept case before this change.
Zero failures.

### Numeric text-summary totals

| Metric | Value | Baseline | Threshold | Result |
|---|---|---|---|---|
| Statements | **96.61%** (41738/43200) | 96.61% (41738/43200) | — | unchanged |
| Branches | **89.96%** (5901/6559) | 89.96% (5901/6559) | >= 75% | PASS, unchanged |
| Functions | **90.11%** (1221/1355) | 90.11% (1221/1355) | — | unchanged |
| Lines | **96.61%** (41738/43200) | 96.61% (41738/43200) | >= 85% | PASS, unchanged |

Totals are byte-identical to baseline, which is expected: the only production TypeScript change
is a one-line constant in each of two files, and both lines were already covered.

### Per-file values from `extensions/drm-copilot/coverage/lcov.info`

The `test:coverage` script's reporters are `lcov` and `text-summary`, so per-file values are
read from each lcov record (`LH/LF` for lines, `BRH/BRF` for branches).

| File | Lines | Branches | Baseline line | Baseline branch |
|---|---|---|---|---|
| `src/lib/validate/parallel-orchestrator-state-core.ts` | **99.38%** (320/322) | **92.11%** (35/38) | 99.38% | 92.11% |
| `src/lib/validate/parallel-planner-state-core.ts` | **100.00%** (453/453) | **97.96%** (48/49) | 100.00% | 97.96% |

Both changed files are unchanged against baseline and both exceed the uniform thresholds
(line >= 85%, branch >= 75%).
