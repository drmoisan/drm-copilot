# PowerShell Static Baseline (issue #1165)

Timestamp: 2026-11-10T00-11
Command: sh SCRATCH/issue-1165-psstatic.sh (pwsh 7: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text, nothing written; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; PSScriptAnalyzer 1.25.0)
EXIT_CODE: 0
Output Summary:
- .claude/hooks/validate-bash.ps1 | formatter-diff=0 | analyzer-findings=0
- .claude/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
- .codex/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | formatter-diff=0 | analyzer-findings=0
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
- TOTAL=0
- EXIT=0
