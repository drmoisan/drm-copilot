# Orchestrator Pass-After ([P3-T15])

Timestamp: 2026-10-12T03-49
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1,tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1,tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
EXIT_CODE: 0
Output Summary: TotalCount=1233, PassedCount=1233, FailedCount=0, FailedContainersCount=0. Passed lines: 13 E-ORC- rows (E-ORC-1 to E-ORC-7 and six E-ORC-8 anomaly rows), 17 O- rows (O-1 to O-15, O-AST, O-STR), S2-13, S2-14, H7, H8, and the B1 row naming subagentstop-envelope.ps1.

TEST_ORDER_NOTE: The file set is the [P3-T15] set unchanged; only the order differs (S-DEP-SUITES-2 first), as recorded for [P2-T8] in evidence/regression-testing/phase2-pass-after.2026-10-12T01-20.md. The first run, in the plan's listed order, reported TotalCount=1233, PassedCount=1231, FailedCount=2: the `baseline mock interception probe` rows of hook-dependency-failure.Claude.Tests.ps1 and hook-dependency-failure.SpecialCases.Tests.ps1 (Get-EpicScopeCheckpointText in module EpicScopeResolution called 0 times). Re-diagnosis in this run: the two dependency suites pass alone (153/153); Envelope then Claude dependency suite passes; Reentry then Claude dependency suite passes; FailClosed then Claude dependency suite reproduces the probe failure. This is the pre-existing cross-suite module-state interaction diagnosed in Phase 2 (reproduced there with the pre-change files).

Required passed rows:
  [+] E-ORC-1 blocks with exit 2 when last_assistant_message is empty
  [+] E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved
  [+] E-ORC-3 exits 0 for a completion summary and a valid checkpoint fixture
  [+] E-ORC-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
  [+] E-ORC-5 blocks with exit 2 when the envelope carries only an output key
  [+] E-ORC-6 exits 2 with ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws
  [+] E-ORC-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
  [+] E-ORC-8 blocks EmptyPayload with the orchestrator payload anomaly clause
  [+] E-ORC-8 blocks UnparseableJson with the orchestrator payload anomaly clause
  [+] E-ORC-8 blocks NonObjectEnvelope with the orchestrator payload anomaly clause
  [+] E-ORC-8 blocks MissingAssistantMessage with the orchestrator payload anomaly clause
  [+] E-ORC-8 blocks NullAssistantMessage with the orchestrator payload anomaly clause
  [+] E-ORC-8 blocks NonStringAssistantMessage with the orchestrator payload anomaly clause
  [+] O-1 invalid envelope blocks once
  [+] O-2 empty assistant text blocks always
  [+] O-3 unsupported artifact type blocks once
  [+] O-4 rejected checkpoint path blocks once
  [+] O-5 epic target not derivable blocks always
  [+] O-6 ambiguous standard target blocks once
  [+] O-7 resolver exception blocks once
  [+] O-8 missing checkpoint file blocks always
  [+] O-9 checkpoint missing required fields blocks always
  [+] O-10 exception response without a runbook blocks always
  [+] O-11 halt response blocks once
  [+] O-12 model routing block blocks always
  [+] O-13 routing contract block blocks always
  [+] O-14 wave-barrier violation blocks once
  [+] O-15 unevaluable wave barrier blocks once
  [+] O-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
  [+] O-STR a string "true" stop_hook_active does not release a block-once stop
  [+] S2-13 keeps a checkpoint whose route and field keys differ only in case (CR-1)
  [+] S2-14 returns ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws (CR-3)
  [+] H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails
  [+] H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails
  [+] B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails

TotalCount=1233
PassedCount=1233
FailedCount=0
FailedContainersCount=0
