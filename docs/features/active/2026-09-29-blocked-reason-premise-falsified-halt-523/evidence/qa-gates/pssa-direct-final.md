# PSScriptAnalyzer Direct Count Final QA (P10-T3)

Timestamp: 2026-09-30T15-10
Command: $set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); $n=0; $m=0; foreach ($p in @('.claude/lib/orchestrator-state/OrchestratorState.psm1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1')) { $e=$null; $n+=@(Invoke-ScriptAnalyzer -Path $p -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; $m+=@($e).Count }; "Findings=$n Errors=$m"
EXIT_CODE: 0
Output Summary: Printed `Findings=0 Errors=0`.

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`).
