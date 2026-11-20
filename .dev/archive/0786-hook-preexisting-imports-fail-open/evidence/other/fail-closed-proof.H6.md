# Fail-Closed Proof H6 ([P1-T10])

Timestamp: 2026-10-09T22-39
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H6 *') (sh <SCRATCHPAD>/r.sh proof -Id H6 ...)
EXIT_CODE: 0
Output Summary: 2 passed, 0 failed (control 1/1, decision 1/1); no E-CONSTRUCTION failure; PROOF_RESULT FAIL-CLOSED; DECISION EXEMPT.

HANDLER: H6
UPSTREAM: #565
HANDLER-FILES: .claude/hooks/enforce-parallel-cohort-barrier.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
FAILURE-VARIABLE: $script:ParallelCohortBarrierResolutionImportFailure
DENY-CODE: PARALLEL_COHORT_BARRIER_BLOCKED:
CITATION: guarded edge feature-folder-resolution.ps1 | cited init :66, comment :76-77, try :78-85, catch :81-84 | observed init 66, catch assignment 83, dot-source line 79 (HANDLER-SITE H6, found)
CITATION: deny path | cited :239-244 | observed comment 239, if 240
CITATION: registered hook | .claude/hooks/enforce-parallel-cohort-barrier.ps1 (PreToolUse)
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
PASSED: H6 control: enforce-parallel-cohort-barrier.ps1 allows the C1 delegation when feature-folder-resolution.ps1 loads
PASSED: H6 enforce-parallel-cohort-barrier.ps1 denies that delegation with PARALLEL_COHORT_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
RUNNER_EXIT: 0
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 1/1
E_CONSTRUCTION_FAILED_LINES: 0
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT
```
