# `EPIC_WORKTREE_REMOVAL_BLOCKED:` Prefix Preserved (P5-T9)

Timestamp: 2026-08-28T11-36

Task: [P5-T9]
Issue: #573
Acceptance criterion supported: AC-12 (second half)
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `git grep -F -c "EPIC_WORKTREE_REMOVAL_BLOCKED:" -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1`

EXIT_CODE: 0

## Result

```
.claude/hooks/enforce-epic-worktree-removal-gate.ps1:2
```

**2 matching lines**, which is at or above the required minimum of two, and the command exited 0.

The two matches, located with `git grep -F -n`:

| Line | Deny site | Text |
| --- | --- | --- |
| 337 | Envelope-anomaly deny | `'EPIC_WORKTREE_REMOVAL_BLOCKED: payload anomaly - ' +` |
| 365 | Terminal deny | `return Get-EpicWorktreeGateBlockDecision -Reason "EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '$worktreePath' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == ""parallel"" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal."` |

The search includes the trailing colon, so it matches the reason **prefix** as emitted rather than a bare token appearing in prose.

## Every deny reason constructed in this file begins with that prefix

The file constructs a deny reason at exactly two sites, and both are listed above.

`Get-EpicWorktreeGateBlockDecision` is the only function that produces a `permissionDecision = 'deny'` object, and it takes the reason as a mandatory `-Reason` parameter, so no deny can be emitted without a reason supplied by a caller. It has exactly two callers: line 336 (the envelope-anomaly path, whose reason begins at line 337) and line 365 (the terminal deny). Both reasons begin with the literal `EPIC_WORKTREE_REMOVAL_BLOCKED:`.

The Phase 2 change replaced the **text** of the terminal deny reason while leaving the prefix and the existing single-quoted `'$worktreePath'` interpolation intact, and did not touch the envelope-anomaly reason at all. All in-repository consumers match on the prefix or on a prefix-anchored fragment, so the reworded sentence breaks none of them; this is corroborated by the seven pre-existing prefix assertions in the suite continuing to pass in [P5-T4].

Output Summary: PASS (AC-12, second half). `git grep -F -c "EPIC_WORKTREE_REMOVAL_BLOCKED:"` reports 2 matching lines and exits 0, at or above the required minimum of two. The two matches are the envelope-anomaly deny at line 337 and the terminal deny at line 365. `Get-EpicWorktreeGateBlockDecision` is the file's only deny constructor, it requires a mandatory `-Reason`, and it has exactly those two callers, so every deny reason constructed in the file begins with the literal `EPIC_WORKTREE_REMOVAL_BLOCKED:` prefix.
