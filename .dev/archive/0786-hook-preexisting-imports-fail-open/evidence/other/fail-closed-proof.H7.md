# Fail-Closed Proof H7 ([P1-T11], expect-fail)

Timestamp: 2026-10-09T22-40
Command: R-SCOPED-FILTERED with Run.Path tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 and $configuration.Filter.FullName = @('*H7 *'), and in the same script R-EXIT2 over .claude/hooks/validate-orchestrator-output.ps1 and .claude/hooks/validate-orchestrator-output-resolution.ps1 (sh <SCRATCHPAD>/r.sh proof -Id H7 ... -Exit2)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the H7 row failed (decision 0/1): the hook invoked through the & route threw the RESOLVER_IMPORT_FAILED block raised by Write-Error under $ErrorActionPreference = 'Stop' instead of exiting 2; neither file contains an exit 2 statement (EXIT2 0 and 0); PROOF_RESULT FAIL-OPEN; DECISION CONVERT (matches the planning-time finding).

HANDLER: H7
UPSTREAM: #787
HANDLER-FILES: .claude/hooks/validate-orchestrator-output.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
FAILURE-VARIABLE: $script:OrchestratorOutputResolverImportFailure
DENY-CODE: RESOLVER_IMPORT_FAILED
CITATION: guarded edges validate-orchestrator-output-resolution.ps1 (try :57-62), WorktreeItemResolution.psm1 and WorktreeRunResolution.psm1 (loop :63-71); comment :53-54, init :55 | observed init 55, catch assignments 61 and 69 (HANDLER-SITE H7, found)
CITATION: deny path | cited :385-388 (ORCHESTRATOR_CHECKPOINT_UNRESOLVED: ... (RESOLVER_IMPORT_FAILED)); tail :476-480 (Write-Error $result.Message; exit 1) under $ErrorActionPreference = 'Stop' (:49) | observed consumer 385; tail 476-480; EAP line 49
CITATION: registered hook | .claude/hooks/validate-orchestrator-output.ps1 (SubagentStop)
EXIT2: .claude/hooks/validate-orchestrator-output.ps1 | 0
EXIT2: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
DECISION_ROWS_PASSED: 0/1
CLASSIFY: H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails | NO-DECISION
PROOF_RESULT: FAIL-OPEN
DECISION: CONVERT

Runner output:

```text
PassedCount: 0
FailedCount: 1
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Failed | passed=0 | failed=1
FAILED: H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails | Expected $null or empty, because the hook must not throw (ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: NoTarget (RESOLVER_IMPORT_FAILED): WorktreeRunResolution.psm1 failed to import; no checkpoint was read.), but got ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: NoTarget (RESOLVER_IMPORT_FAILED): WorktreeRunResolution.psm1 failed to import; no checkpoint was read..
RUNNER_EXIT: 1
DECISION_ROWS_PASSED: 0/1
E_CONSTRUCTION_FAILED_LINES: 0
CLASSIFY: H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails | NO-DECISION
EXIT2: .claude/hooks/validate-orchestrator-output.ps1 | 0
EXIT2: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
PROOF_RESULT: FAIL-OPEN
DECISION: CONVERT
```
