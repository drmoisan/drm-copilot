# Phase 0 static baseline: PowerShell format check (stage B [P0-T4])

Timestamp: 2026-11-20T10-43
Command: sh SCRATCH/issue-1016-psstatic.sh (pwsh: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1 -WriteFile { non-writing seam } -Logger { collect })
EXIT_CODE: 0
Output Summary: 1864 PowerShell files checked; 0 `Formatted:` lines (drift count 0); no file written.
