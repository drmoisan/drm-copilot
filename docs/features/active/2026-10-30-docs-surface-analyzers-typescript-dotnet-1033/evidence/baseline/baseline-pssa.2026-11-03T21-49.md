# PSScriptAnalyzer baseline ([P0-T7])

Timestamp: 2026-11-03T21-49
Command: pwsh -NoProfile -File SCRATCH/issue-1033-pssa.ps1 -Root <worktree> -Folder .claude/lib/docs,tests/scripts/claude-lib/docs (direct `Invoke-ScriptAnalyzer -Path <folder> -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per folder; PSScriptAnalyzer 1.25.0 on PowerShell 7.6.9)
EXIT_CODE: 0
Output Summary: FINDINGS total=0 error=0 warning=0 information=0 parseerror=0 over `.claude/lib/docs` and `tests/scripts/claude-lib/docs`.

## Finding count by severity

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| ParseError | 0 |
| Total | 0 |
