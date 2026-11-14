# Stage B PowerShell Test Baseline

Timestamp: 2026-11-07T05-20
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 shards, each shard exit 0, wall-clock 331.03 seconds. `artifacts/pester/pester-junit.xml` reports 14548 tests, 0 failures, 0 errors, and 10 disabled. `Get-PoshQCCoverageLineSummary` over `artifacts/pester/powershell-coverage.xml` reports 23443 covered and 1519 missed of 24962 lines, 93.91% repo-wide line coverage. The figures were read from those files and not from MCP output. Stage B files were being added to the tree while this run was in progress; the missed-line count of 1519 equals the stage A baseline, which indicates that no stage B file entered the coverage population.
