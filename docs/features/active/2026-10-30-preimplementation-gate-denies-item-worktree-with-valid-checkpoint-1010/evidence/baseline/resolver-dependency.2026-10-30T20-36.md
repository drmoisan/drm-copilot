# Resolver Dependency Check (Issue #1010, P0-T2, restated task)

Timestamp: 2026-10-30T20-36
Command: git fetch origin main; git merge-base --is-ancestor origin/main HEAD; sh SCRATCH/issue-1010-resolver-suite.sh (Invoke-Pester over tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1 and tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1, then direct Resolve-HookTargetWorktree probes with synthetic roots)
EXIT_CODE: 0
Output Summary: Status PRESENT. Both resolver suites pass (166 total, 166 passed, 0 failed). Resolve-HookTargetWorktree is exported by the module and defined by the Codex twin with -SessionRoot, -FilePath, -CommandOperandPath, -CommandBranch, -DelegationPrompt, -CheckpointIssueReader, -WorktreeListInvoker and no -Command. A throwing or empty invoker on the FilePath leg yields the session root with Source SessionRoot.

Status: PRESENT

The earlier artifact `resolver-dependency.2026-10-30T19-49.md` (Status BLOCKED, against the superseded P0-T2 text) is kept as history.

## Merge Result

- `git fetch origin main` succeeded. `git merge-base --is-ancestor origin/main HEAD` exited 0; the merge base of `origin/main` and `HEAD` equals `origin/main`. No merge was needed, and no conflict exists.

## Recorded Fields

| Field | Observed value |
|---|---|
| Module file | `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` present |
| Twin file | `.codex/hooks/hook-target-worktree.ps1` present |
| Exported by module | yes; exports `ConvertFrom-HookTargetWorktreePorcelain`, `ConvertTo-HookTargetWorktreeNormalizedPath`, `Get-HookTargetWorktreeEnclosingRoot`, `Get-HookTargetWorktreeKey`, `Get-HookTargetWorktreeRelativePath`, `Resolve-HookTargetWorktree` |
| Defined by twin | yes; `function Resolve-HookTargetWorktree` with the same parameter block |
| Parameters (both copies) | `-SessionRoot` (mandatory string), `-FilePath` (string[]), `-CommandOperandPath` (string[]), `-CommandBranch` (string), `-DelegationPrompt` (string), `-CheckpointIssueReader` (scriptblock), `-WorktreeListInvoker` (scriptblock, shape `{ param($SessionRoot) <porcelain text> }`, default runs the porcelain worktree listing for the session root and returns an empty string on a non-zero exit) |
| `-Command` parameter | absent in both copies; the gate parses command text itself (P1-T1, P1-T2) |
| Output properties | `WorktreeRoot`, `Source`, `Ambiguous` (plus `ReasonCode`, `Detail`, `Candidates`) |
| Null-`WorktreeRoot` results | ambiguity (`TARGET_WORKTREE_AMBIGUOUS`, `Ambiguous` true); a branch or delegation identity naming no worktree (`TARGET_WORKTREE_NOT_DERIVABLE`); probe `-CommandBranch 'nope'` gave Root empty, Source `CommandOperand`, code `TARGET_WORKTREE_NOT_DERIVABLE`. These satisfy the AC-01 no-root result. |
| Path-leg invoker failure | throwing invoker with an absolute `-FilePath`: Root `/synthetic-worktrees/session`, Source `SessionRoot`, `Ambiguous` false, no reason code. The gate's recording invoker converts this into a deny (P3-T2, P3-T3, spec E1). |
| Empty-list result | invoker returning `''` with an absolute `-FilePath`: Root session root, Source `SessionRoot`, Detail `the worktree list returned no registered worktree` |
| `-FilePath` rejects a path string (E3) | no; the parameter is `[string[]]` with `AllowNull` and `AllowEmptyCollection` and no validation attribute |
| Relative-path result | `-FilePath 'relative/x.ps1',''` with a throwing invoker: Root session root, Source `SessionRoot`; the invoker was not called (it would have thrown otherwise and the result is unchanged either way) |
| No-source result | no source present: Root session root, Source `SessionRoot` |
| `Source` values | `FilePath`, `CommandOperand`, `DelegationIdentity`, `SessionRoot` |
| Reason-code accessors exported | none (the module restates both literals internally) |
| Resolver suite counts | `HookTargetWorktree.Tests.ps1` 83 passed, 0 failed; Codex `hook-target-worktree.Tests.ps1` 83 passed, 0 failed |

## Stop-Condition Review

No merge conflict; both files present; the function is exported and defined by the twin; all three output properties present; `-FilePath`, `-CommandOperandPath`, and `-WorktreeListInvoker` present in both copies; `-FilePath` accepts any path string; an invoker failure on a path leg yields the session root; both suites report zero failures. No stop condition applies.
