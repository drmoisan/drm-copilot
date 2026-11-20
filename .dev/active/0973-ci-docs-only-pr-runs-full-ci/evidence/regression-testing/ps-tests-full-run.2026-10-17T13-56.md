# Fresh Single-Process Pester Run over tests/scripts, Post-Change (Issue #973)

Timestamp: 2026-10-17T13-56
Command: sh SCRATCH/issue-973-run.sh issue-973-test.ps1 -Root <worktree> -ScanList tests/scripts (PowerShell 7; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts, one process), then sh SCRATCH/issue-973-run.sh issue-973-report.ps1 (reads artifacts/pester/pester-junit.xml)
EXIT_CODE: 0

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-56): 11281 test cases, 11271 passed, 0 failed, 10 skipped; no suite reported a container error. Baseline (`FEATURE/evidence/baseline/ps-tests-full.2026-10-17T13-25.md`): 11223 cases, 11213 passed, 0 failed, 10 skipped. The difference of 58 cases is the new merge-base suite (28 cases) and the new rows in `CiChangeScope.Tests.ps1` (26), `CiDocsOnlyPathsConfig.Tests.ps1` (3), and `CiChangeScopeWorkflow.Tests.ps1` (1); no case was removed.

Failing tests: none. The failing set is empty, which is a subset of the empty [P0-T6] failing set, and contains no test from the six suites of [P2-T8]. `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` passes in this run.

Output Summary: 11271 passed, 0 failed, 10 skipped (11281 total); failing set empty.
