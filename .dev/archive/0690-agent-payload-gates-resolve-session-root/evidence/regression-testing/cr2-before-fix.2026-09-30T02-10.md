# CR-2 Fail-Before (P3-T2) [expect-fail]

Timestamp: 2026-09-30T02-10
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- TotalCount=17 PassedCount=16 FailedCount=1 (run against WRR without the CR-2 change, after row T4 was inserted)
- FAILED: Get-WorktreeRunCheckpointText.T4 returns null and writes a diagnostic to stderr when the file cannot be read
- Failure: Expected regular expression 'WORKTREE_RUN_CHECKPOINT_UNREADABLE' to match <empty>. The silent catch returned $null and wrote nothing, which is the CR-2 defect.
