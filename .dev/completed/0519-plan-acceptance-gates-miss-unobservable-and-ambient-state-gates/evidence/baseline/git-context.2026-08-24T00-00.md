# Git Context Baseline — [P0-T14]

Timestamp: 2026-08-26T08-04
Task: [P0-T14]
Command: `git rev-parse HEAD main`, followed by `git cat-file -t <commit>` for each of the six commits
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`
EXIT_CODE: 0

Every command below exited 0. Each was run as a plain, separate invocation from the worktree root; the worktree-isolation guard rejects a compound form, so no loop or chained command was used.

## Resolved object names

```
$ git rev-parse HEAD main
d1dcf5173732c5b13a491ae995757f9434f21bff
245b56a4a1618f25a26e87d60ac0b8894c0b9caa
```

**HEAD: `d1dcf5173732c5b13a491ae995757f9434f21bff`**
**main: `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`**

Current branch:

```
$ git rev-parse --abbrev-ref HEAD
bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519-r2
```

The `main` object name matters beyond record-keeping: every `git diff` span in this plan carries an explicit `main` ref operand, per the plan's self-application rule, so `main` must resolve for those spans to anchor. It resolves.

## The six commits — literal type reported by `git cat-file -t`

| Commit | Command | Literal output | Exit code |
| --- | --- | --- | --- |
| `e2aa6446` | `git cat-file -t e2aa6446` | `commit` | 0 |
| `eff8f196` | `git cat-file -t eff8f196` | `commit` | 0 |
| `30414365` | `git cat-file -t 30414365` | `commit` | 0 |
| `e913e0a9` | `git cat-file -t e913e0a9` | `commit` | 0 |
| `ceacb5a5` | `git cat-file -t ceacb5a5` | `commit` | 0 |
| `5a8ede0f` | `git cat-file -t 5a8ede0f` | `commit` | 0 |

All six report the literal type `commit`. Each is a real, readable commit object in this worktree's object store, reachable by its abbreviated name without ambiguity — `git cat-file -t` fails with a non-zero exit on an unknown or ambiguous object, and none did.

## Shortfall status

**No shortfall.** All six commits are readable, so the conditional branch of this task's acceptance — recording the exact command and its output rather than substituting another commit — is not triggered, and nothing is carried forward into [P5-T1] as a deficit.

This resolves an item the research document left open. Its Q7 section records that the researching agent could **not** verify recoverability, because its tool set contained no shell tool and therefore could not run `git log`, `git rev-list`, or `git show`; it explicitly declined to assert either that the revisions were recoverable or that they were not. That verification is now performed and the answer is affirmative for all six objects.

## Scope of what this task establishes, and what it does not

This task verifies that the six **commit objects** exist and are readable. It does not verify that the issue #502 plan file is present at each of them, nor that its six texts differ. That is [P5-T1]'s work, which runs a `git show` joining each commit, a colon, and the repo-relative path `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`.

The distinction is worth stating because a readable commit does not guarantee a readable path within it. The research document records at Q7 that the plan file has since been archived to the `docs/features/completed/...` tree, so [P5-T1] deliberately extracts using the **active**-tree path as it stood at each commit rather than the current archived path. A `git show` against the current path would fail at every one of the six commits even though all six commits are readable, which is exactly the failure mode this separation of concerns makes visible rather than confusing with an unreadable commit.

## Output Summary

`git rev-parse HEAD main` exited 0, resolving HEAD to `d1dcf5173732c5b13a491ae995757f9434f21bff` and main to `245b56a4a1618f25a26e87d60ac0b8894c0b9caa` on branch `bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519-r2`. All six commits — `e2aa6446`, `eff8f196`, `30414365`, `e913e0a9`, `ceacb5a5`, `5a8ede0f` — were checked individually with `git cat-file -t`; each reported the literal type `commit` and exited 0. **No shortfall is carried forward into [P5-T1].** This resolves the recoverability question the research document left explicitly unverified.
