# Line Counts at Baseline (Remediation Cycle 1, P0-T8)

Timestamp: 2026-09-27T19-35
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
EXIT_CODE: 0

## Output (verbatim)

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=490
.claude/lib/blast-radius/BlastRadius.psm1 LineCount=475
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 LineCount=359
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 LineCount=140
tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 LineCount=323
```

Output Summary: PASS. Exit 0; five LineCount= lines recorded; the scheduling module prints LineCount=490.
