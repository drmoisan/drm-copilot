Timestamp: 2026-11-05T03-51
Started: 2026-11-05T03:50:57.6425020Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-powershell-launch.sh pester6-poshqc
EXIT_CODE: 1
Output Summary:

```text
Coverage file not found; skipping Koverage output: REPO\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
  [+] returns without writing an output file and without throwing when the coverage input file does not exist on disk (line 98) 7ms

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1'
Describing Invoke-PoshQCTest shard parameters
  [+] TS01-SHARD-RUNPATH-SELECTED sets Run.Path to the full paths of this shard slice 21ms
  [+] TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM passes the manifest JSON without selectedFullPath to the seam 11ms
  [+] TS03-NO-SHARD-RUNPATH-UNCHANGED leaves Run.Path and the seam untouched when ShardCount is 0 4ms
  [+] rejects a shard index outside 1..ShardCount before Pester runs 10ms
  [+] TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON writes the manifest through Set-Content in the default WriteShardFileList seam 20ms
  [+] TS05-EMPTY-SHARD-SLICE-THROWS stops before Pester runs when the shard selects no test file 8ms
  [+] TS06-SHARD-WEIGHTED-BY-FILE-SIZE assigns the heaviest test files first to the least-loaded shard 7ms

Running tests from 'REPO\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1'
Describing Get-PoshQCFileList
  [+] returns empty when no PowerShell files are enumerated 5ms
  [+] excludes files matched by the injected predicate 6ms
  [+] throws when the injected resolver fails 4ms
  [+] filters out non-PowerShell extensions with the injected predicate 6ms
  [+] resolves relative roots using the injected resolver 6ms

Describing Install-PoshQCTool
  [+] registers PSGallery when absent and installs required modules 12ms
  [+] logs a warning when PSGallery trust cannot be set 10ms
  [+] skips installation when required modules are already present 6ms
  [+] throws when an injected install operation fails 9ms

Describing Invoke-PoshQCFormat
  [+] writes formatter output without appending another newline 3ms
  [+] throws when PSScriptAnalyzer is missing 4ms
  [+] throws when the settings file is missing 6ms
  [+] logs and returns when no files are found 6ms
  [+] writes formatted content when the formatter changes text 20ms
  [+] performs no writes when content is unchanged 9ms

Describing Invoke-PoshQCAnalyze
  [+] throws when PSScriptAnalyzer is missing 6ms
  [+] throws when the settings file is missing 5ms
  [+] logs and returns when no files are found 6ms
  [+] throws when analyzer returns findings 9ms
  [+] retries transient NullReferenceExceptions and succeeds 14ms
  [+] fails after exhausting NullReferenceException retries 10ms
Tests completed in 6.56s
Tests Passed: 211, Failed: 3, Skipped: 7, Inconclusive: 0, NotRun: 0
Pester6 PoshQC: passed=211,failed=3,result=Failed
```

Raw output: SCRATCH/issue-1082-p1-pester6-poshqc.log
