# QA Gate — Policy Files Untouched — [P6-T4]

Timestamp: 2026-08-23T03-13

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P6-T4]

Command: `git diff --exit-code main -- .claude/rules/plan-acceptance-gates.md .github`

EXIT_CODE: 0

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

## Result

Exit code 0. Neither the acceptance-gate rule file nor any tracked file under the Copilot
instruction tree differs from `main`.

The same diff was additionally taken against the merge base
`bee15c0660d382ed74c642d2e028fd136051046f` and also reported exit code 0, so the result does not
depend on the ref position. That second anchor matters in this run because `main` has advanced 21
commits past this branch (issue #500, merged as pull request #514) and is not an ancestor of `HEAD`;
had #500 touched either pathspec, the `main`-anchored form would have reported a difference this
branch did not make. It reports none, so both pathspecs are unchanged relative to both anchors.

The `main`-anchored `--name-status` form was also run and produced no output, confirming the
zero-exit result rather than inferring it.

## Why `main` must be named and the bare form is prohibited

The bare `git diff --exit-code` form compares the worktree against the index only, so it passes
vacuously after a mid-execution commit and cannot fail. Naming `main` spans every committed and
uncommitted change this branch has made. The resolved SHA is recorded for the moving-ref reason given
at [P5-T7]: `main` is a moving local ref, and if it is fetched forward mid-execution without a rebase
this gate can fail for a change this branch never made. That direction is fail-closed and therefore
safe, but it is only diagnosable when the SHA is on record — and in this run the ref did in fact
move, which is why the second anchor was taken.

## The gate's one scope limit

A diff does not see a brand-new untracked file. This gate therefore proves that **no tracked file** in
those two locations was changed, and does **not** by itself prove that no new file was added under the
Copilot instruction tree.

That gap is not reachable here. No task in this plan creates anything under `.github`, and a
supplementary porcelain status over the same pathspec was taken to close it observationally:

```text
$ git status --porcelain -- .github .claude/rules/plan-acceptance-gates.md
(no output)
```

Empty: no untracked, modified, or staged entry exists under either pathspec. The limit is recorded so
a later reader does not credit the diff alone with broader coverage than it has.

## What the gate protects

`.claude/rules/plan-acceptance-gates.md` is the origin of the five-marker placeholder vocabulary this
item reuses. The item **cites** that rule file from the amended `parallel-orchestration.md` prose and
**pins** its exported marker tuple equal by test, but it does not edit it: the marker set is
consumed, not extended. `.github` holds the canonical Copilot policy surface, which
`CLAUDE.md` declares must not be modified.

## Output Summary

Exit code 0 against `main` at `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` and exit code 0 against the
merge base, with an empty `--name-status` output and an empty porcelain status over the same
pathspec. The acceptance-gate rule file and every tracked file under the Copilot instruction tree are
unmodified across the whole execution, and no new file was added under either.
