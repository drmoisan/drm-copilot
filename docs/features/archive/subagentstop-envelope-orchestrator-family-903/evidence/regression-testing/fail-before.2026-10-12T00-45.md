# Fail-Before Run ([P1-T13], expect-fail)

Timestamp: 2026-10-12T00-45
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TotalCount=113, PassedCount=15, FailedCount=98, FailedContainersCount=0. Every FAILED row begins with E-ORC-, E-EXE-, E-RA-, E-PLN-, S2-13, S2-14, O-, X-, P-, or R-. The 15 passing rows are the three probe rows (resolution suite, orchestrator Envelope, orchestrator Reentry) and S2-1 to S2-12.

Passing rows ([+]):
  [+] baseline mock interception probe (x3)
  [+] S2-1 to S2-12 (12 rows)

Pester report (count lines and FAILED lines):
TotalCount=113
PassedCount=15
FailedCount=98
FailedContainersCount=0
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-1 blocks with exit 2 when last_assistant_message is empty
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-3 exits 0 for a completion summary and a valid checkpoint fixture
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-5 blocks with exit 2 when the envelope carries only an output key
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-6 exits 2 with ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks EmptyPayload with the orchestrator payload anomaly clause
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks UnparseableJson with the orchestrator payload anomaly clause
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks NonObjectEnvelope with the orchestrator payload anomaly clause
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks MissingAssistantMessage with the orchestrator payload anomaly clause
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks NullAssistantMessage with the orchestrator payload anomaly clause
FAILED: validate-orchestrator-output.ps1 SubagentStop envelope.E-ORC-8 blocks NonStringAssistantMessage with the orchestrator payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-1 blocks with exit 2 when last_assistant_message lacks a plan-path line
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-2 exits 0 when the advertised plan satisfies the executor checks
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-3 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-4 blocks with exit 2 when the envelope carries only an output key
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-5 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-6 exits 2 when hook-dependency-guard.ps1 fails to load
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks EmptyPayload with the executor payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks UnparseableJson with the executor payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks NonObjectEnvelope with the executor payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks MissingAssistantMessage with the executor payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks NullAssistantMessage with the executor payload anomaly clause
FAILED: validate-executor-output.ps1 SubagentStop envelope.E-EXE-7 blocks NonStringAssistantMessage with the executor payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-1 blocks with exit 2 when the required artifact is missing
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-2 blocks with exit 2 when -AgentName is missing
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-3 blocks with exit 2 when -RequiredArtifact is missing
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-4 exits 0 when the artifact is present
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-5 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-6 blocks with exit 2 when the envelope carries only an output key
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-8 exits 2 when hook-dependency-guard.ps1 fails to load
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks EmptyPayload with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks UnparseableJson with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks NonObjectEnvelope with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks MissingAssistantMessage with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks NullAssistantMessage with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-9 blocks NonStringAssistantMessage with the required-artifact payload anomaly clause
FAILED: validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-10 calls Exit-SubagentStopBlock exactly once, outside the missing-argument if block
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-1 invalid envelope blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-2 empty assistant text blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-3 unsupported artifact type blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-4 rejected checkpoint path blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-5 epic target not derivable blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-6 ambiguous standard target blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-7 resolver exception blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-8 missing checkpoint file blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-9 checkpoint missing required fields blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-10 exception response without a runbook blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-11 halt response blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-12 model routing block blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-13 routing contract block blocks always
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-14 wave-barrier violation blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-15 unevaluable wave barrier blocks once
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
FAILED: validate-orchestrator-output.ps1 re-entry policy.O-STR a string "true" stop_hook_active does not release a block-once stop
FAILED: validate-executor-output.ps1 re-entry policy.X-1 invalid envelope blocks once
FAILED: validate-executor-output.ps1 re-entry policy.X-2 empty assistant text blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-3 missing plan-path blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-4 missing plan file blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-5 non-canonical preflight blocked text blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-6 missing preflight signal blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-7 non-preflight blocked report blocks once
FAILED: validate-executor-output.ps1 re-entry policy.X-8 plan without task checkboxes blocks once
FAILED: validate-executor-output.ps1 re-entry policy.X-9 unchecked task blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-10 missing AC Status Summary blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-11 missing command evidence blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-12 missing per-language status line blocks always
FAILED: validate-executor-output.ps1 re-entry policy.X-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
FAILED: validate-planner-output.ps1 re-entry policy.P-1 invalid envelope blocks once
FAILED: validate-planner-output.ps1 re-entry policy.P-2 empty assistant text blocks always
FAILED: validate-planner-output.ps1 re-entry policy.P-3 missing preflight signal blocks always
FAILED: validate-planner-output.ps1 re-entry policy.P-4 missing plan-path blocks always
FAILED: validate-planner-output.ps1 re-entry policy.P-5 missing plan file blocks always
FAILED: validate-planner-output.ps1 re-entry policy.P-6 plan structure violations block always
FAILED: validate-planner-output.ps1 re-entry policy.P-7 planner internal review violations block always
FAILED: validate-planner-output.ps1 re-entry policy.P-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-1 missing -AgentName blocks once through the inline tail
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-2 invalid envelope blocks once
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-3 empty assistant text blocks always
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-4 malformed artifact spec blocks once
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-5 missing artifact token blocks always
FAILED: validate-required-artifact-output.ps1 re-entry policy.R-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-1 blocks with exit 2 when last_assistant_message lacks the PREFLIGHT: signal
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-2 blocks with exit 2 when last_assistant_message lacks the plan-path line
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-3 exits 0 when both are present with a contract-valid plan fixture
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-5 blocks with exit 2 when the envelope carries only an output key
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-6 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks EmptyPayload with the planner payload anomaly clause
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks UnparseableJson with the planner payload anomaly clause
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks NonObjectEnvelope with the planner payload anomaly clause
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks MissingAssistantMessage with the planner payload anomaly clause
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks NullAssistantMessage with the planner payload anomaly clause
FAILED: validate-planner-output entry point (issues #786 and #903).E-PLN-7 blocks NonStringAssistantMessage with the planner payload anomaly clause
FAILED: validate-orchestrator-output resolution sibling.S2-13 keeps a checkpoint whose route and field keys differ only in case (CR-1)
FAILED: validate-orchestrator-output resolution sibling.S2-14 returns ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws (CR-3)
