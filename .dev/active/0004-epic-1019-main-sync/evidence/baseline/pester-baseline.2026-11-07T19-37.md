# Pester Phase 0 baseline (integration tip before the main merge)

Timestamp: 2026-11-07T19-23
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree root> (launched from a `sh` script under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Tree: epic/documentation-estate-tooling-integration tip 2f5968dca.
- Run: 8 shard processes, every shard exit code 0, wall clock 673.21s.
- Merged JUnit (artifacts/pester/pester-junit.xml): tests=18859, failures=0, errors=0, disabled=10.
- Merged line coverage (artifacts/pester/powershell-coverage.xml, LINE counter): 33835 covered, 1630 missed, 95.40%.
