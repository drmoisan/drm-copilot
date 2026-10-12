# AC-16 Orchestrator Split ([P6-T8])

Timestamp: 2026-10-12T04-08
Command: rg -n "^function (Test-OrchestratorCheckpointStructure|Invoke-RoutingContractValidation)\b" .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output.ps1 ; rg -n -F "Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1'" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 0
Output Summary: first search prints exactly two lines, both in validate-orchestrator-output-routing.ps1; second search prints exactly one line (56).

Search 1 (EXIT_CODE 0):
.claude/hooks/validate-orchestrator-output-routing.ps1:18:function Test-OrchestratorCheckpointStructure {
.claude/hooks/validate-orchestrator-output-routing.ps1:64:function Invoke-RoutingContractValidation {

Search 2 (EXIT_CODE 0):
56:try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1' -ErrorRecord $_ }
