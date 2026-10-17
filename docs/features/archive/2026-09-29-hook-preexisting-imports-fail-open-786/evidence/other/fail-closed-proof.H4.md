# Fail-Closed Proof H4 ([P1-T8])

Timestamp: 2026-10-09T22-39
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H4 *') (sh <SCRATCHPAD>/r.sh proof -Id H4 ...)
EXIT_CODE: 0
Output Summary: 2 passed, 0 failed (control 1/1, decision 1/1); no E-CONSTRUCTION failure; PROOF_RESULT FAIL-CLOSED; DECISION EXEMPT.

HANDLER: H4
UPSTREAM: #565
HANDLER-FILES: .claude/hooks/enforce-epic-wave-barrier.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
FAILURE-VARIABLE: $script:EpicWaveBarrierResolutionImportFailure
DENY-CODE: EPIC_WAVE_BARRIER_BLOCKED:
CITATION: guarded edge feature-folder-resolution.ps1 | cited init :52, comment :60-61, try :62-69, catch assignment :66-68 | observed init 52, catch assignment 67 (line 57 is the shared #690 catch), dot-source line 63 (HANDLER-SITE H4, found)
CITATION: deny path | cited :274-279, first statement of Invoke-EpicWaveBarrierDecision | observed comment 274, if 275
CITATION: registered hook | .claude/hooks/enforce-epic-wave-barrier.ps1 (PreToolUse)
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 1/1
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT

Runner output:

```text
PassedCount: 2
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=2 | failed=0
PASSED: H4 control: enforce-epic-wave-barrier.ps1 allows the W10 delegation when feature-folder-resolution.ps1 loads
PASSED: H4 enforce-epic-wave-barrier.ps1 denies that delegation with EPIC_WAVE_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
RUNNER_EXIT: 0
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 1/1
E_CONSTRUCTION_FAILED_LINES: 0
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT
```
