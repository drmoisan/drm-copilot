# r3 OIA_SUITE Alone-Failure Diagnosis (P2-T12)

Timestamp: 2026-10-16T21-57
Command:
- Script -1 (SCRATCH/issue-953-r3-p2-t12-1.sh): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1') -Force; "AFTER_ADOPTION_IMPORT=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; "AFTER_ROUTING_IMPORT=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"; "ROUTING_FN=$([bool](Get-Command -Name Get-OrchestratorStateRoutingContractError -ErrorAction SilentlyContinue))"`
- Script -2 (SCRATCH/issue-953-r3-p2-t12-2.sh): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1'); $visible = Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue; "FIXED_ORDER_HAS_FN=$([bool]$visible)"; "FIXED_ORDER_ROUTING_FN=..."; $nested = & (Get-Module -Name OrchestratorStateRoutingContract) { (Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue).Module }; "FIXED_ORDER_SAME_INSTANCE=$([object]::ReferenceEquals($visible.Module, $nested))"`
- Script -3 (SCRATCH/issue-953-r3-p2-t12-3.sh): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; "PREDECESSOR_STATE_HAS_FN=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"`
- Each script runs in its own new pwsh process through the Tool route, runs no test, and writes no file.
EXIT_CODE: 0
Output Summary:
- Script -1 (exit 0): AFTER_ADOPTION_IMPORT=True; AFTER_ROUTING_IMPORT=False; ROUTING_FN=True
- Script -2 (exit 0): FIXED_ORDER_HAS_FN=True; FIXED_ORDER_ROUTING_FN=True; FIXED_ORDER_SAME_INSTANCE=True (observation)
- Script -3 (exit 0): PREDECESSOR_STATE_HAS_FN=False (observation: the import sequence of script -3 alone does not make the function visible; the pass in full and sharded runs therefore depends on other predecessor state, which this task does not gate on)
- OIA_FIRST_FAILURE_MESSAGE (latest r3-oia-fail-before.2026-10-16T21-57.md): CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
- No module-scope import error was observed in either module.
- Result: PASS (H2 confirmed; the D-R3-4 import order keeps both functions visible).

MECHANISM_OIA: H2 CONFIRMED - the forced nested import at OrchestratorStateRoutingContract.psm1:61 unloads the adoption module that OIA_SUITE:29 imported, so the suite relies on a predecessor's module state to see Get-OrchestratorStateIssueAdoptionResult
