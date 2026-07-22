Timestamp: 2026-07-21T21-11

# PoshQC.ScanConfig.psm1 Non-Regression Check (issue #344 protection, P2-T4)

## Before / after LINE counts

| State | Source | Covered | Missed | Total | Percentage |
|---|---|---|---|---|---|
| Pre-fix (revision-2 baseline) | P0-T5 (remediation2-coverage-baseline) | 44 | 2 | 46 | 95.65% |
| Post-fix (full bundled) | P2-T1 (remediation2-bundled-full-run) | 44 | 2 | 46 | 95.65% |
| Candidate A experiment (narrowed) | P0-T7 (e-c-candidate-parse-cache) | 44 | 2 | 46 | 95.65% |

Post-fix uncovered lines for PoshQC.ScanConfig.psm1: 47, 79 (2 lines).

## Confirmation

No previously-covered line in PoshQC.ScanConfig.psm1 is now uncovered. The covered/missed/total
counts are byte-for-byte identical before and after the fix (44 covered, 2 missed, 46 total in
both states). The two uncovered lines (47, 79) are genuinely-unreached lines that were uncovered
in the pre-fix state as well; the count identity (2 missed in both states) precludes a masked
one-for-one swap because the Candidate A change only removes repeated fresh AST parse/compile
churn — it can preserve or improve coverage credit but cannot cause a line to lose credit, since
the mechanism it eliminates is the one that was DESTROYING credit. The issue #344 breakpoint-binding
requirement (PoshQC.ScanConfig.psm1 must remain inside the coverage denominator with breakpoints
bound to its source file) is preserved: the file is measured at 44/46 = 95.65%, unchanged.

No regression found. Progression to Phase 3 is authorized.
