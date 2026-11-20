# Fail-Closed Proof H5 ([P1-T9])

Timestamp: 2026-10-09T22-39
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H5 *') (sh <SCRATCHPAD>/r.sh proof -Id H5 ...)
EXIT_CODE: 0
Output Summary: 2 passed, 0 failed (control 1/1, decision 1/1); no E-CONSTRUCTION failure; PROOF_RESULT FAIL-CLOSED; DECISION EXEMPT.

HANDLER: H5
UPSTREAM: #565
HANDLER-FILES: .claude/hooks/enforce-parallel-drift-gate.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
FAILURE-VARIABLE: $script:ParallelDriftGateResolutionImportFailure
DENY-CODE: PARALLEL_DRIFT_GATE_BLOCKED:
CITATION: guarded edge feature-folder-resolution.ps1 | cited init :77, comment :87-88, try :89-94, catch :92-93 | observed init 77, catch assignment 93, dot-source line 90 (HANDLER-SITE H5, found)
CITATION: deny path | cited :321-326 | observed comment 321, if 322
CITATION: registered hook | .claude/hooks/enforce-parallel-drift-gate.ps1 (PreToolUse)
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
PASSED: H5 control: enforce-parallel-drift-gate.ps1 allows the D1 delegation when feature-folder-resolution.ps1 loads
PASSED: H5 enforce-parallel-drift-gate.ps1 denies that delegation with PARALLEL_DRIFT_GATE_BLOCKED: when feature-folder-resolution.ps1 fails to load
RUNNER_EXIT: 0
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 1/1
E_CONSTRUCTION_FAILED_LINES: 0
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT
```
