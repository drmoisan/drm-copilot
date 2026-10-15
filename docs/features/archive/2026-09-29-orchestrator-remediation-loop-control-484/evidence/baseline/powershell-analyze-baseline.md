# PowerShell Analyzer Baseline (P0-T29)

Timestamp: 2026-10-01T21-13
Task: P0-T29
Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6)

Command: $set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); $e=$null; $n=@(Invoke-ScriptAnalyzer -Path .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; "Findings=$n Errors=$(@($e).Count)"
EXIT_CODE: 0
Output: `Findings=0 Errors=0`

## Output Summary:

- Errors=0 (analyzer ran cleanly after the warm-up call).
- Findings=0 for OrchestratorStateReceipts.psm1 at Error, Warning, and Information severities.
