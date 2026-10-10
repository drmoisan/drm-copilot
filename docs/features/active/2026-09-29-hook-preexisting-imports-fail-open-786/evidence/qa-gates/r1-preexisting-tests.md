# Remediation Cycle 1 Pre-Existing Test Changes, AC-17 Non-Regression ([P5-T8])

Timestamp: 2026-10-10T18-31
Pass: 1
Command: sh <SCRATCHPAD>/r.sh r1-p5t8 -Pass 1 (route sh, fresh PowerShell 7 process): git diff --name-status 86e457a003be0c60b65e01156e4cccd6495dfd1a -- tests together with git status --porcelain -- tests; for each modified (M) path the added and removed lines of git diff -U0 86e457a003be0c60b65e01156e4cccd6495dfd1a -- <path> containing `Should`; category check against the extended admitted set (W-690-TESTS files as listed in evidence/qa-gates/p9-preexisting-tests.md, legacy-codex-hook-contracts.Tests.ps1, the H7 and H8 section 2.6.6 files, [P3-T1] files (none: skip branch), extended `<base>.Coverage.Tests.ps1` files); H7/H8 removed `Should` lines (trimmed) matched as the old-text field of an `ASSERTION-CHANGED:` line of evidence/other/handler-conversions.md for the same path, added `Should` lines (trimmed) matched as an ordinal substring of one such line
EXIT_CODE: 0
Output Summary: 11 modified paths, all admitted: 8 W-690-TESTS files and legacy-codex-hook-contracts.Tests.ps1 with no added or removed `Should` line; H7 (3 removed, 3 added) and H8 (2 removed, 3 added, including the [P4-T1] leading-token assertion) all matched to `ASSERTION-CHANGED:` lines. No [P3-T1] file and no extended Coverage file is modified. AC17-RESULT: pass.

```text
Pass: 1
git diff --name-status 86e457a003be0c60b65e01156e4cccd6495dfd1a -- tests:
A	tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
M	tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
M	tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
A	tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
A	tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
A	tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
A	tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
A	tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
M	tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
M	tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
A	tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
A	tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
A	tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
A	tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1
A	tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
A	tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1
A	tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
A	tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
A	tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
A	tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
A	tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
A	tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
A	tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
A	tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
M	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
A	tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
A	tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
git status --porcelain -- tests:
MODIFIED: 11
PATH: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | category=W-690-TESTS | added-should=0 | removed-should=0 | pass
PATH: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | category=section-2.6.6-H7-H8 | added-should=3 | removed-should=3 | pass
    -        $result.Message.Contains('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:') | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('RESOLVER_IMPORT_FAILED') | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Message
    +        $result.ExitCode | Should -Be 2 -Because $result.Reason
    +        $result.Reason.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    +        $result.Reason.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Reason
PATH: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | category=section-2.6.6-H7-H8 | added-should=3 | removed-should=2 | pass
    -        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Message
    +        $result.ExitCode | Should -Be 2 -Because $result.Reason
    +        $result.Reason.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Reason
    +        $result.Reason.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
PATH: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | category=legacy | added-should=0 | removed-should=0 | pass
AC17-RESULT: pass | failing paths=0
```
