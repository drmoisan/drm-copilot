# Pester Regression, Parity, Back-Compat, and Existing Suites After the Fix (P5-T11)

Timestamp: 2026-10-01T22-39
Task: P5-T11
Route: sh-wrapped pwsh -NoProfile -Command (scratchpad script outside the repository)
Command: $r=Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
(the run additionally printed per-container counts for this artifact)
EXIT_CODE: 0

Output:

```
Tests Passed: 272, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Passed=272 Failed=0
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 Result=Passed Passed=95 Failed=0
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 Result=Passed Passed=84 Failed=0
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 Result=Passed Passed=34 Failed=0
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 Result=Passed Passed=40 Failed=0
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 Result=Passed Passed=19 Failed=0
```

(container paths rendered repository-relative)

Output Summary: `Failed=0`, `Passed=272`; EXIT_CODE is `$r.FailedCount` = 0. The two Phase 2 suites that failed before the fix (P2-T11: `Passed=55 Failed=124`) now pass in full (accounting 95, parity 84); the back-compat suite still passes all 34 cases; the existing receipts and unconditional suites pass. The accounting suite runs with the `BeforeAll` import order recorded under deviation D5.
