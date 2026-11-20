# Full Pester Run (issue #997, final QA)

Timestamp: 2026-10-29T16-54
Command: sh SCRATCH/issue-997-pester-full.sh (fresh PowerShell 7 process; imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -ScanFolders tests/scripts in one process with coverage; then SCRATCH/issue-997-read-results.ps1 reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): tests=12198, failures=0, errors=0, skipped/disabled=10, passed=12188.
- P0-T4 baseline named no failing test; this run has zero failures, so no failure is outside the baseline.
- Test count grew by 94 against the baseline (12104), from the three new suites, SpecialCases C9, and the guard-suite rows that discover the new suites.
- Pester console summary: Tests Passed: 12188, Failed: 0, Skipped: 10; Covered 92.23 percent of 29,166 analyzed commands in 226 files.
- Repository line coverage: 18409 covered, 1396 missed, 92.95 percent.
