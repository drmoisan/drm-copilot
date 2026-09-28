# Git Branch and Commit Baseline — [P0-T2]

Timestamp: 2026-08-28T12-46

Command: `git rev-parse HEAD`, then `git rev-parse --abbrev-ref HEAD`, then `git status --porcelain`

EXIT_CODE: 0

## Recorded Outputs

### `git rev-parse HEAD`

```
cc9d0e5cdb0b7880f70c9ccf8b6621017e9297a5
```

Exit code: 0. The value is 40 hexadecimal characters.

### `git rev-parse --abbrev-ref HEAD`

```
bug/conflictresult-truthiness-always-true-576-r2
```

Exit code: 0.

### `git status --porcelain`

```
?? docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/
```

Exit code: 0. The single untracked entry is the evidence folder this run creates; no tracked file is modified at baseline.

## Branch-Name Substitution (recorded deviation)

The plan's [P0-T2] acceptance names the branch `bug/conflictresult-truthiness-always-true-576`. This
worktree runs the non-destructive sibling branch
`bug/conflictresult-truthiness-always-true-576-r2`, which was created from the exact tip of that
branch and carries byte-identical content for this feature. The substitution was authorized in the
execution directive and is the only branch-name substitution applied to this run.

Sibling relationship, verified in this worktree:

| Item | Value |
| --- | --- |
| Sibling branch tip | `d6149e0b511765dcdbe868069a7af38142202533` |
| Sibling tip subject | `docs(576): prepare conflictresult-truthiness-always-true for parallel run` |
| This branch HEAD | `cc9d0e5cdb0b7880f70c9ccf8b6621017e9297a5` |
| HEAD subject | `Merge remote-tracking branch 'origin/main' into bug/conflictresult-truthiness-always-true-576-r2` |
| `git diff --stat d6149e0b HEAD -- docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576` | empty output, exit code 0 |

The empty feature-folder diff establishes that the two branches carry identical feature content. The
HEAD commit is a merge of `origin/main` into this branch, performed at execution start, so
`origin/main` is an ancestor of HEAD and every `git diff origin/main ...` span in the plan runs as
written. `git rev-parse origin/main` reports `e546e814e246d814474d35067f0674590b0e41ff` and
`git merge-base --is-ancestor origin/main HEAD` succeeds.

Output Summary: All three commands exited 0. The commit hash is the 40-character value
`cc9d0e5cdb0b7880f70c9ccf8b6621017e9297a5`. The branch name is
`bug/conflictresult-truthiness-always-true-576-r2`, the non-destructive sibling of the plan-named
branch `bug/conflictresult-truthiness-always-true-576`, carrying byte-identical feature content from
that branch's exact tip `d6149e0b511765dcdbe868069a7af38142202533`. The working tree carries no
modified tracked file at baseline; the only porcelain entry is the untracked evidence folder created
by this run. `origin/main` at `e546e814e246d814474d35067f0674590b0e41ff` is an ancestor of HEAD.
