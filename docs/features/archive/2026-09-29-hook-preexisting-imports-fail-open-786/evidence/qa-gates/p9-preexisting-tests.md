# Pre-Existing Test Changes ([P9-T9])

Timestamp: 2026-10-10T00-42
Command: `git diff --name-status 86e457a003be0c60b65e01156e4cccd6495dfd1a -- tests` together with `git status --porcelain -- tests`; for each modified (M) path, the added and removed lines of `git diff -U0 86e457a003be0c60b65e01156e4cccd6495dfd1a -- <path>` containing `Should`
EXIT_CODE: 0
Output Summary: 11 modified paths: the 8 W-690-TESTS files, tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, and the two section 2.6.6 files of the apply-branch handlers H7 (validate-orchestrator-output-resolution.Tests.ps1) and H8 (validate-orchestrator-output.WaveBarrier.Tests.ps1). The W-690-TESTS files and legacy-codex-hook-contracts.Tests.ps1 have no added or removed line containing `Should`. In the H7 and H8 files, every removed `Should` line is (trimmed) the `<old text>` of an ASSERTION-CHANGED line of that handler, and every added `Should` line is (trimmed) the `<new text>` of one, as recorded in handler-conversion.H7.md and handler-conversion.H8.md.

```text
git diff --name-status 86e457a003be0c60b65e01156e4cccd6495dfd1a -- tests:
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
M	tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
M	tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
A	tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1
A	tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
A	tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1
A	tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
A	tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
A	tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
A	tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
A	tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
A	tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
M	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
git status --porcelain -- tests:

MODIFIED: 11
PATH: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
PATH: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
    -        $result.Message.Contains('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:') | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('RESOLVER_IMPORT_FAILED') | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Message
    +        $result.ExitCode | Should -Be 2 -Because $result.Reason
    +        $result.Reason.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    +        $result.Reason.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Reason
PATH: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
    -        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    -        $result.Message.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Message
    +        $result.ExitCode | Should -Be 2 -Because $result.Reason
    +        $result.Reason.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Reason
PATH: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
