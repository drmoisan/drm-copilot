# PowerShell Test Baseline

Timestamp: 2026-11-07T03-25
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 shards, each shard exit 0, wall-clock 317.22 seconds. `artifacts/pester/pester-junit.xml` reports 14462 tests, 0 failures, 0 errors, and 10 disabled. `Get-PoshQCCoverageLineSummary` over `artifacts/pester/powershell-coverage.xml` reports 23248 covered and 1519 missed of 24767 lines, 93.87% repo-wide line coverage. The figures were read from those files and not from MCP output.
