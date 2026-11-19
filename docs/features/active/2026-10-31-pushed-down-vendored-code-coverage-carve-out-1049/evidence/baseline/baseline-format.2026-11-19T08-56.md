# Baseline - PoshQC Format - [P0-T5]

Timestamp: 2026-11-19T08-56
Command: sh SCRATCH/issue-1049-static.sh format (git status --porcelain before; PowerShell 7 session importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1; git status --porcelain after)
EXIT_CODE: 0
Output Summary: PORCELAIN: identical (before and after listings equal; the formatter changed no file). FORMATTED_COUNT: 0; ALREADY_FORMATTED_COUNT: 982. Scan folders `scripts`, `tests/scripts` (configured `tests/powershell` absent).
