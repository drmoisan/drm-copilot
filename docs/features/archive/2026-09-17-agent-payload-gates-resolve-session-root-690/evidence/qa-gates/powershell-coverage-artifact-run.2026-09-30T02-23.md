# Canonical PowerShell Coverage Artifact Run (P4-T1, RF-3)

Timestamp: 2026-09-30T02-23
Command: sh SCRATCH/run-ps.sh SCRATCH/poshqc-repo-test.ps1 (Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root <worktree root> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1), run as a background command
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- Tests completed in 571.66s; Tests Passed: 5821, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0.
- Covered 95.52% of 15,762 analyzed commands in 121 files.
- artifacts/pester/powershell-coverage.xml and artifacts/pester/pester-junit.xml exist (plus the Koverage copy).
- Run.Exit = $true in the repository runsettings, so the exit code equals the failed-test count; ExpectedExitCode 0 equals the P4-T2 FailedCount.
