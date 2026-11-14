# Pester Final Gate (remediation cycle 1, P0-T1 and P0-T2)

Timestamp: 2026-11-08T18-26
Command: sh SCRATCH/issue-1138-gates.sh r1 both (pwsh 7.6.9: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8, wall-clock 571.82 s, returned ExitCode 0; one run, no re-run
- artifacts/pester/pester-junit.xml: 20120 test cases, 20110 passed, 0 failed, 0 errors, 10 skipped (Phase 0 baseline: 20010 cases, 0 failed; prior final gate: 20119 cases, 0 failed); one new case
- Repo-wide line coverage: 95.64% (36056 covered, 1645 missed); baseline 95.62%, no drop
- .claude/hooks/epic-invocation-nesting-depth.ps1: 100.00% line coverage (19 of 19); prior final gate 100.00%, no drop
- .claude/hooks/enforce-epic-invocation-origin.ps1: 90.79% line coverage (69 of 76); unchanged
- New It "coordinators halt on a NESTING_DEPTH_INSUFFICIENT deny" (live and bundle copies of the four coordinator agents): found once, passed
- "allows at or above 3" (now including 99999999999) and "denies below 3 with remedy text" (now including -99999999999): passed
- "bundle copy matches live file" (14 mirrored files): passed
