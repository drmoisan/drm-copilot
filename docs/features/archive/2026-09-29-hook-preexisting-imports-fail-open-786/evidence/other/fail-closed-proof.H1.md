# Fail-Closed Proof H1 ([P1-T5])

Timestamp: 2026-10-09T22-38
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H1 *') (sh <SCRATCHPAD>/r.sh proof -Id H1 ...)
EXIT_CODE: 0
Output Summary: 4 passed, 0 failed (control 1/1, decision 3/3); no E-CONSTRUCTION failure; BF1-DECISION EXEMPT; PROOF_RESULT FAIL-CLOSED; DECISION EXEMPT.

HANDLER: H1
UPSTREAM: #565
HANDLER-FILES: .claude/hooks/enforce-feature-folder-order.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
FAILURE-VARIABLE: $script:FeatureFolderOrderResolutionImportFailure
DENY-CODE: FEATURE_FOLDER_ORDER_BLOCKED:
CITATION: guarded edge feature-folder-resolution.ps1 | cited init :45, try :46-51, catch assignment :50, W-HELD region :43-51 | observed init 45, catch 50 (hook-guard-worklist.md HANDLER-SITE H1, found)
CITATION: deny path | cited :210-214, reached only for a plan path (gate :205-207) | observed consumer line 210; plan-path gate line 205 returns allow (bf1-feature-folder-order-analysis.md)
CITATION: registered hook | .claude/hooks/enforce-feature-folder-order.ps1 (PreToolUse)
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 3/3
BF1_DECISION: EXEMPT
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT

Runner output:

```text
PassedCount: 4
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=4 | failed=0
PASSED: H1 control: enforce-feature-folder-order.ps1 allows a full-bug plan write whose prerequisites exist when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 denies that plan write with FEATURE_FOLDER_ORDER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H1 enforce-feature-folder-order.ps1 calls no resolver function for a non-plan write when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 returns the same allow for a non-plan write whether or not feature-folder-resolution.ps1 loads
RUNNER_EXIT: 0
CONTROL_ROWS_PASSED: 1/1
DECISION_ROWS_PASSED: 3/3
E_CONSTRUCTION_FAILED_LINES: 0
PROOF_RESULT: FAIL-CLOSED
DECISION: EXEMPT
```
