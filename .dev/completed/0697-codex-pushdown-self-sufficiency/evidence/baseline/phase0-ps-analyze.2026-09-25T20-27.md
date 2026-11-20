# Phase 0 PowerShell Analyze Baseline (Issue #697)

Timestamp: 2026-09-25T20-27
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @(".codex/hooks", ".codex/scripts", ".claude/lib/codex-routing", "tests/scripts/codex-hooks", "tests/scripts/claude-lib/codex-routing") -InformationAction Continue'
EXIT_CODE: 0
Output Summary:
- `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>` (0 findings).
- One transient engine retry was logged: `Transient ScriptAnalyzer engine error (NullReferenceException) on <WORKSPACE_ROOT>\.claude\lib\codex-routing\CodexDeployment.psm1; retrying (1/5). PSScriptAnalyzer=1.25.0 PS=7.6.6`; the retry succeeded.
