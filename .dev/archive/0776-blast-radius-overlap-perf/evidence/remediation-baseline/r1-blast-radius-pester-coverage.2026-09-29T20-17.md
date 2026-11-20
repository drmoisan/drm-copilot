# Pre-Remediation Blast-Radius Pester Run with Coverage (remediation plan P0-T10)

Timestamp: 2026-09-29T20-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1,.claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/r1-baseline-blast-coverage.xml
EXIT_CODE: 0
Output Summary:
- Run in the background on the pre-remediation tree; exit 0.
- TotalCount=594
- PassedCount=593
- FailedCount=0
- Skipped: 1 (Pester summary: "Tests Passed: 593, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 0"; "Tests completed in 105.68s"). The skipped test is the pre-existing conditional skip recorded in the ORIGINAL-BASELINE P0-T11 artifact.
- TotalCount 594 equals the ORIGINAL-BASELINE P0-T11 TotalCount (561) plus 33. R1-BLAST-TOTAL = 594.
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 AnalyzedLines=77 CoveredLines=77 LinePercent=100
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 AnalyzedLines=66 CoveredLines=65 LinePercent=98.48
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=118 CoveredLines=118 LinePercent=100
- Result: PASS. P1-T8 and P2-T3 expect TotalCount = 594 + 17 = 611.
