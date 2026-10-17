# Pester Accounting and Parity Suites Before the Fix (P2-T11, expect-fail)

Timestamp: 2026-10-01T21-48
Task: P2-T11
Route: sh-wrapped pwsh -NoProfile -Command
Command: $r=Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
(the run additionally printed per-container counts and the first three failure messages for this artifact)
EXIT_CODE: 1
ExpectedExitCode: 1

Output:

```
Tests Passed: 55, Failed: 124, Skipped: 0, Inconclusive: 0, NotRun: 0
Passed=55 Failed=124
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 Result=Failed Passed=1 Failed=94
CONTAINER tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 Result=Failed Passed=54 Failed=30
FAILED: Get-RemediationReviewVerdict.derives the spec verdict for subset empty :: No modules named 'OrchestratorStateRemediationAccounting' are currently loaded.
```

Output Summary: `Failed=124` (greater than 0); EXIT_CODE is `[int]($r.FailedCount -gt 0)` = 1. The accounting file fails on the missing module (`OrchestratorStateRemediationAccounting.psm1` does not exist; 94 of 95 cases fail, the `InModuleScope` cases with "No modules named 'OrchestratorStateRemediationAccounting' are currently loaded" and the entry-point cases on the missing command). Its one passing case is `validates a halt checkpoint without cycles cleanly`, which asserts an empty unconditional error list that the unmodified modules already return. The parity file fails on the 30 corpus cases with non-empty `expected_errors`; its 41 name-equals-stem cases, 11 empty-expectation cases, and 2 discovery cases pass.

Toolchain status for the two new files: Invoke-Formatter reports both unchanged; Invoke-ScriptAnalyzer (pssa.settings.psd1, Error/Warning/Information) reports `Findings=0 Errors=0` for each.

Interface note for Phase 5: the accounting tests call `Get-OrchestratorStateRemediationAccountingError -RemediationLoop <loop> -Cycle <list or $null>` and, through `InModuleScope`, `Get-RemediationReviewVerdict -Remediability <class list>`. The plan names the parameters only descriptively (P5-T2), so these parameter names are fixed by the tests.
