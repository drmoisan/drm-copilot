# Full Pester Run After Change (Issue #1011, AC-17)

Timestamp: 2026-10-31T02-06
Command: sh SCRATCH/issue-1011-pester-full.sh (fresh single-process run: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts, coverage on; the `poshqc / PowerShell QC` population); then sh SCRATCH/issue-1011-read-results.sh
EXIT_CODE: 0
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): tests 13478, failures 0, errors 0, skipped cases 10.
- Pester console: Tests Passed 13468, Failed 0, Skipped 10, NotRun 0; overall command coverage 92.74% over 256 files.
- Baseline (P0-T5): 13437 tests, 0 failures, 0 errors, so there are no baseline failures to exclude. The 41 additional tests are the new AL, TR, and CT rows.
