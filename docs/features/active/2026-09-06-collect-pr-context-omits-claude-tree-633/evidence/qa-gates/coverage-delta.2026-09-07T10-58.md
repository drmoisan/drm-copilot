Timestamp: 2026-09-07T10-58

Source: P0-T11 baseline (evidence/baseline/lcov-per-file-baseline.2026-09-07T10-58.md)
        vs P5-T1 post-change (evidence/qa-gates/lcov-per-file-post-change.2026-09-07T10-58.md)

## collector-core.ts
- Baseline:    Lines 97.67% (461/472)  | Branches 86.57% (58/67)
- Post-change: Lines 97.89% (465/475)  | Branches 89.71% (61/68)
- Delta:       Lines +0.22pp           | Branches +3.14pp
- Threshold check: Lines >= 85 -> PASS (97.89%). Branches >= 75 -> PASS (89.71%).
- Verdict: PASS (no threshold previously applied; now gated and satisfied)

## collector-output.ts
- Baseline:    Lines 97.73% (474/485)  | Branches 82.28% (65/79)
- Post-change: Lines 97.73% (474/485)  | Branches 82.28% (65/79)
- Delta:       Lines 0.00pp            | Branches 0.00pp
- Verdict: PASS (no regression)

## summary-helpers.ts
- Baseline:    Lines 93.56% (363/388)  | Branches 87.84% (65/74)
- Post-change: Lines 93.56% (363/388)  | Branches 87.84% (65/74)
- Delta:       Lines 0.00pp            | Branches 0.00pp
- Verdict: PASS (no regression)

## Overall Verdict
All three files pass their required check: collector-core.ts newly reaches and exceeds
the 85%-lines / 75%-branches gate added in P3-T1; collector-output.ts and
summary-helpers.ts show zero regression relative to the P0-T11 baseline. This is the
AC8 evidence.
