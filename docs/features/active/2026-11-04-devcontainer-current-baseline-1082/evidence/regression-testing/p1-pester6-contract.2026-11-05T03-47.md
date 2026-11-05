Timestamp: 2026-11-05T03-47
Started: 2026-11-05T03:47:41.3525823Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-powershell-launch.sh pester6-contract
EXIT_CODE: 0
Output Summary:

```text
Selected Pester: 6.2.0
Pester v6.2.0

Running tests from 2 files.

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1'
Describing PoshQC shipped Pester runsettings (issue #953)
  [+] RS01-RUNSETTINGS-PROFILER-MODE sets UseBreakpoints to false and keeps the coverage keys 92ms
  [+] RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE builds a Pester configuration whose UseBreakpoints value is false 5ms

Describing Install-PoshQCTool Pester minimum (issue #953)
  [+] RS03-INSTALLER-PESTER-620 passes Pester version 6.2.0 to the injected install seam 29ms
  [+] RS05-INSTALLER-PESTER-CEILING-BELOW-7 installs Pester 6.2.0 when only Pester 7.0.0 is present 14ms

Describing Invoke-PoshQCTest Pester import ceiling (issue #953)
  [+] RS06-TEST-IMPORT-PESTER-MAXIMUM imports Pester with MaximumVersion 6.99.99 through the default EnsureModule seam 292ms

Describing Invoke-PoshQCTest Pester presence check and import range (issue #953, CR-1, CR-2)
  [+] RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS queries and imports Pester with minimum 6.2.0 and maximum 6.99.99 43ms
  [+] RS09-TEST-PESTER-7-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 7.0.0 is installed 54ms
  [+] RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 3.4.0 is installed 26ms
Filter 'FullName' set to ('*RS01-*', '*RS02-*', '*RS03-*', '*RS05-*', '*RS06-*', '*RS08-*', '*RS09-*', '*RS10-*', '*Invoke-PoshQCTest default*').
Filters selected 11 tests to run.

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1'
Describing Invoke-PoshQCTest default $InvokePester seam (issue #392)
  [+] defines function:global:Invoke-PoshQCPesterRun during the run, removes it after, and returns the result unmodified 18ms

Describing Invoke-PoshQCTest default $EnsureModule seam (issue #392)
  [+] imports the requested module with -Global 31ms
  [+] throws the supplied error when the module is unavailable 14ms
Tests completed in 1.29s
Tests Passed: 11, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 3
Pester6 contract: passed=11,failed=0,notrun=3
```

Raw output: SCRATCH/issue-1082-p1-pester6-contract.log
