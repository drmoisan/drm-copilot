Timestamp: 2026-11-05T04-13
Started: 2026-11-05T04:13:37.7266307Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp\codex-container-baseline\issue-1082\issue-1082-current-powershell.sh poshqc
EXIT_CODE: 0
Output Summary:

```text
Coverage file not found; skipping Koverage output: REPO\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
  [+] returns without writing an output file and without throwing when the coverage input file does not exist on disk (line 98) 9ms

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1'
Describing Invoke-PoshQCTest shard parameters
  [+] TS01-SHARD-RUNPATH-SELECTED sets Run.Path to the full paths of this shard slice 19ms
  [+] TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM passes the manifest JSON without selectedFullPath to the seam 11ms
  [+] TS03-NO-SHARD-RUNPATH-UNCHANGED leaves Run.Path and the seam untouched when ShardCount is 0 4ms
  [+] rejects a shard index outside 1..ShardCount before Pester runs 10ms
  [+] TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON writes the manifest through Set-Content in the default WriteShardFileList seam 19ms
  [+] TS05-EMPTY-SHARD-SLICE-THROWS stops before Pester runs when the shard selects no test file 7ms
  [+] TS06-SHARD-WEIGHTED-BY-FILE-SIZE assigns the heaviest test files first to the least-loaded shard 7ms

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1'
Describing Get-PoshQCFileList
  [+] returns empty when no PowerShell files are enumerated 8ms
  [+] excludes files matched by the injected predicate 10ms
  [+] throws when the injected resolver fails 8ms
  [+] filters out non-PowerShell extensions with the injected predicate 10ms
  [+] resolves relative roots using the injected resolver 9ms

Describing Install-PoshQCTool
  [+] registers PSGallery when absent and installs required modules 18ms
  [+] logs a warning when PSGallery trust cannot be set 15ms
  [+] skips installation when required modules are already present 8ms
  [+] throws when an injected install operation fails 12ms

Describing Invoke-PoshQCFormat
  [+] writes formatter output without appending another newline 5ms
  [+] throws when PSScriptAnalyzer is missing 7ms
  [+] throws when the settings file is missing 7ms
  [+] logs and returns when no files are found 7ms
  [+] writes formatted content when the formatter changes text 28ms
  [+] performs no writes when content is unchanged 14ms

Describing Invoke-PoshQCAnalyze
  [+] throws when PSScriptAnalyzer is missing 10ms
  [+] throws when the settings file is missing 7ms
  [+] logs and returns when no files are found 8ms
  [+] throws when analyzer returns findings 13ms
  [+] retries transient NullReferenceExceptions and succeeds 17ms
  [+] fails after exhausting NullReferenceException retries 12ms
Tests completed in 7.62s
Tests Passed: 224, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0
RESULT=Passed passed=224 failed=0 skipped=7
```

Raw output: SCRATCH/issue-1082-p3-bundle-poshqc-tests.log
