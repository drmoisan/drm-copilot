Timestamp: 2026-10-17T17:52:28.229855+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root .
EXIT_CODE: 0
Output Summary:

Coverage root attributes: {'name': 'Pester (10/17/2026 17:49:39)'}
JUnit root attributes: {'{http://www.w3.org/2001/XMLSchema-instance}noNamespaceSchemaLocation': 'junit_schema_4.xsd', 'name': 'Pester', 'tests': '11281', 'errors': '0', 'failures': '0', 'disabled': '10', 'time': '678.355'}
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 449ms (343ms|76ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 225ms (144ms|66ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageMerge.Tests.ps1 178ms (125ms|35ms)
No PowerShell files found under .\tests\scripts\powershell\PoshQC
[+] .\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 204ms (143ms|45ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 125ms (85ms|28ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 244ms (166ms|64ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 115ms (61ms|43ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 339ms (242ms|79ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Shard.Tests.ps1 256ms (187ms|54ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCommands.Tests.ps1 212ms (137ms|60ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 174ms (132ms|32ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 122ms (69ms|42ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 106ms (66ms|31ms)
Coverage file not found; skipping Koverage output: .\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 142ms (89ms|42ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1 149ms (91ms|39ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 268ms (175ms|78ms)
[+] .\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 359ms (266ms|76ms)
[+] .\tests\scripts\workflows\CiWorkflow.Tests.ps1 105ms (63ms|31ms)
[+] .\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 121ms (52ms|58ms)
[+] .\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 108ms (50ms|48ms)
[+] .\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 48ms (14ms|24ms)
Tests completed in 678.36s
Tests Passed: 11271, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 91.5% / 0%. 28,048 analyzed Commands in 215 Files.
Wrote Koverage coverage copy: .\artifacts\pester\powershell-coverage.koverage.xml

Full sanitized output: SCRATCH/issue-977-baseline-powershell-test.log

Measured LINE counters:
TOTAL: lines 17644/19130 (92.2321%).
./.claude/lib/codex-routing/CodexDeployment.psm1: lines 68/68 (100.0000%).
./.codex/hooks/record-subagent-routing-attestation.ps1: lines 103/192 (53.6458%).
Host completed reporting normally with actual exit 0 before a contemplated stop; no process was terminated.
