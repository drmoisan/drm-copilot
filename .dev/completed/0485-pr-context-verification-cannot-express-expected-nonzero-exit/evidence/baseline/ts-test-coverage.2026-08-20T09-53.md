# Baseline — TypeScript coverage (Jest)

Timestamp: 2026-08-20T09-53

Task: [P0-T15]

Command: (from `extensions/drm-copilot`) npm run test:coverage -- --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov
EXIT_CODE: 0

## Why the added `text` reporter is load-bearing

`extensions/drm-copilot/package.json:212` defines `test:coverage` as
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, and
`extensions/drm-copilot/jest.config.cjs:18` sets `coverageReporters: ["lcov", "text-summary"]`.
`text-summary` prints only the four overall totals and no per-file rows, so the per-file figures this
task must record are unobtainable without appending `--coverageReporters=text`.

## Overall coverage (text-summary block)

```
Statements   : 96.61% ( 41750/43212 )
Branches     : 89.96% ( 5902/6560 )
Functions    : 90.11% ( 1221/1355 )
Lines        : 96.61% ( 41750/43212 )
```

- Overall LINE coverage: 96.61% (41750/43212)
- Overall BRANCH coverage: 89.96% (5902/6560)

Both are above the policy thresholds (line >= 85%, branch >= 75%).

## Per-file coverage of the two TypeScript files this change touches

Read from the `text` table (the `% Stmts` / `% Branch` / `% Lines` columns for the
`src/lib/pr-context` group):

| File | Lines | Branch | Uncovered lines |
| --- | --- | --- | --- |
| `src/lib/pr-context/verification-evidence.ts` | 95.56% | 80.00% | 106-107, 215-216, 226-227, 237-238, 243, 245-246 |
| `src/lib/pr-context/collector-output.ts` | 97.55% | 80.51% | 112, 248-251, 295-298, 369-370 |

Source used for the per-file figures: the `text` reporter table from this same run (not the LCOV
file). The directory row for reference: `src/lib/pr-context` at 93.86% lines and 87.59% branches.

## Test outcome in the same run

```
Test Suites: 185 passed, 185 total
Tests:       2558 passed, 2558 total
```

Output Summary: Jest coverage passes at baseline with exit code 0. Overall line coverage 96.61%
(41750/43212) and overall branch coverage 89.96% (5902/6560). Per-file baseline from the `text`
table: `src/lib/pr-context/verification-evidence.ts` lines 95.56% / branches 80.00% (uncovered
106-107, 215-216, 226-227, 237-238, 243, 245-246); `src/lib/pr-context/collector-output.ts` lines
97.55% / branches 80.51% (uncovered 112, 248-251, 295-298, 369-370). 185 of 185 suites and 2558 of
2558 tests passed. All required numeric values are present; no placeholder is used.
