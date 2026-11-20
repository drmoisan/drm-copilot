Timestamp: 2026-11-05T05-36
Started: 2026-11-05T05:35:39.7881548Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-final-pester.sh targeted
EXIT_CODE: 1
Output Summary:

```text
Actual Pester version: 6.2.0
Coverage policy: config/poshqc-coverage.json; profiler mode; JaCoCo output; unchanged configured roots
Entire affected test files: 27; no test-name filter

Running tests from 27 files.
[+] REPO\tests\scripts\claude-hooks\enforce-batch-budget.RouteImportFailure.Tests.ps1 2s (20 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 225ms (7 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1 1.26s (26 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 987ms (31 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 3.59s (21 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 1.71s (22 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 862ms (62 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.96s (19 tests)
[+] REPO\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 267ms (11 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 9.86s (186 tests)
[+] REPO\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.55s (15 tests)
[+] REPO\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.56s (19 tests)
[+] REPO\tests\scripts\claude-hooks\validate-executor-output.Envelope.Tests.ps1 212ms (12 tests)
[+] REPO\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 307ms (8 tests)
[+] REPO\tests\scripts\claude-hooks\validate-orchestrator-output.Envelope.Tests.ps1 657ms (14 tests)
[+] REPO\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 272ms (12 tests)
[+] REPO\tests\scripts\claude-hooks\validate-required-artifact-output.Envelope.Tests.ps1 277ms (15 tests)
[+] REPO\tests\scripts\claude-hooks\validate-task-researcher-output.Coverage.Tests.ps1 852ms (66 tests)
[-] Codex enforce-codex-model-routing coverage (issue #786).entry point.reads the transcript-keyed attestation and denies profile drift 38ms
 at $result.ExitCode | Should -Be 0, REPO\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1:127
 Expected 0, but got 2.
[+] REPO\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 122ms (7 tests)
[-] Codex enforce-epic-root-invocation coverage (issue #786).entry point.reads the transcript-keyed attestation and allows valid provenance 22ms
 at $result.ExitCode | Should -Be 0, REPO\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1:88
 Expected 0, but got 2.
[+] REPO\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 322ms (21 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-file-size-limit.Tests.ps1 310ms (33 tests)
[+] REPO\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 635ms (23 tests)
[+] REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 4.23s (89 tests)
[+] REPO\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 351ms (5 tests)
[+] REPO\tests\scripts\host-tools.manifest.Tests.ps1 224ms (9 tests)
Tests completed in 41.1s
Tests Passed: 778, Failed: 2, Skipped: 0, Inconclusive: 0, NotRun: 0
Targeted result: Failed; discovered=780; passed=778; failed=2; skipped=0; notrun=0
```

Raw output: SCRATCH/issue-1082-powershell-fixture-targeted-proven.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
