# Pester final gate (after the main merge)

Timestamp: 2026-11-07T19-38
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree root> (launched from a `sh` script under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Tree: merge commit 9b650459c.
- Run: 8 shard processes, every shard exit code 0, wall clock 552.2s.
- Merged JUnit: tests=19300, failures=0, errors=0, disabled=10. Phase 0 baseline: tests=18859, failures=0. The increase comes from suites merged from main.
- Merged line coverage: 34368 covered, 1637 missed, 95.45%. Phase 0 baseline: 95.40%.
