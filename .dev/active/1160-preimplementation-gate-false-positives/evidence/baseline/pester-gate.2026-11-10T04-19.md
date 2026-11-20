# Pester Gate Phase 0 Baseline (P0-T2)

Timestamp: 2026-11-10T03-39
Command: sh SCRATCH/issue-1160-pester-baseline.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode; then SCRATCH/issue-1160-summary.ps1 reads artifacts/pester/pester-junit.xml, the shard JUnit files, and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- One parallel run on the unchanged tree, 8 shard processes, all exiting 0; started 2026-11-10T03-39 UTC and ended 2026-11-10T04-17 UTC.
- Merged JUnit (`artifacts/pester/pester-junit.xml`): total 21311, passed 21301, failed 0, errors 0, skipped 10. The shard JUnit files give the same totals. No pre-existing failure.
- Repo-wide line coverage (`artifacts/pester/powershell-coverage.xml`): 95.80% (37558/39203 lines).
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 96.32% (157/163 lines).
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 100.00% (173/173 lines).
- The new sibling files do not exist yet, so the report holds no figure for them (no pre-change run; they are judged against the thresholds).
