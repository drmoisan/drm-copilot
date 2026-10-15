# Remediation Line Limits for AC-5 (P2-T10)

Timestamp: 2026-09-29T20-43
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1
EXIT_CODE: 0
Output Summary:
- .claude/lib/blast-radius/BlastRadiusGlob.psm1 LineCount=454
- .claude/lib/blast-radius/BlastRadiusConflict.psm1 LineCount=469
- .claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=483
- tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 LineCount=139
- tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 LineCount=169
- tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 LineCount=141
- tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 LineCount=74
- Every LineCount is at most 500; SCHEDULING 483 is at most 486 (R5).
- Informational (R7): CONFLICT 469 meets the target of at most 470.
- Result: PASS.
