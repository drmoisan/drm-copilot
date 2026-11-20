# Pester Fixture Retarget — Green Run — [P1-T16]

Timestamp: 2026-09-07T11-51
Task: [P1-T16]

Command: `pwsh -NoProfile -Command '& { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path "tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1" -Output Detailed -PassThru; Write-Output ("RESULT={0} PASSED={1} FAILED={2}" -f $r.Result, $r.PassedCount, $r.FailedCount); if ($r.Result -ne "Passed") { exit 1 } }'`
EXIT_CODE: 0

This is the same command [P1-T14] ran, unchanged. The only difference in state is that [P1-T15] created the fixture the guard requires.

## Result (verbatim, ANSI colour codes stripped)

```
Tests Passed: 50, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
RESULT=Passed PASSED=50 FAILED=0
```

## The six expanded byte-identity case names, from the Detailed output

```
   [+] denies malformed MCP id exactly without changing checkpoint bytes
   [+] denies unrelated MCP server exactly without changing checkpoint bytes
   [+] denies unregistered MCP operation exactly without changing checkpoint bytes
   [+] denies approximate MCP operation exactly without changing checkpoint bytes
   [+] denies shell edit exactly without changing checkpoint bytes
   [+] denies production patch exactly without changing checkpoint bytes
```

All six are marked `[+]`, meaning passed.

Output Summary: The run exits 0 with `RESULT=Passed`, `PASSED=50`, and `FAILED=0`. The recorded passed count of 50 meets the at-least-45 floor and equals the value observed at plan authoring. The Detailed output shows each of the six expanded case names passing. The six cases now read the checkpoint bytes from the committed fixture rather than from the gitignored live checkpoint, so they no longer depend on a file that a fresh checkout does not contain, and each still asserts that the hook decision leaves those bytes unchanged.
