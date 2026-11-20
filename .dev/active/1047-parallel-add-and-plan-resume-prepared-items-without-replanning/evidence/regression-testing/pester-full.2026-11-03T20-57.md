# Pester Fresh Single-Process Run (CI shape, remediation cycle 1, loop pass 3)

Timestamp: 2026-11-03T20-57
Task: [P6-T6]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-run-pester.ps1: one fresh pwsh process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts with the module-default settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage population from config/poshqc-coverage.json); the last Pester run of the plan (loop pass 3); coverage read from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1047-read-results.ps1
EXIT_CODE: 255
Output Summary: 13946 tests discovered; 13527 passed, 409 failed, 10 skipped, 0 not run, in 978.66 s in one process (Pester console summary; the JUnit export failed on a 0x1B character and left artifacts/pester/pester-junit.xml truncated, hence exit 255). The failure lines are identical to the pre-edit baseline [P0-T3] and lie outside this item's suites; see qa-gates/pester-coverage.2026-11-03T20-57.md. Zero failures is not met on this Linux host.
