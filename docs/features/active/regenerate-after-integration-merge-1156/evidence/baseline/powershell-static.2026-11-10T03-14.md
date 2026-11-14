# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-10T03-14
Command: sh SCRATCH/issue-1156-exec-static.sh (pwsh 7: per file, Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with file content, no write; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, direct run)
EXIT_CODE: 0
Output Summary:
- .claude/hooks/enforce-epic-merge-gate.ps1: format drift none; PSScriptAnalyzer findings 0
- .codex/hooks/enforce-epic-merge-gate.ps1: format drift none; PSScriptAnalyzer findings 0
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: format drift none; PSScriptAnalyzer findings 0
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: format drift none; PSScriptAnalyzer findings 0
- Total: 0 files with format drift, 0 analyzer findings. The format step wrote nothing.
