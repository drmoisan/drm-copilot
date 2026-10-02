# Remediation Cycle 1 — Target Test File After the Fix (P1-T4)

Timestamp: 2026-09-30T15-39
Command: $r=Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; @($r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedName }); @($r.Passed | Where-Object { $_.ExpandedName -ceq 'the orchestrator-state module stays within the 500-line file cap' }).Count
EXIT_CODE: 0
Output Summary: `Passed=8 Failed=0`; no `FAILED:` line; last printed line `1` (the renamed row `the orchestrator-state module stays within the 500-line file cap` ran and passed). EXIT_CODE is `$r.FailedCount`.

Execution route: PowerShell execution route (scratchpad `.sh` file calling `pwsh -NoProfile -Command '<command text>'`, run with `sh`).

## Printed lines

```
Passed=8 Failed=0
1
```

Pester discovery reported 8 tests in 1 file. Fail-before evidence: `evidence/regression-testing/r1-cap-test-before.md` (`Passed=7 Failed=1`).
