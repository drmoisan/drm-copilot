Timestamp: 2026-11-05T05-55
Started: 2026-11-05T05:54:53.8903449Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-shuffled-pester.sh -Seed 1082
EXIT_CODE: 1
Output Summary:

```text
[+] REPO\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.02s (21 tests)
[+] REPO\tests\scripts\claude-hooks\validate-task-researcher-output.Coverage.Tests.ps1 822ms (66 tests)
[+] REPO\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 228ms (12 tests)
[+] REPO\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 314ms (8 tests)
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 304ms (17 tests)
[+] REPO\tests\scripts\dev-tools\HostBootstrap.Invoke.Tests.ps1 2.09s (25 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 196ms (11 tests)
Coverage file not found; skipping Koverage output: REPO\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 110ms (4 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 703ms (22 tests)
[+] REPO\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.51s (19 tests)
Already formatted: /repo/test.ps1
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
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 782ms (33 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 697ms (23 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.05s (19 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 291ms (21 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 249ms (31 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-file-size-limit.Tests.ps1 306ms (33 tests)
[+] REPO\tests\scripts\claude-hooks\validate-required-artifact-output.Envelope.Tests.ps1 243ms (15 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1 749ms (26 tests)
[-] Claude hook dependency-failure special cases (issue #786).baseline mock interception probe 37ms
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, REPO\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:160
 at Invoke-EpicStateInterceptionProbe, REPO\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:204
 at <ScriptBlock>, REPO\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1:137
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 time exactly, but was called 0 times
 Performed invocations:
   <none>
[+] REPO\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 160ms (21 tests)
Tests completed in 44.41s
Tests Passed: 895, Failed: 2, Skipped: 7, Inconclusive: 0, NotRun: 0
Seed=1082; result=Failed; discovered=904; passed=895; failed=2; skipped=7; notrun=0
Recorded file order: ["tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1","tests/scripts/host-tools.manifest.Tests.ps1","tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1","tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1","tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1","tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1","tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1","tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1","tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1","tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1","tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1","tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1","tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1","tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1","tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1","tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1","tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1","tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1","tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1","tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1","tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1","tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1","tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1","tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1","tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1","tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1"]
```

Raw output: SCRATCH/issue-1082-isolation-pester-seed-1082.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
