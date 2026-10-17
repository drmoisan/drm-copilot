# P5-T7 Pester regression and back-compat suites after the fix

Timestamp: 2026-09-30T10-49
Command: $r=Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
Route: PowerShell execution route (scratchpad .sh file calling pwsh -NoProfile -Command, run with sh).
EXIT_CODE: 0
Output Summary:
- Printed line: `Passed=92 Failed=0` (EXIT_CODE is `$r.FailedCount`).
- 92 = 21 regression cases + 43 parity cases + 28 back-compat cases. The 28 back-compat cases captured in Phase 1 remain green against the modified module, and the 17 failures recorded in `pester-expect-fail.md` now pass.
