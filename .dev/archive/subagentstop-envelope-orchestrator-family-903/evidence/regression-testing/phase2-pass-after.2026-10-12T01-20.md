# Phase 2 Pass-After ([P2-T8])

Timestamp: 2026-10-12T01-20
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1,tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1,tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
EXIT_CODE: 0
Output Summary: TotalCount=1200, PassedCount=1200, FailedCount=0, FailedContainersCount=0. Passed lines present for S2-13, S2-14, H7, H8, the no-Python AST row, and the B1 routing-sibling row.

Required passed rows:
  [+] S2-13 keeps a checkpoint whose route and field keys differ only in case (CR-1)
  [+] S2-14 returns ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws (CR-3)
  [+] H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails
  [+] H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails
  [+] invokes no python, python3, py, or poetry command anywhere in the default invoker
  [+] B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-routing.ps1 when that direct edge fails

TEST_ORDER_NOTE: The file set is the [P2-T8] set unchanged; only the order differs (S-DEP-SUITES-2 first). The first run, in the plan's listed order, reported TotalCount=1200, FailedCount=2: the `baseline mock interception probe` rows of hook-dependency-failure.Claude.Tests.ps1 and hook-dependency-failure.SpecialCases.Tests.ps1 (Get-EpicScopeCheckpointText in module EpicScopeResolution called 0 times). Diagnosis:
- The two dependency suites pass when run alone (152/152).
- FailClosed followed by hook-dependency-failure.Claude.Tests.ps1 reproduces the probe failure with the edited files.
- The same reproduction occurs with the HEAD versions of FailClosed, validate-orchestrator-output.ps1, and validate-orchestrator-output-resolution.ps1 (each restored temporarily from HEAD and then put back from a saved copy).
The failure is a cross-suite module-state interaction that exists before this change. It occurs only when FailClosed runs before the dependency suites in one Pester session. The baseline full run in [P0-T12] passes because alphabetical order runs the dependency suites first. Later gates that combine these suites order S-DEP-SUITES-2 before FailClosed for the same reason.

TotalCount=1200
PassedCount=1200
FailedCount=0
FailedContainersCount=0
