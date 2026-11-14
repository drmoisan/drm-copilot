Timestamp: 2026-11-05T06-08
Started: 2026-11-05T06:08:00.4913728Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-shuffled-pester.sh -Seed 1084
EXIT_CODE: 0
Output Summary:

```text
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
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.5s (33 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 356ms (31 tests)
[+] REPO\tests\scripts\claude-hooks\validate-executor-output.Envelope.Tests.ps1 247ms (12 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 290ms (11 tests)
[+] REPO\tests\scripts\claude-hooks\validate-orchestrator-output.Envelope.Tests.ps1 882ms (14 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-file-size-limit.Tests.ps1 451ms (33 tests)
[+] REPO\tests\scripts\host-tools.manifest.Tests.ps1 276ms (9 tests)
[+] REPO\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.87s (19 tests)
[+] REPO\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 404ms (8 tests)
No PowerShell files found under REPO\tests\scripts\powershell\PoshQC
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 132ms (5 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 182ms (11 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 209ms (21 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.63s (15 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-batch-budget.RouteImportFailure.Tests.ps1 742ms (20 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingOutputPath.Tests.ps1 111ms (4 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 9.85s (186 tests)
[+] REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 4.06s (89 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 149ms (10 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 578ms (23 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 252ms (17 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1 753ms (26 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 2.95s (19 tests)
[+] REPO\tests\scripts\claude-hooks\validate-task-researcher-output.Coverage.Tests.ps1 792ms (66 tests)
[+] REPO\tests\scripts\dev-tools\HostBootstrap.Invoke.Tests.ps1 2.33s (25 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 105ms (7 tests)
Coverage file not found; skipping Koverage output: REPO\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 90ms (4 tests)
[+] REPO\tests\scripts\claude-hooks\validate-required-artifact-output.Envelope.Tests.ps1 225ms (15 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 86ms (5 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 80ms (7 tests)
Tests completed in 43.69s
Tests Passed: 897, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0
Seed=1084; result=Passed; discovered=904; passed=897; failed=0; skipped=7; notrun=0
Recorded file order: ["tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1","tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1","tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1","tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1","tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1","tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1","tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1","tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1","tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1","tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1","tests/scripts/host-tools.manifest.Tests.ps1","tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1","tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1","tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1","tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1","tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1","tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1","tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1","tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1","tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1"]
```

Raw output: SCRATCH/issue-1082-isolation-pester-seed-1084-corrected.log
