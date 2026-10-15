# PSScriptAnalyzer Findings Read Directly (P10-T3)

Timestamp: 2026-10-01T22-52
Task: P10-T3
Loop iteration: 2
Route: sh-wrapped pwsh -NoProfile -Command (scratchpad script outside the repository)

Command: $set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); $n=0; $m=0; foreach ($p in @('.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1','.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1')) { $e=$null; $n+=@(Invoke-ScriptAnalyzer -Path $p -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; $m+=@($e).Count }; "Findings=$n Errors=$m"
EXIT_CODE: 0

## Output Summary:

- Printed: `Findings=0 Errors=0`
- Result: PASS.
