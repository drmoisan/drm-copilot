Timestamp: 2026-11-05T05-58
Started: 2026-11-05T05:58:28.6662488Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-diagnose-probe-command.sh
EXIT_CODE: 1
Output Summary:

```text

Running tests from 16 files.
[+] REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 6.74s (89 tests)
[+] REPO\tests\scripts\host-tools.manifest.Tests.ps1 329ms (9 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 175ms (7 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 381ms (16 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingOutputPath.Tests.ps1 183ms (4 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 637ms (62 tests)
No PowerShell files found under REPO\tests\scripts\powershell\PoshQC
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 268ms (5 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 147ms (5 tests)
[+] REPO\tests\scripts\claude-hooks\validate-executor-output.Envelope.Tests.ps1 264ms (12 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 126ms (7 tests)
[+] REPO\tests\scripts\claude-hooks\validate-orchestrator-output.Envelope.Tests.ps1 869ms (14 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 251ms (10 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-batch-budget.RouteImportFailure.Tests.ps1 1.02s (20 tests)
[+] REPO\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 536ms (5 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 216ms (11 tests)
RESOLVER: module=EpicScopeResolution; source=REPO\.claude\lib\worktree-resolution\EpicScopeResolution.psm1
MODULE: REPO\.claude\lib\worktree-resolution\EpicScopeResolution.psm1
[-] Claude hook dependency-failure behaviour (issue #786).baseline mock interception probe 82ms
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, REPO\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:160
 at Invoke-EpicStateInterceptionProbe, REPO\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:204
 at <ScriptBlock>, SCRATCH\issue-1082-diagnostic-probe-command.Tests.ps1:137
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 time exactly, but was called 0 times
 Performed invocations:
   <none>
Tests completed in 22.8s
Tests Passed: 461, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
Diagnostic tests=462; passed=461; failed=1
```

Raw output: SCRATCH/issue-1082-pester6-probe-exact-prefix-ownership.log
