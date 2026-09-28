# Phase 0 — Revision Anchors (remediation cycle 2)

Timestamp: 2026-08-28T01-28
Task: [P0-T3]
Command: `git rev-parse HEAD`, then `git merge-base HEAD origin/main`, then `git merge-base --is-ancestor 1e991b86d78e4f979922b79268f19ca0e5ab19e3 HEAD`
EXIT_CODE: 0 (all three commands; observed exit codes 0, 0, 0)

Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`
Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3`

## Branch head

`git rev-parse HEAD` — EXIT_CODE 0

```
9fed8b9074354ac91b35dc6756fcf4935cfc1c89
```

Full 40-character branch-head SHA: **`9fed8b9074354ac91b35dc6756fcf4935cfc1c89`**

## The comparison anchor — a fixed constant, verified by ancestry

The comparison anchor for every changed-line computation in this cycle is the **fixed cycle-1
constant**:

```
1e991b86d78e4f979922b79268f19ca0e5ab19e3
```

`git merge-base --is-ancestor 1e991b86d78e4f979922b79268f19ca0e5ab19e3 HEAD` — EXIT_CODE **0**.

Exit code 0 from `--is-ancestor` means the anchor **is** an ancestor of `HEAD`. The anchor therefore
remains a valid diff base, and the changed-line sets computed against it in this cycle stay directly
comparable with the sets cycle 1 computed against the same commit.

The anchor is **pinned as a constant and verified by ancestry**. It is never recomputed from
`git merge-base`, because the merge of `origin/main` into this branch moved the merge base while
leaving the anchor valid. Every later task that needs the comparison anchor — `[P3-T7]` item 6 in
particular, whose 9-and-25 uncovered-changed-line counts are computed against it — reads this pinned
constant.

## Separately headed statement — the current merge base is NOT the comparison anchor

`git merge-base HEAD origin/main` — EXIT_CODE 0

```
c62af7a71eb2dbc8c8086c9cbf1c30c22551590a
```

This branch merged `origin/main`, so `git merge-base HEAD origin/main` now resolves to
`c62af7a71eb2dbc8c8086c9cbf1c30c22551590a`.

**This value is NOT the comparison anchor.** It is recorded here only so that a reader who runs
`git merge-base` and obtains a different value from the anchor understands why the two differ. No
task in this remediation plan uses `c62af7a71eb2dbc8c8086c9cbf1c30c22551590a` as a diff base for a
changed-line computation. Substituting it for the pinned anchor would silently change the
uncovered-changed-line counts of `[P3-T7]` item 6.

## Summary table

| Fact | Value | Exit code |
| --- | --- | --- |
| Branch head | `9fed8b9074354ac91b35dc6756fcf4935cfc1c89` | 0 |
| Current merge base with `origin/main` (NOT the anchor) | `c62af7a71eb2dbc8c8086c9cbf1c30c22551590a` | 0 |
| Fixed cycle-1 comparison anchor (pinned constant) | `1e991b86d78e4f979922b79268f19ca0e5ab19e3` | n/a |
| Anchor is an ancestor of `HEAD` | yes | 0 |

Output Summary: All three commands returned EXIT_CODE 0. Branch head is
`9fed8b9074354ac91b35dc6756fcf4935cfc1c89`. The fixed comparison anchor
`1e991b86d78e4f979922b79268f19ca0e5ab19e3` is confirmed still an ancestor of `HEAD`. The current
`git merge-base HEAD origin/main` value `c62af7a71eb2dbc8c8086c9cbf1c30c22551590a` is recorded as
explicitly not the comparison anchor.
