# Fail-Closed Proof H8 ([P1-T12], expect-fail)

Timestamp: 2026-10-09T22-41
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H8 *'), and in the same script R-EXIT2 over .claude/hooks/validate-orchestrator-output.ps1 and .claude/hooks/validate-orchestrator-output-resolution.ps1 (sh <SCRATCHPAD>/r.sh proof -Id H8 ... -Exit2)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the H8 row failed (decision 0/1): with OrchestratorStateEpicWaveBarrier.psm1 forced to fail, the hook invoked through the & route threw a Write-Error block under $ErrorActionPreference = 'Stop' instead of exiting 2 (the epic leg was not reached; the block text is the resolver's target diagnostic); neither file contains an exit 2 statement (EXIT2 0 and 0); PROOF_RESULT FAIL-OPEN; DECISION CONVERT (matches the planning-time finding).

HANDLER: H8
UPSTREAM: #840
HANDLER-FILES: .claude/hooks/validate-orchestrator-output.ps1; .claude/hooks/validate-orchestrator-output-resolution.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1
FAILURE-VARIABLE: $script:OrchestratorOutputWaveBarrierImportFailure
DENY-CODE: $script:OrchestratorOutputUnevaluableToken (EPIC_WAVE_BARRIER_UNEVALUABLE:)
CITATION: guarded edge OrchestratorStateEpicWaveBarrier.psm1 | cited init :56, try :72-77 | observed init 56, catch assignment 76 (HANDLER-SITE H8, found)
CITATION: deny path | cited validate-orchestrator-output-resolution.ps1:294-297, epic leg only (validate-orchestrator-output.ps1:463-466); same exit-1 tail as H7 | observed consumer validate-orchestrator-output-resolution.ps1:294; epic leg 463-466; tail 476-480
CITATION: registered hook | .claude/hooks/validate-orchestrator-output.ps1 (SubagentStop)
EXIT2: .claude/hooks/validate-orchestrator-output.ps1 | 0
EXIT2: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
DECISION_ROWS_PASSED: 0/1
CLASSIFY: H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails | NO-DECISION
PROOF_RESULT: FAIL-OPEN
DECISION: CONVERT

Runner output:

```text
PassedCount: 0
FailedCount: 1
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Failed | passed=0 | failed=1
FAILED: H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails | Expected $null or empty, because the hook must not throw (ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Ambiguous (TARGET_WORKTREE_AMBIGUOUS): the epic checkpoints of live worktrees record 4 distinct integration_branch values (epic/parallel-orchestration-integration, epic/push-down-payload-correctness-integration, epic/orchestrator-state-contract-correctness-integration, epic/enforcement-hook-precision-integration), and the agent output names no integration_branch: value), but got ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Ambiguous (TARGET_WORKTREE_AMBIGUOUS): the epic checkpoints of live worktrees record 4 distinct integration_branch values (epic/parallel-orchestration-integration, epic/push-down-payload-correctness-integration, epic/orchestrator-state-contract-correctness-integration, epic/enforcement-hook-precision-integration), and the agent output names no integration_branch: value.
RUNNER_EXIT: 1
DECISION_ROWS_PASSED: 0/1
E_CONSTRUCTION_FAILED_LINES: 0
CLASSIFY: H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails | NO-DECISION
EXIT2: .claude/hooks/validate-orchestrator-output.ps1 | 0
EXIT2: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
PROOF_RESULT: FAIL-OPEN
DECISION: CONVERT
```
