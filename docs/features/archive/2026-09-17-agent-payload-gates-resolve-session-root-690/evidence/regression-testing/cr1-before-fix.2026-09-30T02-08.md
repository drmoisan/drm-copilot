# CR-1 Fail-Before (P2-T2) [expect-fail]

Timestamp: 2026-09-30T02-08
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- TotalCount=28 PassedCount=27 FailedCount=1 (run against the unfixed WRR, after row B13 was inserted)
- FAILED: Resolve-WorktreeRunTargetByRecord.B13 resolves NoTarget for a pull request value too large for a 64-bit integer without enumerating live roots
- Failure: OverflowException: Value was either too large or too small for an Int64, raised at Test-WorktreeRunCheckpointRecord (WorktreeRunResolution.psm1:396) through Resolve-WorktreeRunTargetByRecord (:441). This is the CR-1 defect.
