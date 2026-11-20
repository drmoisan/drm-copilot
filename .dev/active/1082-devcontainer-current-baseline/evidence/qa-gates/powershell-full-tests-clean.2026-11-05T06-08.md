Timestamp: 2026-11-05T06-08
Started: 2026-11-05T05:44:43.8026240Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-final-pester.sh full -TargetRoot SCRATCH\stage\current-source
EXIT_CODE: 8
Output Summary:

```text
Already formatted: /repo/test.ps1
PSScriptAnalyzer passed: no findings under /repo
PSScriptAnalyzer passed: no findings under /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 2.65s (33 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 982ms (13 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 608ms (17 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.CoverageMerge.Tests.ps1 615ms (9 tests)
No PowerShell files found under SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 455ms (5 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 364ms (5 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ParallelMerge.Tests.ps1 450ms (12 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ParallelRunner.Tests.ps1 931ms (11 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 586ms (10 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 433ms (14 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 1.37s (17 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.Shard.Tests.ps1 715ms (16 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.ShardWeights.Tests.ps1 353ms (7 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingCommands.Tests.ps1 535ms (13 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 277ms (4 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 230ms (5 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 151ms (3 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingOutputPath.Tests.ps1 227ms (4 tests)
Coverage file not found; skipping Koverage output: SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 237ms (4 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1 264ms (7 tests)
[+] SCRATCH\stage\current-source\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 548ms (21 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 640ms (40 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\CiRequiredGateWorkflow.Tests.ps1 175ms (5 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\CiWorkflow.Tests.ps1 214ms (4 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 269ms (15 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 243ms (11 tests)
[+] SCRATCH\stage\current-source\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 114ms (4 tests)
Tests completed in 1137.27s
Tests Passed: 14280, Failed: 8, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 92.67% / 0%. 38,203 analyzed Commands in 271 Files.
```

Raw output: SCRATCH/issue-1082-powershell-full-tests-clean.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
