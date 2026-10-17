# Codex gate and helper loads in the test tree (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-38
Task: [P1-T1]
Command: git grep -n -e "enforce-epic-merge-gate.ps1" -e "enforce-epic-merge-gate-command.ps1" -- tests/scripts; then Read of each codex-hooks line and each line that builds a .codex/hooks path
EXIT_CODE: 0
Output Summary:
CODEX_GATE_IN_PROCESS_LOADS=7
CODEX_GATE_CHILD_PROCESS_LOADS=1
CODEX_GATE_RESOLVED_LOADS=0
MQ_SUITE_LOAD=IN_PROCESS
HELPER_DIRECT_LOADS=0

## Search output (verbatim)

```text
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:6:    .claude/hooks/enforce-epic-merge-gate.ps1 (issue #670).
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:20:Describe 'enforce-epic-merge-gate.ps1 standalone authorization (issue #670)' {
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:26:        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1:4:    Entry-point coverage for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #786).
tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1:14:        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-epic-merge-gate.ps1'))
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:6:    End-to-end rows for the docs-only branch of .claude/hooks/enforce-epic-merge-gate.ps1 (issue #927).
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:18:        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:23:    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:5:    Merge-queue scope tests for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #952).
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:28:Describe 'enforce-epic-merge-gate.ps1 merge-queue scope (issue #952)' {
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:30:        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:5:    Pester tests for the enforce-epic-merge-gate.ps1 PreToolUse hook.
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:8:Describe 'enforce-epic-merge-gate.ps1' {
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:10:        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:5:    Trigger-scoping tests for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #545).
tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:23:Describe 'enforce-epic-merge-gate.ps1 trigger scoping (issue #545)' {
tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:25:        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:27:    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:90:        . (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")
tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1:49:        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')
tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:78:            '.claude/hooks/enforce-epic-merge-gate.ps1'                      = 'EPIC_MERGE_GATE_BLOCKED:'
tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:165:        try { $result = Invoke-HookProcess -Hook '.claude/hooks/enforce-epic-merge-gate.ps1' }
tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1:39:        '.claude/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:478:            # Arrange: the checkpoint shape .claude/hooks/enforce-epic-merge-gate.ps1
tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:40:            '.codex/hooks/enforce-epic-merge-gate.ps1',
tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:85:                'enforce-epic-merge-gate.ps1',
tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:173:                '.codex/hooks/enforce-epic-merge-gate.ps1',
tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:22:        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1:36:        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:6:    Docs-only branch of the Codex epic merge gate .codex/hooks/enforce-epic-merge-gate.ps1 (issue #927).
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:18:        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:34:        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:34:        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:21:        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')
tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:74:            '.codex/hooks/enforce-epic-merge-gate.ps1'                      = 'EPIC_MERGE_GATE_BLOCKED:'
tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py:253:        `.claude/hooks/enforce-epic-merge-gate.ps1` requires a child checkpoint
```

## Classification (lines under tests/scripts/codex-hooks or building a .codex/hooks path)

| Line | Class | Path form | Reading |
|---|---|---|---|
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:40 | REFERENCE | n/a | element of the `$script:RuntimePaths` list used for manifest and byte-identity checks (`:178-186`) |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:85 | REFERENCE | n/a | file name asserted with `Should -Match` against config text |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:173 | REFERENCE | n/a | path asserted to be listed in the bundle manifest |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:22 | IN_PROCESS | Join-Path-unresolved | `$script:CodexHook` set at `:22`, dot-sourced at `:24` (`. $script:CodexHook`) |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1:36 | IN_PROCESS | Join-Path-unresolved | dot-sourced at `:37` (`. $script:UnderTest`) |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:18 | IN_PROCESS | Join-Path-unresolved | dot-sourced at `:19` (`. $script:CodexHook`) |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:34 | IN_PROCESS | Join-Path-unresolved | dot-sourced at `:35` (`. $script:UnderTest`) |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:34 | IN_PROCESS | Join-Path-unresolved | dot-sourced at `:35` (`. $script:UnderTest`) |
| tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:21 | IN_PROCESS | Join-Path-unresolved | `. (Join-Path $script:HookRoot ...)`, `$script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'` at `:7` |
| tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:74 | CHILD_PROCESS | n/a | key of `$script:ReasonPrefix`; hooks are passed to `Invoke-HookProcess -Hook $Hook` at `:146`, `:169` |
| tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:90 (codex row of `:24`) | IN_PROCESS | Join-Path-unresolved | `. (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")` with `HookRoot = '.codex/hooks'` from the runtime table `:22-25` |

`tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1:49` loads the Claude gate (`$script:HookRoot` resolves `.claude/hooks` at `:40`); it builds no `.codex/hooks` path and is not counted.

No output line names `enforce-epic-merge-gate-command.ps1`, so no test file loads the helper directly (HELPER_DIRECT_LOADS=0). No Codex in-process load uses `Resolve-Path` (CODEX_GATE_RESOLVED_LOADS=0).
