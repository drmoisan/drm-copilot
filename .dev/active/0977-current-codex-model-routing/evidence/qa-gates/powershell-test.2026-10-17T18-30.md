Timestamp: 2026-10-17T18:30:38.369337+00:00
Command: & 'SCRATCH/issue-977-full-pester.ps1'
EXIT_CODE: 0
Output Summary:

RUN_METADATA: fresh single-process Pester PID=14788; process_started_at=2026-10-17T18:15:59.2585443Z; configured test scan includes scripts and tests/scripts; full config-derived coverage population; all 844 repository PowerShell-file hashes captured in SCRATCH/issue-977-final-pester-identity.json.
Coverage root attributes: {'name': 'Pester (10/17/2026 18:27:32)'}
TOTAL: lines 17730/19142 (92.6236%).
./.claude/lib/codex-routing/CodexDeployment.psm1: lines 68/68 (100.0000%).
./.codex/hooks/record-subagent-routing-attestation.ps1: lines 189/204 (92.6471%).
JUnit root attributes: {'{http://www.w3.org/2001/XMLSchema-instance}noNamespaceSchemaLocation': 'junit_schema_4.xsd', 'name': 'Pester', 'tests': '11320', 'errors': '0', 'failures': '0', 'disabled': '10', 'time': '681.729'}
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.48s (1.28s|171ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 386ms (311ms|46ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 182ms (122ms|44ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageMerge.Tests.ps1 212ms (148ms|48ms)
No PowerShell files found under .\tests\scripts\powershell\PoshQC
[+] .\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 180ms (111ms|53ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 145ms (71ms|59ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 248ms (175ms|56ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 133ms (63ms|57ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 369ms (250ms|99ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Shard.Tests.ps1 284ms (202ms|63ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCommands.Tests.ps1 213ms (144ms|52ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 184ms (136ms|33ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 129ms (83ms|32ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 104ms (58ms|33ms)
Coverage file not found; skipping Koverage output: .\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 164ms (73ms|50ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1 137ms (92ms|33ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 236ms (140ms|80ms)
[+] .\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 385ms (267ms|97ms)
[+] .\tests\scripts\workflows\CiWorkflow.Tests.ps1 121ms (81ms|28ms)
[+] .\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 129ms (62ms|54ms)
[+] .\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 124ms (66ms|45ms)
[+] .\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 77ms (18ms|47ms)
Tests completed in 681.73s
Tests Passed: 11310, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 91.83% / 0%. 28,075 analyzed Commands in 215 Files.

Full sanitized output: SCRATCH/issue-977-qa-gates-powershell-test.log
