# Final QC Static, PowerShell, Plan B (P2-T1)

Timestamp: 2026-11-16T04-58
Command: pwsh -NoProfile -File SCRATCH/issue-1025-static.ps1 -OutJson SCRATCH/issue-1025-static-b2.json (check-only format and PSSA over scripts and tests/scripts)
EXIT_CODE: 0
Output Summary: format 939 files checked, 0 would-change (pwsh-format-baseline-b: 0), porcelain identical before and after; PSSA 935 files, 0 findings (pssa-baseline-b: 0), so 0 findings under scripts/harness and tests/scripts/harness; type check not applicable (PowerShell). No rewrite and no new finding, so the loop does not restart.

| Step | Command | Exit code | Finding count |
| --- | --- | --- | --- |
| Format (check-only) | Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1 with a no-op WriteFile that records would-change files | 0 | 0 would-change files; `git status --porcelain` identical before and after: true |
| Lint (PSSA) | Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over each .ps1 and .psm1 under scripts and tests/scripts | 0 | 0 findings (0 under scripts/harness and tests/scripts/harness) |
| Type check | not applicable (PowerShell) | n/a | n/a |
