# PowerShell Test Gate

Timestamp: 2026-11-07T03-57
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 shards, wall-clock 363.45 seconds. `artifacts/pester/pester-junit.xml` reports 14537 tests, 0 failures, 0 errors, and 10 disabled, which is 75 more tests than the baseline of 14462. The new suites hold 75 tests with 0 failures: `ProcessReductionLedger.Tests.ps1` holds 61, and `ProcessReductionLedger.Index.Tests.ps1`, the split file named in the plan's `File size` Pre-Mortem bullet, holds 14. Repo-wide line coverage from `Get-PoshQCCoverageLineSummary` is 93.91% (23440 covered, 1519 missed, 24959 lines) beside the baseline 93.87% (23248 covered, 1519 missed, 24767 lines). The `LINE` counter of the `sourcefile` element named `ProcessReductionLedger.psm1` reports 192 covered and 0 missed, 100% of 192 lines. The presence of that element confirms the module joined the coverage population. The figures were read from those files and not from MCP output.

Notes: this run follows the self-review fix, which added three tests, and it supersedes the earlier gate artifact.
