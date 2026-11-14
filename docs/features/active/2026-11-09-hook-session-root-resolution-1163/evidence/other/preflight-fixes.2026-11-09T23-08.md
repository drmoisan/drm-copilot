# Preflight Fixes (round 3, final preflight after the planner revision)

Timestamp: 2026-11-09T23-08
Plan: docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
EXIT_CODE: 0
Output Summary: The branch-current plan validator passed before and after the fixes below. Task count and task order are unchanged. The round-2 defect in [P1-T5] is resolved: the D9 removal-gate rows are now in [P1-T6], and each D9 call site named in [P6-T2] has at least one row marked "fails before". No substantive defect remains.

## Fixes

1. [P2-T1] | literal-formatting ambiguity (assertion unchanged) | The D9 "fails before" list read "RE6, RE7 (both kinds)". [P1-T6] defines RE6 as a `-ForEach` over parallel and epic, and both cases fail before. The list now reads "RE6 (both kinds), RE7 (both kinds)".
2. [P5-T1] | incomplete disposition list (validator-blind class; the decision is unaffected) | `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` calls `Invoke-CompletionConsistencyDecision` with relative `file_path` values only, so no resolution runs. It is added to the unchanged list with that reason.
3. [P5-T2] | incomplete disposition list (validator-blind class; the decision is unaffected) | `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` calls the Codex `Invoke-CompletionConsistencyDecision` with relative `file_path` values or with no `file_path`, so no resolution runs. It is added to the unchanged list with that reason.
4. [P5-T5] | incomplete disposition list (validator-blind class; the decision is unaffected) | The `Describe 'enforce-docs-complete-gate.ps1 with the review/verdict commands'` block of `tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1` calls `Invoke-DocsCompleteGateDecision`. Its commands are not merges. Its control merge is denied when the mocked `gh pr view` lookup fails, which happens before any receipt read, so `Get-DocsCompleteGateReceiptRoot` is never reached. The block is added to the unchanged list with that reason.
5. [P6-T2] | incomplete disposition list (validator-blind class; the decision is unaffected) | `enforce-epic-merge-gate.Authorization.Tests.ps1`, `enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, and `enforce-epic-merge-gate.MergeQueue.Tests.ps1` carry `branch_name` only inside `standalone_merge_authorizations` records, which no `worktree_path` comparison reads. They are added to the unchanged list next to the four merge-gate suites already named.
