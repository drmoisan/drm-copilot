# AC-16 Orchestrator Split, Static Re-run ([P7-T8] re-run of [P6-T8])

Timestamp: 2026-10-12T04-21
Command: rg -n "^function (Test-OrchestratorCheckpointStructure|Invoke-RoutingContractValidation)\b" .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output.ps1 ; rg -n -F "Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1'" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 0
Output Summary: first search prints exactly two lines, both in the routing sibling; second search prints exactly one line.

.claude/hooks/validate-orchestrator-output-routing.ps1:18:function Test-OrchestratorCheckpointStructure {
.claude/hooks/validate-orchestrator-output-routing.ps1:64:function Invoke-RoutingContractValidation {

56:try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1' -ErrorRecord $_ }
