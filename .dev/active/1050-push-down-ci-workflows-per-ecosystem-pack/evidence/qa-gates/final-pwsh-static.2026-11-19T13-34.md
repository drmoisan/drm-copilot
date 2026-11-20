# Final QC: PowerShell Static (advisory-fix plan, P2-T1)

Timestamp: 2026-11-19T13-34
Command: sh SCRATCH/issue-1050-advisory-gate-static.sh afinal (PowerShell leg: SCRATCH/issue-1050-pwsh-folders.ps1 -FolderList scripts,tests/scripts,extensions/drm-copilot/resources/ci-workflows)
EXIT_CODE: 0
Output Summary: 985 PowerShell files, including `scripts/ci/Set-CiRequiredChecks.ps1`, `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1`, and `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`. Format 0 differences; PSScriptAnalyzer 0 findings; 0 engine exceptions in this run.

| Step | Command | Exit code | Findings |
| --- | --- | --- | --- |
| Format | `Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the file text (no write) | 0 | 0 |
| Analyze | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file | 0 | 0 |
| Type check | not applicable for PowerShell | n/a | n/a |

Porcelain observation: `git status --porcelain` before the run 0 lines, after the run 0 lines (identical); the formatter step writes no file.
