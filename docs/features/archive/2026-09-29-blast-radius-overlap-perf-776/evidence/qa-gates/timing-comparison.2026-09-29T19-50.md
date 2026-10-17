# Timing Comparison for AC-2 (P2-T6): FAIL, Remediation Required

Timestamp: 2026-09-29T19-50
Command: awk 'BEGIN { printf "RATIO=%.2f\n", 213.12 / 82.05 }'
EXIT_CODE: 0
Output Summary:
- Test file: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (coverage disabled, Pester 5.6.1, same host).
- Baseline median (P0-T10): 213.12 s (runs 214.04, 213.12, 213.02).
- Post-change median (P2-T5): 82.05 s (runs 82.05, 82.86, 69.8).
- RATIO=2.60
- Threshold (D2): at least 4.00.
- Verdict: FAIL. Per the plan, this stops execution as remediation-required. No remediation was improvised.
- Measured reduction: 131.07 s per file run (61.5%). The D2 threshold required a post-change median of at most 53.28 s.

Stop reason and likely cause (inferred from code inspection, not profiled):

- D1 left the scheduling cost loop in `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` (`Get-BlastRadiusPairCost`, line 269) calling the exported advanced function `Test-EntryOverlap` once per entry pair. The loop also calls the advanced function `Get-PathPairWeight` once per overlapping pair. That function in turn calls `Test-GlobEntry` through `Where-Object` and `Test-MergeablePath` (lines 203 and 206).
- P1-T4 made the body of `Test-EntryOverlap` cheaper. It does not remove the per-call advanced-function parameter binding, which D2's rationale identified as the dominant per-pair cost. D2 estimated that about 90 of about 200 full pairwise passes in the slowest test run through this unchanged loop.
- The record-form rewrite of `Get-SmallestPathOverlap` therefore removed only the portion of the cost on the detection path. The remaining 82 s is most likely dominated by the scheduling cost loop. This attribution is an inference from the code structure and the D2 rationale; no profiler was run.
- Remediation options (for the planner; none were applied):
  - (a) Apply the record-form inline decision to the scheduling cost loop. BlastRadiusScheduling.psm1 is out of scope under the current plan, and at 486 lines it has little headroom under the 500-line limit.
  - (b) Revise the D2 threshold with the measured evidence.
  - (c) Profile the historical-runs test to confirm the attribution before choosing.

Plan tasks P2-T7 through P2-T14 were not executed.
