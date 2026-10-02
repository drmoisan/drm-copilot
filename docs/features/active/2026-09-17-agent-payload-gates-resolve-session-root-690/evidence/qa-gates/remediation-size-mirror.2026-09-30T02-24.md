# Remediation Size, Mirror, and Manifest (P5-T5)

Timestamp: 2026-09-30T02-24
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <WRR> <T-REC> <T-SIG>; sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 <WRR> <WRRB>; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
EXIT_CODE: 0
Output Summary:
- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 LineCount=497
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 LineCount=441
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 LineCount=174
- PAIR-SUMMARY pairs=1 unequal=0
- Manifest suite: TotalCount=19 PassedCount=19 FailedCount=0
