# PowerShell Final Static QC (issue #1165)

Timestamp: 2026-11-10T00-38
Command: sh SCRATCH/issue-1165-psstatic.sh (pwsh 7: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text, nothing written; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); then sh SCRATCH/issue-1165-leak.sh (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <item worktree root>)
EXIT_CODE: 0
Output Summary:
- Format step: exit 0; formatter-difference count 0 for every file (no file rewritten).
- Lint step: exit 0; analyzer finding count 0 for every file.
- Type-check step: not applicable to PowerShell.
- Per file:
  - .claude/hooks/validate-bash.ps1 | formatter-diff=0 | analyzer-findings=0
  - .claude/hooks/bash-command-shape-guidance.ps1 | formatter-diff=0 | analyzer-findings=0
  - .claude/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
  - .codex/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
  - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | formatter-diff=0 | analyzer-findings=0
  - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/bash-command-shape-guidance.ps1 | formatter-diff=0 | analyzer-findings=0
  - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
  - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/worktree-poetry-venv-policy.ps1 | formatter-diff=0 | analyzer-findings=0
  - tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1 | formatter-diff=0 | analyzer-findings=0
  - tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1 | formatter-diff=0 | analyzer-findings=0
  - tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1 | formatter-diff=0 | analyzer-findings=0
  - tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1 | formatter-diff=0 | analyzer-findings=0
  - TOTAL=0
- Leak scan: exit 0; "Leak scan: 741 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."
