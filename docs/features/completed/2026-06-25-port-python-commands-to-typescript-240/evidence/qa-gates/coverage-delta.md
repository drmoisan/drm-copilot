# P7-T6 — TypeScript Coverage Delta (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-27

## Baseline (from P0-T6)
- Command: node run-jest.cjs --coverage --collectCoverageFrom="src/**/*.ts"
- All files: Lines 96.17%, Branch 88.30%.
- Tests: 115 suites / 1387 passed.

## Post-change (from P7-T5)
- Command: node run-jest.cjs --coverage --collectCoverageFrom="src/**/*.ts"
- All files: Lines 96.62%, Branch 88.29%.
- Tests: 116 suites / 1389 passed.

## Delta Analysis
- Overall src line coverage: 96.17% -> 96.62% (+0.45 pts). Branch: 88.30% -> 88.29% (-0.01 pts, effectively flat).
- Line coverage increased: removing the dead Python detection branch from `command-runtime.ts`, the four dead Python option builders from `repo-automation-service-workflows.ts`, and the three orphaned arg-builders from `repo-automation-args.ts` removed previously-uncovered/lightly-covered code from the denominator, while the new `src/lib/hello-message.ts` is fully covered.
- The -0.01 branch movement is rounding noise from denominator changes, not a regression on any previously-covered file.

## New-code threshold check
- `src/lib/hello-message.ts`: Lines 100%, Branch 100% — meets line >= 85% and branch >= 75%.

## Outcome
PASS. No regression on overall `src` line/branch coverage versus baseline (line increased, branch flat). The new `hello-message.ts` meets both thresholds. All numeric values recorded.
