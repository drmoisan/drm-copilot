# Orchestrator Split: Function Text and Load ([P2-T1], [P2-T2])

Timestamp: 2026-10-12T01-02
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/function-text-compare.ps1 -OldPath <SCRATCHPAD>/orchestrator-before-split.ps1 -NewPath .claude/hooks/validate-orchestrator-output-routing.ps1 -Name Test-OrchestratorCheckpointStructure,Invoke-RoutingContractValidation
EXIT_CODE: 0
Output Summary: FUNCTION-TEXT-SUMMARY MismatchCount=0 with two Match=True lines. Both functions removed from the main file; L1 is at line 54, before the $ErrorActionPreference line 61.

Note: <SCRATCHPAD>/orchestrator-before-split.ps1 was produced by copying the working-tree file after `git diff --quiet HEAD -- .claude/hooks/validate-orchestrator-output.ps1` exited 0 (identical to HEAD). The worktree isolation guard refused redirecting `git show` output to a file.
Note: the deletion removed lines 172-325 after the L1 insertion (the two functions plus the blank line that followed them), so one blank line separates Test-HumanInteractionShape from Invoke-OrchestratorOutputValidation.

A7 output:
FUNCTION-TEXT name=Test-OrchestratorCheckpointStructure Match=True
FUNCTION-TEXT name=Invoke-RoutingContractValidation Match=True
FUNCTION-TEXT-SUMMARY MismatchCount=0

[P2-T2] searches:
Command: rg -n "^function (Test-OrchestratorCheckpointStructure|Invoke-RoutingContractValidation)\b" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 1 (no match)
Command: rg -c -F "validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure" .claude/hooks/validate-orchestrator-output.ps1
Output: 1
L1 line: 54:try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1' -ErrorRecord $_ }
ErrorActionPreference line: 61
