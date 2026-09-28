# Final QA — coverage delta for pr-context models.ts

Timestamp: 2026-09-27T05-58
Baseline source: evidence/baseline/jest-coverage.2026-09-27T05-53.md (P0-T6)
Final source: evidence/qa-gates/jest-coverage-final.2026-09-27T05-58.md (P4-T7)

| Metric | Baseline | Final | Final >= Baseline | Threshold | Final meets threshold |
|---|---|---|---|---|---|
| % Lines (`src/lib/pr-context/models.ts`) | 100 | 100 | yes | >= 85 | yes |
| % Branch (`src/lib/pr-context/models.ts`) | 100 | 100 | yes | >= 75 | yes |

Statement: final >= baseline for both Lines (100 >= 100) and Branch (100 >= 100), and both final values meet the thresholds (100 >= 85, 100 >= 75). There is no coverage regression on the changed lines. The added `compareCodePoint` function in `models.ts` is fully covered: the `models.ts` row reports no uncovered lines.

Supplementary (not an acceptance input): the `src/lib/pr-context` group row moved from Lines 94.47 / Branch 89.69 to Lines 94.91 / Branch 90.53 after the eight duplicate copies were removed.
