# PowerShell Static Baseline (remediation [P0-T2])

Timestamp: 2026-11-07T17-45
Command: sh SCRATCH/issue-1037-r-static.sh (runs SCRATCH/issue-1037-r-static.ps1 in PowerShell 7 at the pre-merge head: `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` in check mode, no write, then `Invoke-ScriptAnalyzer` with the same settings; `git status --porcelain --untracked-files=all` and `git diff` captured before and after)
EXIT_CODE: 0
Output Summary: Files: `.claude/hooks/docs-role-contract.ps1`, `.claude/hooks/validate-docs-role-output.ps1`, `.claude/hooks/enforce-docs-role-write-scope.ps1`, `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1`. Formatter changed-file count: 0 of 4. Analyzer finding count: 0. `git status --porcelain` identical before and after (PORCELAIN_IDENTICAL=true).
