# PSScriptAnalyzer Direct Count Final QA (P10-T3)

Timestamp: 2026-09-30T15-46
Command: $set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); $n=0; $m=0; foreach ($p in @('.claude/lib/orchestrator-state/OrchestratorState.psm1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1')) { $e=$null; $n+=@(Invoke-ScriptAnalyzer -Path $p -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; $m+=@($e).Count }; "Findings=$n Errors=$m"
EXIT_CODE: 0
Output Summary: printed `Findings=0 Errors=0` (warm-up call first; four paths analyzed one at a time). Loop iteration 2 (restart after remediation cycle 1; supersedes the iteration 1 artifact).

Execution route: PowerShell execution route (scratchpad `.sh` file calling `pwsh -NoProfile -Command '<command text>'`, run with `sh`).
