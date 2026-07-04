# Phase 9 — Coverage Delta / Threshold Verification (F10)

Timestamp: 2026-06-26T12-20

## Baseline (from f10-test-coverage-baseline.md, 2026-06-26T11-29)

- src/lib (measured, collectCoverageFrom=src/lib/**/*.ts): line 96.45%, branch 88.07%
- No `src/lib/codex-native-converter/**` files existed at baseline.

## Post-change (from f10-final-test-coverage.md, 2026-06-26T12-20)

- src/lib (measured, collectCoverageFrom=src/lib/**/*.ts): line 97.03%, branch 88.28%
- Test Suites: 115 passed; Tests: 1387 passed.

## Delta (overall src/lib)

- Line: 96.45% -> 97.03% (+0.58 pp; no regression).
- Branch: 88.07% -> 88.28% (+0.21 pp; no regression).

## New-code coverage (src/lib/codex-native-converter/**)

All new files meet line >= 85% and branch >= 75%. Aggregate for the new
directory: line 98.87%, branch 89.06% (from the directory-scoped coverage run).
The minimum per-file branch is pipeline-render.ts at 79.54%; the minimum per-file
line is pipeline-traces.ts at 93.44%. Per-file numbers are recorded in
`f10-final-test-coverage.md`.

## Outcome

PASS. No regression on overall src/lib line/branch coverage versus the F10
baseline, and every new codex-native-converter file meets the line >= 85% /
branch >= 75% thresholds.

Note (evidence-path deviation): named `f10-coverage-delta.md` to avoid
overwriting the existing `coverage-delta.md` (F9) in the shared qa-gates folder;
remains under the canonical `<FEATURE>/evidence/qa-gates/` location.
