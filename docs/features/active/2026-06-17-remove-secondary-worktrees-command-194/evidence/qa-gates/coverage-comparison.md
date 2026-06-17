# Coverage Delta Comparison (Issue #194)

Timestamp: 2026-06-17T16-57

## Package-Level Coverage (All files)

| Metric | Baseline ([P0-T5]) | Post-change ([P5-T6]) | Threshold | Delta |
|---|---|---|---|---|
| Line | 95.54% | 95.65% | >= 85% | +0.11 |
| Branch | 87.14% | 87.04% | >= 75% | -0.10 |
| Statements | 95.54% | 95.65% | n/a | +0.11 |
| Functions | 95.90% | 96.03% | n/a | +0.13 |

Both line and branch coverage remain well above the repository thresholds
(line >= 85%, branch >= 75%). The package branch coverage moved by -0.10 percentage
points, which is within normal denominator variation from adding new branch-bearing
code; it is not a regression on the changed lines (see below).

## New / Changed-Code Coverage

| File | Line | Branch | Func | Uncovered |
|---|---|---|---|---|
| src/remove-worktrees.ts (new) | 98.42% | 90.32% | 100% | 103-105 (malformed-block guard) |
| src/remove-worktrees-runner.ts (new) | 100% | 85% | 100% | default-branch fallbacks at 69, 113, 148 |
| src/extension.ts (modified) | 96.82% | 86.84% | 100% | 233-239, 274-275, 281-282 |

## No-Regression on Changed Lines

- The newly added modules are covered at 98.42% / 100% line coverage.
- The new command-registration block in `extension.ts` is exercised by the
  registration, confirmation-cancellation, and error-path tests in
  `test/extension.test.ts`. The uncovered lines in `extension.ts` (233-239,
  274-275, 281-282) belong to pre-existing handlers and subscription wiring,
  not to the lines changed for this feature; the changed lines are covered.

## Outcome

PASS — package and new-module coverage satisfy line >= 85% and branch >= 75%,
and there is no coverage regression on the lines changed by this feature.
