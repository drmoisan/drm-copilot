Timestamp: 2026-11-05T05-27
Started: 2026-11-05T05:27:10.2447521Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-diagnose-bb4.sh
EXIT_CODE: 0
Output Summary:

```text
Pester v6.2.0

Running tests from 1 files.
Filter 'FullName' set to ('*BB4*').
Filters selected 4 tests to run.

Running tests from 'SCRATCH\issue-1082-bb4-diagnostic.Tests.ps1'
Describing enforce-python-batch-budget.ps1 route helper import failure on the repository root (#984)
  [+] BB4 enforce-python-batch-budget.ps1 emits no deny for src/app.ts through the & route when enforce-batch-budget-route.ps1 fails to load (#984) 458ms

Describing enforce-powershell-batch-budget.ps1 route helper import failure on the repository root (#984)
  [+] BB4 enforce-powershell-batch-budget.ps1 emits no deny for src/app.py through the & route when enforce-batch-budget-route.ps1 fails to load (#984) 111ms

Describing enforce-python-batch-budget.ps1 route helper import failure on the mirror root (#984)
  [+] BB4 enforce-python-batch-budget.ps1 emits no deny for src/app.ts through the & route when enforce-batch-budget-route.ps1 fails to load (#984) 59ms

Describing enforce-powershell-batch-budget.ps1 route helper import failure on the mirror root (#984)
  [+] BB4 enforce-powershell-batch-budget.ps1 emits no deny for src/app.py through the & route when enforce-batch-budget-route.ps1 fails to load (#984) 71ms
Tests completed in 1.61s
Tests Passed: 4, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 16
Diagnostic cases: 20; failed=0
```

Raw output: SCRATCH/issue-1082-pester6-bb4-captured-native-diagnostic.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
