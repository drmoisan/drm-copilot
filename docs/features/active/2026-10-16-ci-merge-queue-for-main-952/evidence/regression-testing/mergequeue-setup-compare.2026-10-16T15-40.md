# MergeQueue suite setup comparison (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-40
Task: [P1-T5]
Command: Read tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:29-34; tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:32-38; .claude/hooks/enforce-epic-merge-gate.ps1:86; .codex/hooks/enforce-epic-merge-gate.ps1:35
EXIT_CODE: 0
Output Summary:
CLAUDE_MQ_HOOK_PATH=Resolve-Path (:30)
CODEX_MQ_HOOK_PATH=Join-Path-unresolved (:34)
HELPER_LOAD=gate-relative Join-Path PSScriptRoot (both gates)

## Claude MergeQueue setup (tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:29-34, verbatim)

```powershell
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
```

## Codex merge-queue setup (tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:32-38, verbatim)

```powershell
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
```

## Helper load lines (verbatim)

`.claude/hooks/enforce-epic-merge-gate.ps1:86`:

```powershell
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
```

`.codex/hooks/enforce-epic-merge-gate.ps1:35`:

```powershell
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
```

Observed forms equal the planner's expected forms.
