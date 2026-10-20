# Fresh Single-Process Pester Run over tests/scripts (Issue #984)

Timestamp: 2026-10-20T15-20
Command: sh SCRATCH/issue-984-run-full.sh issue-984-p6t15c (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts -DisableKoverageCopy; then SCRATCH/issue-984-parse.ps1 over artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: loop pass 3. 11394 test cases in one process: 11384 passed, 0 failed, 10 skipped. The failing set is empty, a subset of the empty [P0-T8] set, and holds no test from the eight suites of [P6-T14].

Counts from `artifacts/pester/pester-junit.xml`: total 11394, passed 11384, failed 0, skipped 10 (baseline [P0-T8]: total 11320, passed 11310, failed 0, skipped 10; the 74 added cases are the new suites' rows net of the B1 edges that left for handler entries).

Failing tests: none.
