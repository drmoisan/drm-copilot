# Resolver-Call and Interpreter Scan (P3-T14)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/resolver-call-scan.ps1 -File .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
EXIT_CODE: 0
Output Summary:
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Get-WorktreeRunCheckpointPath allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Get-WorktreeItemLiveRoot allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Get-WorktreeRunCheckpointText allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Get-WorktreeRunCheckpointPath allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Resolve-WorktreeOperandTarget allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Find-WorktreeRunIdentitySignal allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Resolve-WorktreeEpicTarget allowed=True
RESOLVER-CALL file=.claude/hooks/validate-orchestrator-output-resolution.ps1 name=Resolve-WorktreeParallelTarget allowed=True
RESOLVER-CALL-SUMMARY disallowed=0 interpreter=0

The RESOLVER-CALL lines name only functions of the seven-function allowed set (Find-WorktreeRunIdentitySignal, Get-WorktreeRunCheckpointText, Get-WorktreeRunCheckpointPath, Resolve-WorktreeEpicTarget, Resolve-WorktreeParallelTarget, Resolve-WorktreeOperandTarget, Get-WorktreeItemLiveRoot). HOOK and PORT call no worktree-resolution function. No python, python3, py, or poetry command appears in any of the three files.

Result: PASS.
