# P4-T15 Merge-Gate Suite Set Derivation (issue #927, AC-M16)

Timestamp: 2026-10-16T03-31
Command: grep -r -l -F -e 'enforce-epic-merge-gate.ps1' --include='*.Tests.ps1' tests
EXIT_CODE: 0
Output Summary: The fixed derivation yields exactly the eight member suites that Appendix K names. The comparison search lists seven of them plus suite C; the eighth member (the Coverage suite) loads the gate without calling the decision function. No re-derivation of Appendix K is required.

SECOND_COMMAND: grep -r -l -E -e 'Invoke-EpicMergeGateDecision|Get-EpicMergeGateCommandPrNumber' --include='*.Tests.ps1' tests
SECOND_EXIT_CODE: 0

## First search (20 files) and classification

MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
MEMBER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
MEMBER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
MEMBER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1

EXCLUDED: tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 (suite C, excluded by the derivation)

NON_MEMBER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 (path listed only as data in a hook-to-token table, line 78)
NON_MEMBER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 (spawns the hook as a process through Invoke-HookProcess, line 165)
NON_MEMBER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 (path listed only as data, line 39)
NON_MEMBER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 (path named only in a comment, line 478)
NON_MEMBER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 (names only the Codex copy, as data)
NON_MEMBER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 (names only the Codex copy)
NON_MEMBER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 (names only the Codex copy)
NON_MEMBER: tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 (suite E; names only the Codex copy)
NON_MEMBER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 (names only the Codex copy)
NON_MEMBER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 (dot-sources through $script:HookRoot assigned to .codex/hooks, line 7; Codex copy only)
NON_MEMBER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 (names only the Codex copy, as data)

Membership basis per member: direct `. (Resolve-Path ...enforce-epic-merge-gate.ps1)` (Authorization, ItemResolution, WorktreeResolution); `. $script:UnderTest` assigned to the Claude path (enforce-epic-merge-gate.Tests.ps1, TriggerScoping); `. $script:Hook` assigned to the Claude path (Coverage, line 15); `. (Join-Path $script:HookRoot ...)` with HookRoot `.claude/hooks` (AcceptanceCases, line 49); `-ForEach` row with HookRoot `.claude/hooks` (Issue824, lines 23 and 90).

## Comparison set (second search, 8 files)

Every file other than suite C is a member: enforce-epic-merge-gate.Authorization, .ItemResolution, .Tests, .TriggerScoping, .WorktreeResolution, hook-command-consumers.Issue824, hook-command-parser.AcceptanceCases.

MEMBER_ABSENT_FROM_COMPARISON: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 (it loads the gate for entry-point coverage without calling Invoke-EpicMergeGateDecision or Get-EpicMergeGateCommandPrNumber by name).
