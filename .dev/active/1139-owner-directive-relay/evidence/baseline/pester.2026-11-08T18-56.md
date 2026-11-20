# Pester Phase 0 Baseline ([P0-T2])

Timestamp: 2026-11-08T18-40
Command: sh SCRATCH/issue-1139-pester.sh (from the worktree root: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root (Get-Location).ProviderPath; exit $r.ExitCode')
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one Invoke-PoshQCParallelTest run of the branch-current PoshQC module. Returned ExitCode 0; WorkerCount 8; wall-clock 874.82 s; every shard exited 0. Counts from artifacts/pester/pester-junit.xml (merged, written 2026-11-08T18:55Z): tests 20098, failures 0, errors 0, skipped (disabled) 10, passed 20088. Failing tests: none. Repo-wide line coverage from artifacts/pester/powershell-coverage.xml: 95.63% (36034 covered, 1645 missed). In-scope file line coverage: .claude/hooks/validate-orchestrator-output.ps1 99.19% (122 covered, 1 missed). .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1 does not exist yet (new file, no baseline; judged against the thresholds at [P4-T3]).

## Notes

- The sum of the eight per-shard JUnit files agrees with the merged file: 20098 tests, 0 failed, 0 errors, 10 skipped.
- The run completed during the window in which the Bash tool started it at 2026-11-08T18-40 UTC and the merged reports were written at 2026-11-08T18-55 UTC.
- Pre-existing failures: none recorded.
