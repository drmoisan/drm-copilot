# Remediation Cycle 1 — Target Test File Before the Fix (P0-T3, expect-fail)

Timestamp: 2026-09-30T15-37
Command: $r=Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; @($r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedName }); @($r.Failed | ForEach-Object { $_.ErrorRecord | ForEach-Object { 'MESSAGE: ' + $_.Exception.Message } })
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `Passed=7 Failed=1`. Exactly one failing case: `the orchestrator-state module keeps its four hundred ninety-nine line count` (assertion `$lineCount | Should -Be 499` at line 163; observed 492). EXIT_CODE is `$r.FailedCount` and equals ExpectedExitCode.

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`).

## Printed lines

```
Passed=7 Failed=1
FAILED: the orchestrator-state module keeps its four hundred ninety-nine line count
MESSAGE: Expected 499, but got 492.
```

Pester discovery reported 8 tests in 1 file.
