# #792 Offenders ([P4-T1])

Timestamp: 2026-10-09T23-16
Command: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 (re-run; stdout-guard-offenders.md reads none)
EXIT_CODE: 0
Output Summary: no offenders, so no file was edited, no R-INSTALL group ran, and no mirror was copied; the re-run reports 25 passed, 0 failed, with N1 (repository and mirror) and N2 on PASSED lines.

Offender handling: no offenders (stdout-guard-offenders.md reads none).

Runner output:

```text

Starting discovery in 1 files.
Discovery found 25 tests in 125ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1 13.58s (13.2s|279ms)
Tests completed in 13.59s
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
