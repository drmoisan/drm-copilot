# Resolver Contract Verification (Issue #1011)

Timestamp: 2026-10-31T01-18
Module: .claude/lib/worktree-resolution/HookTargetWorktree.psm1
Method: read of `Resolve-HookTargetWorktree` and the `Export-ModuleMember` list.

## Parameters

- SessionRoot: MATCH (mandatory)
- FilePath: MATCH
- CommandOperandPath: MATCH
- CommandBranch: MATCH
- DelegationPrompt: MATCH
- CheckpointIssueReader: MATCH (scriptblock seam)
- WorktreeListInvoker: MATCH (scriptblock seam; default runs `git -C <SessionRoot> worktree list --porcelain`)

## Result properties (nested `Get-HookTargetResult`)

- WorktreeRoot: MATCH
- Source: MATCH
- Ambiguous: MATCH (true exactly when ReasonCode is TARGET_WORKTREE_AMBIGUOUS)
- ReasonCode: MATCH
- Detail: MATCH
- Candidates: MATCH

## Source values

- FilePath: MATCH
- CommandOperand: MATCH
- DelegationIdentity: MATCH
- SessionRoot: MATCH (no source present, or a path that falls back)

## CommandBranch-only behavior (`Resolve-HookTargetBranchSource` with Source CommandOperand)

- Match: MATCH (WorktreeRoot = matched root, Source CommandOperand, ReasonCode null)
- No match: MATCH (WorktreeRoot null, Source CommandOperand, ReasonCode TARGET_WORKTREE_NOT_DERIVABLE)
- Several matches: MATCH (WorktreeRoot null, Ambiguous true, ReasonCode TARGET_WORKTREE_AMBIGUOUS, Candidates set)
- Empty worktree list (invoker failure): MATCH (no record matches, so the no-match result applies)

## Exports

- ConvertTo-HookTargetWorktreeNormalizedPath exported: MATCH
- Resolve-HookTargetWorktree exported: MATCH

RESOLVER_CONTRACT: USABLE
