# PowerShell Test Gate

Timestamp: 2026-11-07T03-47
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 shards, each shard exit 0, wall-clock 414.5 seconds. `artifacts/pester/pester-junit.xml` reports 14533 tests, 0 failures, 0 errors, and 10 disabled, which is 71 more tests than the baseline of 14462. The new suites hold 71 tests with 0 failures: `ProcessReductionLedger.Tests.ps1` holds 57, and `ProcessReductionLedger.Index.Tests.ps1`, the split file named in the plan's `File size` Pre-Mortem bullet, holds 14. Repo-wide line coverage from `Get-PoshQCCoverageLineSummary` is 93.9% (23437 covered, 1522 missed, 24959 lines) beside the baseline 93.87% (23248 covered, 1519 missed, 24767 lines). The `LINE` counter of the `sourcefile` element named `ProcessReductionLedger.psm1` reports 189 covered and 3 missed, 98.44% of 192 lines. The presence of that element confirms the module joined the coverage population. The figures were read from those files and not from MCP output.
