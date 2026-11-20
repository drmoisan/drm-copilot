# Baseline PSScriptAnalyzer (issue #1009)

Timestamp: 2026-10-30T17-09
Command: sh SCRATCH/issue-1009-ps.sh issue-1009-pssa.ps1 -ListFile SCRATCH/issue-1009-p0-pssa.txt (PowerShell 7: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information per file; no autofix)
EXIT_CODE: 0
Output Summary: 6 files analyzed, 0 findings in total.

| File | Findings |
|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` | 0 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 0 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 0 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 0 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 0 |
