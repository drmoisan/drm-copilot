Timestamp: 2026-11-05T05-34
Started: 2026-11-05T05:34:26.2251842Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-prove-mock-mechanics.sh
EXIT_CODE: 0
Output Summary:

```text
Pester v6.2.0

Running tests from 1 files.

Running tests from '<ScriptBlock>:SCRATCH\issue-1082-prove-mock-mechanics.ps1:3'
Describing Native Pester 6 forwarding and fallback mechanics
Live keys=ChildPath,Path; Path=/repo; ChildPath=source
Live keys=ChildPath,Path; Path=/repo; ChildPath=fault
  [+] forwards current mock-bound arguments through a per-test captured CmdletInfo 406ms
  [+] uses the original reader for an explicitly allowed synthetic path 58ms
  [+] lets a later scenario mock override the native default 25ms
  [+] retains the original null isolation outside the fixture path domain 26ms
Tests completed in 1.1s
Tests Passed: 4, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Mechanics result=Passed; passed=4; failed=0; notrun=0
```

Raw output: SCRATCH/issue-1082-pester6-live-arguments-and-fallback-proof.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
