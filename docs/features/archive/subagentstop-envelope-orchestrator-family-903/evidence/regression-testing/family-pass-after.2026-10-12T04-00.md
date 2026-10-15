# Family Pass-After ([P4-T21])

Timestamp: 2026-10-12T04-00
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1,tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1,tests/scripts/claude-hooks/validate-executor-output.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1,tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1,tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1,tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
EXIT_CODE: 0
Output Summary: TotalCount=1216, PassedCount=1216, FailedCount=0, FailedContainersCount=0. Passed lines: 12 E-EXE-, 15 E-RA-, 12 E-PLN-, 13 X-, 8 P-, 6 R-, 10 REG-; B1 row for validate-planner-output.ps1 naming subagentstop-envelope.ps1; C8 row for validate-planner-output.ps1.

TEST_ORDER_NOTE: S-DEP-SUITES-2 is listed first, consistent with the Phase 2 and Phase 3 gates; FailClosed is not in this set, so the recorded cross-suite interaction does not apply here.

Required passed rows:
  [+] E-EXE-1 blocks with exit 2 when last_assistant_message lacks a plan-path line
  [+] E-EXE-2 exits 0 when the advertised plan satisfies the executor checks
  [+] E-EXE-3 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
  [+] E-EXE-4 blocks with exit 2 when the envelope carries only an output key
  [+] E-EXE-5 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
  [+] E-EXE-6 exits 2 when hook-dependency-guard.ps1 fails to load
  [+] E-EXE-7 blocks EmptyPayload with the executor payload anomaly clause
  [+] E-EXE-7 blocks UnparseableJson with the executor payload anomaly clause
  [+] E-EXE-7 blocks NonObjectEnvelope with the executor payload anomaly clause
  [+] E-EXE-7 blocks MissingAssistantMessage with the executor payload anomaly clause
  [+] E-EXE-7 blocks NullAssistantMessage with the executor payload anomaly clause
  [+] E-EXE-7 blocks NonStringAssistantMessage with the executor payload anomaly clause
  [+] E-RA-1 blocks with exit 2 when the required artifact is missing
  [+] E-RA-2 blocks with exit 2 when -AgentName is missing
  [+] E-RA-3 blocks with exit 2 when -RequiredArtifact is missing
  [+] E-RA-4 exits 0 when the artifact is present
  [+] E-RA-5 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
  [+] E-RA-6 blocks with exit 2 when the envelope carries only an output key
  [+] E-RA-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
  [+] E-RA-8 exits 2 when hook-dependency-guard.ps1 fails to load
  [+] E-RA-9 blocks EmptyPayload with the required-artifact payload anomaly clause
  [+] E-RA-9 blocks UnparseableJson with the required-artifact payload anomaly clause
  [+] E-RA-9 blocks NonObjectEnvelope with the required-artifact payload anomaly clause
  [+] E-RA-9 blocks MissingAssistantMessage with the required-artifact payload anomaly clause
  [+] E-RA-9 blocks NullAssistantMessage with the required-artifact payload anomaly clause
  [+] E-RA-9 blocks NonStringAssistantMessage with the required-artifact payload anomaly clause
  [+] E-RA-10 calls Exit-SubagentStopBlock exactly once, outside the missing-argument if block
  [+] E-PLN-1 blocks with exit 2 when last_assistant_message lacks the PREFLIGHT: signal
  [+] E-PLN-2 blocks with exit 2 when last_assistant_message lacks the plan-path line
  [+] E-PLN-3 exits 0 when both are present with a contract-valid plan fixture
  [+] E-PLN-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails
  [+] E-PLN-5 blocks with exit 2 when the envelope carries only an output key
  [+] E-PLN-6 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true
  [+] E-PLN-7 blocks EmptyPayload with the planner payload anomaly clause
  [+] E-PLN-7 blocks UnparseableJson with the planner payload anomaly clause
  [+] E-PLN-7 blocks NonObjectEnvelope with the planner payload anomaly clause
  [+] E-PLN-7 blocks MissingAssistantMessage with the planner payload anomaly clause
  [+] E-PLN-7 blocks NullAssistantMessage with the planner payload anomaly clause
  [+] E-PLN-7 blocks NonStringAssistantMessage with the planner payload anomaly clause
  [+] X-1 invalid envelope blocks once
  [+] X-2 empty assistant text blocks always
  [+] X-3 missing plan-path blocks always
  [+] X-4 missing plan file blocks always
  [+] X-5 non-canonical preflight blocked text blocks always
  [+] X-6 missing preflight signal blocks always
  [+] X-7 non-preflight blocked report blocks once
  [+] X-8 plan without task checkboxes blocks once
  [+] X-9 unchecked task blocks always
  [+] X-10 missing AC Status Summary blocks always
  [+] X-11 missing command evidence blocks always
  [+] X-12 missing per-language status line blocks always
  [+] X-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
  [+] P-1 invalid envelope blocks once
  [+] P-2 empty assistant text blocks always
  [+] P-3 missing preflight signal blocks always
  [+] P-4 missing plan-path blocks always
  [+] P-5 missing plan file blocks always
  [+] P-6 plan structure violations block always
  [+] P-7 planner internal review violations block always
  [+] P-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
  [+] R-1 missing -AgentName blocks once through the inline tail
  [+] R-2 invalid envelope blocks once
  [+] R-3 empty assistant text blocks always
  [+] R-4 malformed artifact spec blocks once
  [+] R-5 missing artifact token blocks always
  [+] R-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result
  [+] REG-1 discovers exactly nine SubagentStop registrations of E2 hooks
  [+] REG-2 every argument name passed by a registration exists in the target script param block
  [+] REG-3 Invoke-OrchestratorOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
  [+] REG-3 Invoke-ExecutorOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
  [+] REG-3 Invoke-PlannerOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
  [+] REG-3 Invoke-RequiredArtifactOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
  [+] REG-4 validate-orchestrator-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
  [+] REG-4 validate-executor-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
  [+] REG-4 validate-planner-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
  [+] REG-4 validate-required-artifact-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
  [+] B1: SubagentStop .claude/hooks/validate-planner-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
  [+] C8: .claude/hooks/validate-planner-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail

TotalCount=1216
PassedCount=1216
FailedCount=0
FailedContainersCount=0
