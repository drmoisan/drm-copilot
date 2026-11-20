# Final QC - PowerShell static (P2-T1, remediation cycle 1)

Timestamp: 2026-11-15T19-41
Command: pwsh -NoProfile -File artifacts/scratch-issue-1188/issue-1188-r1-static.ps1 -ListFile artifacts/scratch-issue-1188/final-files.txt (the list is `git diff --name-only --diff-filter=d <merge-base of origin/main and HEAD> HEAD -- '*.ps1'`, 27 files; `git status --porcelain` was empty, so no uncommitted file is outside the list)
EXIT_CODE: 0
Output Summary: format 0 drift (27 `Already formatted:` lines, 0 `Formatted:` lines, 0 writes through the non-writing `-WriteFile` seam), PSScriptAnalyzer 0 findings, `Invoke-PoshQCLeakScan` 0 failures (858 files, 78 findings, 76 exempt, 2 allowlisted). One pass, no restart.

Plan: remediation-plan.2026-11-14T23-56.md

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format (check-only) | `Invoke-PoshQCFormat -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1` with a `-GetFileList` seam returning the 27 files and a non-writing `-WriteFile` seam | 0 | 0 |
| Lint | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` | 0 | 0 |
| Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` (branch-current `scripts/powershell/PoshQC/PoshQC.psd1`) | 0 | 0 failures |
| Type check | not applicable to PowerShell | - | - |

No Python, TypeScript, or C# file is changed against the merge base.
