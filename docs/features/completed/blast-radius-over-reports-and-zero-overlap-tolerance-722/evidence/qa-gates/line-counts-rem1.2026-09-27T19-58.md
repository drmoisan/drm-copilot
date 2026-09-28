# Line Counts After the Edits (Remediation Cycle 1, P1-T12)

Timestamp: 2026-09-27T19-58
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
EXIT_CODE: 0

## Output (verbatim)

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=486
.claude/lib/blast-radius/BlastRadius.psm1 LineCount=475
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 LineCount=372
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 LineCount=143
tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 LineCount=326
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=486
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 LineCount=475
```

Before (P0-T8): scheduling module 490, facade 475, scheduling Pester 359, historical-runs Pester 140, write-intent Pester 323.

Output Summary: PASS. Every LineCount is at most 500 (maximum 486); each mirror equals its primary (486 and 475).
