# Live Route Probe of the Claude PowerShell Hook (P1-T6)

Timestamp: 2026-09-29T19-20
Command: sh SCRATCH/run-ps.sh SCRATCH/route-probe.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
Output Summary:
LARGE-PATH-ROUTE=True
SELECTED-ROUTE=large
CPSHOOK now dot-sources only `enforce-batch-budget-route.ps1` and resolves the neutral helper names; the live hook loads and classifies the checkpoint as the large path.
