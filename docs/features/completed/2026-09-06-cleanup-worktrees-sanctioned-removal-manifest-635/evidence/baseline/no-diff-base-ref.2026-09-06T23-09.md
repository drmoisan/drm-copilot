# Anchored Base Ref For Every No-Diff Acceptance Condition

Timestamp: 2026-09-08T00-26

Task: [P0-T9]

Command: `git merge-base main HEAD`

EXIT_CODE: 0

## Resolved SHAs

| Ref | SHA |
| --- | --- |
| `git merge-base main HEAD` | `0542c92a7c589cfe952a0dfd480223960fd1eb33` |
| `HEAD` | `d250cf72ee24139735e7f08b07d002ae0e4f1d00` |

`git rev-parse HEAD` was run as a second command, without a pipe, to resolve the `HEAD` SHA.

## What the later comparisons mean

Later tasks in this plan express their no-diff acceptance conditions as `git diff --merge-base main`,
which compares the merge base of `main` and `HEAD` — the commit `0542c92a7c589cfe952a0dfd480223960fd1eb33`
recorded above — against the **working tree**. It therefore reports uncommitted edits, which is the
form those conditions require, and it does not go vacuous the way an unanchored `git diff` would.

`HEAD` at the time of this capture is `d250cf72ee24139735e7f08b07d002ae0e4f1d00`, the merge of pull
request #651 (issue #545, revision r4) into the epic integration branch. Recording both SHAs makes
the comparison point auditable: a later reviewer can confirm that the base a no-diff condition was
evaluated against is the one recorded here, and can detect a rebase or a base-branch advance that
would move it.

Output Summary: Merge base of `main` and `HEAD` resolves to
`0542c92a7c589cfe952a0dfd480223960fd1eb33`; `HEAD` is
`d250cf72ee24139735e7f08b07d002ae0e4f1d00`. Both were produced by this run. This is the anchor every
`git diff --merge-base main` acceptance condition later in this plan compares against.
