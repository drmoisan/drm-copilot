Timestamp: 2026-11-05T06-20
Started: 2026-11-05T06:18:51.3396954Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-shuffled-pester.sh -Seed 1083
EXIT_CODE: 0
Output Summary:

```text
Formatted: /repo/test.ps1
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
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.78s (33 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 13.11s (186 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 177ms (10 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-batch-budget.RouteImportFailure.Tests.ps1 797ms (20 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-file-size-limit.Tests.ps1 377ms (33 tests)
[+] REPO\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.61s (19 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.83s (15 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 153ms (21 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 240ms (11 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1 1.57s (26 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 4.12s (19 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 121ms (7 tests)
Coverage file not found; skipping Koverage output: REPO\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 115ms (4 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 333ms (2 tests)
[+] REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 7.82s (89 tests)
No PowerShell files found under REPO\tests\scripts\powershell\PoshQC
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 145ms (5 tests)
[+] REPO\tests\scripts\claude-hooks\validate-required-artifact-output.Envelope.Tests.ps1 354ms (15 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingOutputPath.Tests.ps1 139ms (4 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 449ms (21 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 331ms (31 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 116ms (5 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.43s (21 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 1.48s (23 tests)
[+] REPO\tests\scripts\dev-tools\HostBootstrap.Invoke.Tests.ps1 3.88s (25 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 522ms (11 tests)
[+] REPO\tests\scripts\claude-hooks\validate-task-researcher-output.Coverage.Tests.ps1 2.08s (66 tests)
Tests completed in 58.64s
Tests Passed: 899, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0
Seed=1083; result=Passed; discovered=906; passed=899; failed=0; skipped=7; notrun=0
Recorded file order: ["tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1","tests/scripts/host-tools.manifest.Tests.ps1","tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1","tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1","tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1","tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1","tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1","tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1","tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1","tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1","tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1","tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1","tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1","tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1","tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1","tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1","tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1","tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1","tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1","tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1","tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1","tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1"]
```

Raw output: SCRATCH/issue-1082-isolation-pester-seed-1083-final.log
