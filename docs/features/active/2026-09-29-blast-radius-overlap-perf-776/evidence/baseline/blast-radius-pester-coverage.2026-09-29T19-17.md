# Baseline Blast-Radius Pester Run with Coverage (P0-T11)

Timestamp: 2026-09-29T19-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1 -CoverageOutputPath SCRATCH/baseline-blast-coverage.xml
EXIT_CODE: 0
Output Summary:
- TotalCount=561
- PassedCount=560
- FailedCount=0
- Skipped: 1 (Pester summary: "Tests Passed: 560, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 0"; "Tests completed in 452.6s"). The skipped test is "keeps a scheduling edge for every must-conflict case at the strictest tolerance", skipped by its own conditional on the Issue #722 tolerance-layer detection. The skip is pre-existing and is not related to this change.
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 AnalyzedLines=70 CoveredLines=70 LinePercent=100
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 AnalyzedLines=43 CoveredLines=42 LinePercent=97.67
- Result: PASS (exit 0, FailedCount=0). Baseline is green. P1-T10 and P2-T3 expect TotalCount = 561 + 33 = 594.
