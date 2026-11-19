# Baseline - PSScriptAnalyzer - [P0-T5]

Timestamp: 2026-11-19T08-56
Command: sh SCRATCH/issue-1049-static.sh analyze (PowerShell 7 session importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCAnalyze -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1, each file through Invoke-ScriptAnalyzer -Severity Error, Warning, Information)
EXIT_CODE: 0
Output Summary: FINDING_COUNT: 0. `PSScriptAnalyzer passed: no findings`. Scan folders: `scripts`, `tests/scripts` (the configured folder `tests/powershell` does not exist in the tree and is skipped). One transient NullReferenceException on scripts/ci/CiChangeScope.psm1 was retried once by the built-in retry and then analyzed without finding. PSScriptAnalyzer 1.25.0.
