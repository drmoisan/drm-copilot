# Pester Line-Coverage Baseline for OrchestratorStateReceipts.psm1 (P0-T30)

Timestamp: 2026-10-01T21-13
Task: P0-T30
Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6, Pester 5.6.1)

Command: $c=New-PesterConfiguration; $c.Run.Path=@('tests/scripts/claude-lib/orchestrator-state'); $c.Run.PassThru=$true; $c.CodeCoverage.Enabled=$true; $c.CodeCoverage.Path=@('.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1'); $c.CodeCoverage.OutputFormat='JaCoCo'; $c.CodeCoverage.OutputPath='artifacts/pester/coverage-484-receipts-baseline.xml'; $r=Invoke-Pester -Configuration $c; [xml]$x=Get-Content -Raw -LiteralPath artifacts/pester/coverage-484-receipts-baseline.xml; $l=$x.report.counter | Where-Object { $_.type -eq 'LINE' }; "Passed=$($r.PassedCount) Failed=$($r.FailedCount) LineCovered=$($l.covered) LineMissed=$($l.missed)"
EXIT_CODE: 38

## Output Summary:

- Printed line: `Passed=523 Failed=38 LineCovered=113 LineMissed=0`
- Pester summary: `Tests Passed: 523, Failed: 38, Skipped: 0, Inconclusive: 0, NotRun: 0`; Pester reported `Covered 100% / 75%. 170 analyzed Commands in 1 File.`
- Line percent for OrchestratorStateReceipts.psm1: 113/(113+0) = 100.00%.
- Coverage file present: `artifacts/pester/coverage-484-receipts-baseline.xml` (tool output only).
- Pre-existing failures (38), all in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`, each with `CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized` raised from `Invoke-Adoption` (test line 92). `OrchestratorStateIssueAdoption.Parity.Tests.ps1` passed in the same run. The failing groups:
  - `Issue adoption accepts valid records (AC-6)`: 10 tests
  - `Issue adoption rejects malformed records (AC-7)`: 20 tests
  - `Issue adoption enforces the closed waivable set (AC-8)`: 6 tests
  - `Issue adoption fails closed and is presence gated (AC-9, AC-11)`: 2 tests
- None of the failing tests exercise OrchestratorStateReceipts.psm1; the root cause was not diagnosed in this task.
