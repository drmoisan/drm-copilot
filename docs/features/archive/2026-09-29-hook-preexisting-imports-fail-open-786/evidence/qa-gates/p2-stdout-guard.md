# #792 Stdout Guard Run ([P2-T5])

Timestamp: 2026-10-09T22-47
Command: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: 25 passed, 0 failed; N1 (repository and mirror), N2, N3, the 12 N4 forms, the 6 N5 forms, N6, N7, and N8 appear on PASSED lines; the offender list reads none.

Runner output:

```text

Starting discovery in 1 files.
Discovery found 25 tests in 122ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1 13.12s (12.75s|265ms)
Tests completed in 13.13s
Tests Passed: 25, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 25
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | result=Passed | passed=25 | failed=0
PASSED: N1: repository reports no success- or warning-stream write in any module or helper imported by a registered hook
PASSED: N1: mirror reports no success- or warning-stream write in any module or helper imported by a registered hook
PASSED: N2: mirror findings equal repository findings
PASSED: N3: discovers registered PreToolUse and SubagentStop hooks from both registrations
PASSED: N4: reports Write-Output as an offender
PASSED: N4: reports write as an offender
PASSED: N4: reports echo as an offender
PASSED: N4: reports Write-Host as an offender
PASSED: N4: reports Write-Information as an offender
PASSED: N4: reports Write-Warning as an offender
PASSED: N4: reports Out-Host as an offender
PASSED: N4: reports [Console]::Write as an offender
PASSED: N4: reports [Console]::WriteLine as an offender
PASSED: N4: reports [System.Console]::WriteLine as an offender
PASSED: N4: reports [Console]::Out.WriteLine as an offender
PASSED: N4: reports [System.Console]::Out.Write as an offender
PASSED: N5: does not report [Console]::Error.WriteLine
PASSED: N5: does not report a comment
PASSED: N5: does not report a string literal
PASSED: N5: does not report Write-Verbose
PASSED: N5: does not report Write-Error
PASSED: N5: does not report Write-Debug
PASSED: N6: reports an offender in a module imported transitively by a synthetic registered hook
PASSED: N7: does not report a Write-Output in a registered entry script invoked directly
PASSED: N8: does not report a Write-Output in a registered entry script dot-sourced by another hook
```
