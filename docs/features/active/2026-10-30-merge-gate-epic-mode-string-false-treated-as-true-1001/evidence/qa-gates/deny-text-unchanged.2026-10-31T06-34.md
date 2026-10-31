# Deny Text Unchanged (issue #1001)

Timestamp: 2026-10-31T06-34
Command: git diff ccec4eba82e272d27f7d81c0e0657a93110de5fb -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 .claude/hooks/enforce-model-routing-receipt.ps1 (MERGE_BASE substituted by its resolved commit)
EXIT_CODE: 0

The diff is non-empty: 8 hunks across the three hooks (3 in the merge gate, 3 in the model-routing hook, 2 in the base-branch file).

| File | Hunk | Enclosing function or block | Change |
|---|---|---|---|
| `enforce-epic-merge-gate.ps1` | 1 | script-level comment-based help, `.DESCRIPTION` condition 1 | two help lines added |
| `enforce-epic-merge-gate.ps1` | 2 | `Test-ChildCheckpointAllowsEpicMerge` (help) | `.DESCRIPTION` added |
| `enforce-epic-merge-gate.ps1` | 3 | `Test-ChildCheckpointAllowsEpicMerge` | `[bool]` cast replaced by the `-is [bool]` test |
| `enforce-model-routing-receipt.ps1` | 1 | script-level comment-based help, "Author-asserted autoclose line (issue #989)" paragraph | one line replaced by two |
| `enforce-model-routing-receipt.ps1` | 2 | `Get-ModelRoutingAuthorAssertedReason` (help) | `.DESCRIPTION` sentence added |
| `enforce-model-routing-receipt.ps1` | 3 | `Get-ModelRoutingAuthorAssertedReason` | `-eq $true` replaced by the `-is [bool]` test |
| `enforce-pr-author-skill.epic-base-branch.ps1` | 1 | `Test-EpicBaseBranchOverride` (help) | `.DESCRIPTION` sentence added |
| `enforce-pr-author-skill.epic-base-branch.ps1` | 2 | `Test-EpicBaseBranchOverride` | `[bool]` cast replaced by the `-is [bool]` test |

Changed `return` statements carrying a string literal: 0. No added or removed line contains `return`; the final deny literal of `Invoke-EpicMergeGateDecision` (containing `epic_mode == true`), the three `EPIC_BASE_BRANCH_MISMATCH` return literals, and the `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` return literal are outside every hunk.

Output Summary: zero changed return string-literal lines; changed hunks fall only in `Test-ChildCheckpointAllowsEpicMerge`, `Test-EpicBaseBranchOverride`, `Get-ModelRoutingAuthorAssertedReason`, and the two script-level help blocks named in [P2-T2] and [P2-T5].
