# PowerShell Format Baseline, Plan B (P0-T3)

Timestamp: 2026-11-16T04-02
Command: pwsh -NoProfile -File SCRATCH/issue-1025-static.ps1 -OutJson SCRATCH/issue-1025-static-b0.json (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1 with an injected no-op WriteFile that records each file the formatter would rewrite; check-only, no file written)
EXIT_CODE: 0
Output Summary: 939 PowerShell files checked under scripts and tests/scripts; would-change file count 0; `git status --porcelain` identical before and after the run (PorcelainIdentical=True).

WouldChange: 0
PorcelainIdentical: true
