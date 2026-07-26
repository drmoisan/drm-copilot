# [expect-fail] New Readiness Test Against the Unedited Module (Issue #412, Cycle 1)

Timestamp: 2026-07-25T20-05

Status: `[expect-fail]`. Exactly one failing test — the [P1-T1] test — is the expected outcome for
this task. The production module has not yet been edited.

Command: `pwsh -NoProfile -Command "Set-Location 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585'; $r = Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state -Output Detailed -PassThru; Write-Host ('SUMMARY Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' Skipped=' + $r.SkippedCount); if ($r.FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1

## Result

```
Pester v5.6.1
Starting discovery in 3 files.
Discovery found 54 tests in 214ms.
Tests completed in 2.01s
Tests Passed: 53, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
SUMMARY Passed=53 Failed=1 Skipped=0
```

## The single failing test

```
   [-] returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit 50ms (48ms|1ms)
    at $result.ExitCode | Should -Be 1, ...\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1:143
    at <ScriptBlock>, ...\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1:143
    Expected 1, but got 0.
```

`Expected 1, but got 0` is the F-1 fail-open expressed through the public entry point
`Test-OrchestratorStatePrCreationReadiness`: the readiness gate returns no error, so `ExitCode` is
0 and PR creation would be permitted.

## Pre-existing tests

Discovery found 54 tests (53 pre-existing + the 1 new). 53 passed, 1 failed. Every pre-existing test
passed, including the three cases [P1-T1] was required to leave untouched:

- `[+] returns ExitCode 1 when a readiness step is pending`
- `[+] returns ExitCode 1 when a readiness step is blocked`
- `[+] accepts step6_status value blocked_remediation_loop_limit` (base-validation acceptance)

Output Summary: **EXIT_CODE 1**, `SUMMARY Passed=53 Failed=1 Skipped=0`. Exactly one failure, and it
is the [P1-T1] test `returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit`
failing with `Expected 1, but got 0`. All 53 pre-existing tests pass, so the new test isolates the
F-1 defect and introduces no collateral breakage. The non-zero exit came from the explicit
`if ($r.FailedCount -gt 0) { exit 1 }` branch, because a bare `Invoke-Pester` exits 0 even when
tests fail; `-CI` was not used, so the tracked repo-root `testResults.xml` was not rewritten.
