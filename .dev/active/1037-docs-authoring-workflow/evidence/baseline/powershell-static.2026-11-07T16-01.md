# PowerShell Static Baseline (P0-T4)

Timestamp: 2026-11-07T16-01
Command: sh SCRATCH/issue-1037-static.sh (imports `scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCFormat -ScanFolders .claude/hooks -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1` with a no-op `-WriteFile` scriptblock; then `Invoke-ScriptAnalyzer -Path .claude/hooks -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `git status --porcelain` captured before and after)
EXIT_CODE: 0
Output Summary: Formatter check mode: 81 files examined, 0 `Formatted:` log lines (changed-file count 0). Analyzer findings over `.claude/hooks`: 0. `git status --porcelain` identical before and after (tree unchanged).
