Timestamp: 2026-07-04T02-35
Command: (Select-String -Path scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Pattern "Invoke-FullReleaseFlow.ps1" -AllMatches | Measure-Object).Count
EXIT_CODE: 0
Output Summary: 1 match. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is now registered in `CodeCoverage.Path`, confirming Fix 2 was applied.
