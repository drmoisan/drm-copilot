# Targeted Pester Line Coverage, OrchestratorStateReceipts.psm1 (P10-T7)

Timestamp: 2026-10-01T23-04
Task: P10-T7
Loop iteration: 2
Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6, Pester 5.6.1)

Command: $c=New-PesterConfiguration; $c.Run.Path=@('tests/scripts/claude-lib/orchestrator-state'); $c.Run.PassThru=$true; $c.CodeCoverage.Enabled=$true; $c.CodeCoverage.Path=@('.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1'); $c.CodeCoverage.OutputFormat='JaCoCo'; $c.CodeCoverage.OutputPath='artifacts/pester/coverage-484-receipts-final.xml'; $r=Invoke-Pester -Configuration $c; [xml]$x=Get-Content -Raw -LiteralPath artifacts/pester/coverage-484-receipts-final.xml; $l=$x.report.counter | Where-Object { $_.type -eq 'LINE' }; "Passed=$($r.PassedCount) Failed=$($r.FailedCount) LineCovered=$($l.covered) LineMissed=$($l.missed)"
EXIT_CODE: 38
ExpectedExitCode: 38

## Output Summary:

- Printed: `Passed=736 Failed=38 LineCovered=117 LineMissed=0`
- Pester: `Tests Passed: 736, Failed: 38`; `Covered 100% / 75%. 174 analyzed Commands in 1 File.`
- Line percent: 117/(117+0) = 1.0000 (100.00%), at least 0.85 and not below the P0-T30 value (113/113 = 100.00%).
- The 38 failures are the P0-T30 pre-existing `OrchestratorStateIssueAdoption.Tests.ps1` set, unchanged (same four groups 10/20/6/2, all 38 with `The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized`). P0-T30 recorded `Passed=523 Failed=38`; the passed count rose by 213 from the new Pester suites.
- The literal `Failed=0` acceptance is not met because of these pre-existing, out-of-scope (#509) failures; evaluated under deviation D10 with ExpectedExitCode 38 authorized by P0-T30.
