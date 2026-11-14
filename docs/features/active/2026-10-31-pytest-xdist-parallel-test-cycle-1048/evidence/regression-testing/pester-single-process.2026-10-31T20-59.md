# Fresh single-process Pester run over tests/scripts (#1048, P10-T8)

Timestamp: 2026-10-31T20-59
Command: in a new pwsh process, `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts'` through SCRATCH/issue-1048-pester-single.ps1; totals read from `artifacts/pester/pester-junit.xml`
EXIT_CODE: 0
Output Summary:
- JUnit root: tests=13643, failures=0, errors=0, disabled=10, 485 test suites (one per test file); JUnit root time 791.833 s; wall-clock 1048.1 s including coverage processing.
- Console summary: `Tests Passed: 13633, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`.
- One process ran every test file in sequence, as each CI shard does, with the SW04 addition from P10-T7 included. The totals equal the P10-T7 full run and the P7-T3 concurrent and serial runs (13643 tests, 0 failures), so no cross-file state leak appears in single-process execution.
