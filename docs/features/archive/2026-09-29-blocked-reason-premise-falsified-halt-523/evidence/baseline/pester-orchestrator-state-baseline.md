# Pester Baseline with Line Coverage for OrchestratorState.psm1 (P0-T22)

Timestamp: 2026-09-30T14-31
Command: $c=New-PesterConfiguration; $c.Run.Path=@('tests/scripts/claude-lib/orchestrator-state'); $c.Run.PassThru=$true; $c.CodeCoverage.Enabled=$true; $c.CodeCoverage.Path=@('.claude/lib/orchestrator-state/OrchestratorState.psm1'); $c.CodeCoverage.OutputFormat='JaCoCo'; $c.CodeCoverage.OutputPath='artifacts/pester/coverage-523-baseline.xml'; $r=Invoke-Pester -Configuration $c; [xml]$x=Get-Content -Raw -LiteralPath artifacts/pester/coverage-523-baseline.xml; $l=$x.report.counter | Where-Object { $_.type -eq 'LINE' }; "Passed=$($r.PassedCount) Failed=$($r.FailedCount) LineCovered=$($l.covered) LineMissed=$($l.missed)"
EXIT_CODE: 0
Output Summary: `Passed=395 Failed=0 LineCovered=109 LineMissed=0`.
- Line percent covered/(covered+missed): 109/109 = 100.00%
- Pester summary: `Tests Passed: 395, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; command coverage `Covered 100% / 75%. 166 analyzed Commands in 1 File.` (informational)
- Coverage file written: `artifacts/pester/coverage-523-baseline.xml`
- `EXIT_CODE:` is `$r.FailedCount` (0).

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`).
