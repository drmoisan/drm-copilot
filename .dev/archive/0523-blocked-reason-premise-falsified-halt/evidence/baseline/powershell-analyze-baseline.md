# PowerShell Analyzer Baseline (P0-T21)

Timestamp: 2026-09-30T14-30
Command: $set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); $e=$null; $n=@(Invoke-ScriptAnalyzer -Path .claude/lib/orchestrator-state/OrchestratorState.psm1 -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; "Findings=$n Errors=$(@($e).Count)"
EXIT_CODE: 0
Output Summary: `Findings=0 Errors=0`. Findings baseline 0; analyzer errors 0.

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`).
