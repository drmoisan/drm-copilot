# Fresh Single-Process Pester Run Without Coverage

Timestamp: 2026-10-28T22-24
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts -DisableKoverageCopy -LoadSettings { repository pester.runsettings.psd1 with CodeCoverage.Enabled = $false and TestResult.OutputPath under SCRATCH } (one fresh process; sh launcher under SCRATCH, PowerShell 7.6, Pester 5.9)
EXIT_CODE: 0
Output Summary:
- Counts read from the run's JUnit file: total 11812, passed 11802, failed 0, errors 0, skipped 10.
- Discovery found 11812 tests in 426 files; tests completed in 485 s; no code-coverage phase ran.
- The run shape matches the CI single-process execution of `tests/scripts`; no order dependence or leaked state surfaced.
