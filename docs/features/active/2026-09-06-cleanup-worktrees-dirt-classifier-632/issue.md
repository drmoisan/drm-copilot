# cleanup-worktrees-dirt-classifier (Issue #632)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-dirt-classifier/ (Issue #632)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #632
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/632
- Last Updated: 2026-09-07
- Work Mode: full-bug

## Summary

`/cleanup-merged-worktrees` reports dirty worktrees as `BLOCKED-DIRTY` without classifying the
dirt, so an operator cannot tell disposable build or session output from work that exists only in
that worktree. On the 2026-09-06 run this left 14 worktrees on already-merged branches requiring
manual, file-by-file triage.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, bash toolchain under WSL Ubuntu
- Python version: not applicable; the cleanup toolchain is native bash
- Command/flags used: `/cleanup-merged-worktrees` report mode and apply mode
  (`bash scripts/bash/cleanup-worktrees.sh`)
- Data source or fixture: the TaskMaster checkout as observed on 2026-09-06

## Steps to Reproduce

1. Run `/cleanup-merged-worktrees` in report mode against a checkout that carries worktrees on
   already-merged branches whose working trees are dirty.
2. Observe that report mode emits `WORKTREE|` records with no statement about the nature of the
   dirt in each worktree.
3. Run apply mode against the same checkout.
4. Observe that each dirty worktree produces `DIRTY|<path>|<status-porcelain-line>` records
   followed by `ACTION|worktree-remove|<path>|BLOCKED-DIRTY`, with no verdict distinguishing
   disposable output from unique work.

## Expected Behavior

Report mode labels every dirty worktree with a deterministic verdict so the operator can decide
without inspecting each file by hand, and an explicit opt-in flag clears provably disposable dirt
and completes the normal non-forced removal.

The six verdicts required by the run observations are:

- `DISPOSABLE_BUILD_ARTIFACT`
- `DISPOSABLE_SESSION_ARTIFACT`
- `CONTENT_ON_MAIN`
- `CONTENT_IN_HISTORY`
- `STAGED_TREE_IS_COMMIT <sha>`
- `UNIQUE`

## Actual Behavior

The only classification an operator receives is the raw `git status --porcelain` line carried on
each `DIRTY|` record, and that record is emitted only in apply mode. Report mode says nothing at
all about dirt. Every dirty worktree is treated identically regardless of whether its dirt is a
`nuget restore` HintPath rewrite or a file that exists nowhere else.

Verbatim from the 2026-09-06 run observations:

> ### 2. Dirty worktrees are blocked with no classification of the dirt
>
> 14 worktrees on merged branches were reported `BLOCKED-DIRTY`. In every case the dirt was one of:
> `*.csproj` / `packages.config` / `app.config` analyzer-HintPath rewrites left by `nuget restore`;
> `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`;
> `artifacts/orchestration/orchestrator-state.json`; or untracked files whose exact content already
> exists in `main`'s history (`git log main --find-object=<blob>` hits) or matches `main`'s current
> blob at the same path.
>
> Required: add a deterministic dirt classifier to report mode that labels each `DIRTY|` line
> `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`,
> `CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT <sha>` (compare `git write-tree` against the
> branch's commit trees; one worktree carried 86 staged changes that were exactly an earlier
> commit), or `UNIQUE`. Add an opt-in apply flag (for example `--clear-disposable`) that, for a
> worktree whose dirt is entirely non-`UNIQUE`, runs `git reset --hard` + `git clean -fd` and then
> the normal non-forced removal. Keep the default behavior unchanged. `UNIQUE` dirt still blocks.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
DIRTY|/repo-wt/dirty|?? untracked-artifact.txt
ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A cleanup run that reports 14 unclassified blocked worktrees pushes the entire triage burden onto
the operator, and the manual triage is exactly the work the skill exists to automate.

## Suspected Cause / Notes

- The only `DIRTY|` emission site is `scripts/bash/cleanup_worktrees_actions_lib.sh:274`, inside
  `remove_worktree_safe`, immediately before the `ACTION|worktree-remove|%s|BLOCKED-DIRTY` emission
  at `:277`. That is apply mode. The requirement places the classifier in report mode, so the
  emission site and the requirement disagree and the resolution must be decided and recorded.
- `STAGED_TREE_IS_COMMIT <sha>` requires `git write-tree`, which writes to the object database and
  to the index. Report mode must remain non-mutating, so the index used for that comparison must be
  redirected away from the inspected worktree's own index.
- `scripts/bash/cleanup_worktrees_lib.sh` is at 479 lines and
  `scripts/bash/cleanup_worktrees_actions_lib.sh` at 382 against the 500-line cap in
  `.claude/rules/general-code-change.md`, so the classifier belongs in a new sibling library.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` **Prohibited Shortcuts** states that a dirty
  worktree is never force-removed. A `--clear-disposable` flag clears and then removes without
  force, which is consistent with that prohibition but is not obviously so from the current text.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: one bats scenario fixture per verdict, driven through the
  `CLEANUP_WT_GIT_BIN` stub seam paired with `CLEANUP_WT_STUB_SCENARIO`.
- [x] Integration scenario to retest: existing `dirty_worktree` and `dirty_worktree_status_error`
  scenarios must produce byte-identical output when the new flag is absent.
- [x] Manual verification notes: confirm the inspected worktree's index file is unchanged after a
  report-mode run that exercises the `STAGED_TREE_IS_COMMIT` path.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
