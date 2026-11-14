# Pester Phase 0 Baseline (P0-T3)

Timestamp: 2026-11-08T17-25
Command: sh SCRATCH/issue-1138-gates.sh baseline (pwsh 7.6.9: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8, wall-clock 642.61 s, returned ExitCode 0; merged JUnit and coverage written
- artifacts/pester/pester-junit.xml: 20010 test cases, 20000 passed, 0 failed, 0 errors, 10 skipped
- artifacts/pester/powershell-coverage.xml repo-wide line coverage: 95.62% (35851 covered, 1641 missed)
- .claude/hooks/enforce-epic-invocation-origin.ps1 line coverage: 90.41% (66 covered, 7 missed)
- .claude/hooks/epic-invocation-nesting-depth.ps1: absent before the change (new file, judged against the threshold at the final gate)
