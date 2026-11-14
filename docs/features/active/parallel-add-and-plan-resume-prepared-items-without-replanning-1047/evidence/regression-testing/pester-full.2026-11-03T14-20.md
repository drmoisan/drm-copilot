# Pester Fresh Single-Process Run (CI shape)

Timestamp: 2026-11-03T14-20
Task: [P8-T12]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-run-pester.ps1 -DefaultSettings: one fresh pwsh process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts with the module-default settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage population derived from config/poshqc-coverage.json); counts from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: 13912 tests, 0 failures, 0 errors, 10 disabled (pre-existing), 493 suites, in one process. Per-file line coverage in this run: ParallelAdmission.psm1 100.00% (141/141), ParallelAdmissionPrecedence.psm1 100.00% (179/179), Invoke-ParallelAdmission.ps1 96.15% (250/260), enforce-parallel-cohort-barrier-helpers.ps1 100.00% (97/97).
