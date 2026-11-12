# Pester Phase 0 Baseline ([P0-T3])

Timestamp: 2026-11-12T03-25
Command: sh SCRATCH/issue-1167-pester.sh (pwsh 7 from the item worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8, wall-clock=635.3s, every shard exit code 0, overall ExitCode 0 (fully green); merged JUnit and coverage written.
- artifacts/pester/pester-junit.xml (testsuites root): tests=21311, failures=0, errors=0, skipped/disabled=10; passed=21301, failed=0.
- artifacts/pester/powershell-coverage.xml repo-wide LINE coverage: 37558 covered / 39203 lines = 95.80% (missed 1645).
- Instruction coverage (information only): 63697 covered / 67240 = 94.73%.
- Per-file production coverage: not in scope (the plan changes no PowerShell production file).
