# cleanup-worktrees-skips-detached-head-worktrees (Issue #630)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-skips-detached-head-worktrees/ (Issue #630)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #630
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/630
- Last Updated: 2026-09-06
- Work Mode: full-bug
- Epic context: child feature A of the cleanup-merged-worktrees hardening epic (gaps 1 and 6 of the 2026-09-06 run observations recorded at `research/2026-09-06-cleanup-run-observations-user-context.md` in this folder). Work mode was changed from `minor-audit` to `full-bug` on 2026-09-06 when the objective was rerouted to `/epic-plan`, because the preparation route produces `spec.md`.

## Summary

The `cleanup-merged-worktrees` skill and its script `scripts/bash/cleanup-worktrees.sh` never delete a worktree whose HEAD is detached, even when that HEAD commit is already an ancestor of `main`. Apply mode is driven by local branch enumeration, and the worktree map it builds explicitly skips `DETACHED` registrations, so a detached-HEAD worktree is listed in the report but is never classified and never becomes a deletion candidate. In the 2026-09-06 TaskMaster cleanup run, 30 of 57 registered worktrees had a detached HEAD (preparation worktrees, epic-child baselines, agent worktrees whose branch was deleted earlier) and all were invisible to apply mode.

A second apply-mode safety defect in the same library is in scope: the consolidation branch `documentationandmemories` is created at `main` and is classified `MERGED_CLEAN` (and `verify_consolidation_merged` returns `MERGED_CLEAN`) until its first commit lands, so an apply pass in that window deletes the branch and its worktree.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; script executed under Git Bash (GNU bash 5.2.37 msys) and WSL Ubuntu (bats 1.13.0, kcov 43).
- Python version: not applicable (native bash tool).
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh` (report) and `bash scripts/bash/cleanup-worktrees.sh --apply`.
- Data source or fixture: the live `drm-copilot` checkout on this machine, which has 33 registered worktrees, one of them detached at `.../scratchpad/base-wt` on commit `fb30a9a5`; the 2026-09-06 TaskMaster run with 57 worktrees and 69 local branches.

## Steps to Reproduce

1. Register a worktree with a detached HEAD on a commit that is already reachable from `main`, for example `git worktree add --detach <path> <merged-sha>`.
2. Run `bash scripts/bash/cleanup-worktrees.sh`. Observe the report emits `WORKTREE|<path>|DETACHED|detached` and no classification record for that worktree.
3. Run `bash scripts/bash/cleanup-worktrees.sh --apply`. Observe no `ACTION|worktree-remove|<path>|...` line is emitted for the detached worktree and the registration remains in `git worktree list`.
4. For the ordering hazard: run the consolidation step so that `documentationandmemories` exists at `main` with zero commits ahead, then run `--apply`. Observe the branch and its worktree are deleted as `MERGED_CLEAN`.

## Expected Behavior

A detached-HEAD worktree is classified against `main` with the same ladder used for branches (ancestry, content-neutral, cherry-equivalence, rename-aware blob fallback). When the detached HEAD is delete-eligible (`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, or `MERGED_EQUIVALENT`) and the working tree is clean, apply mode removes the worktree registration without force after same-process re-verification, exactly as it does for a branch-backed worktree. When it is not delete-eligible, dirty, locked, prunable, or the caller's own worktree, it is left in place and reported, exactly as a branch-backed worktree would be. The report carries a `WORKTREE|<path>|DETACHED|<state>` record using the branch state vocabulary.

A zero-commit `documentationandmemories` branch (tip equal to `main`) is never delete-eligible: `verify_consolidation_merged` reports it as not merged (a `NOT_ANCESTOR`-equivalent verdict) or apply mode refuses to run while the consolidation worktree exists with no commits.

## Actual Behavior

- `run_report` (`scripts/bash/cleanup_worktrees_lib.sh`) emits only the `WORKTREE|...|DETACHED|...` registration line for a detached worktree; no classification is performed because classification iterates `enumerate_branches` output only.
- `run_apply` (`scripts/bash/cleanup_worktrees_actions_lib.sh`) builds its `wt_of` branch-to-path map with the guard `[[ -n $wbranch && $wbranch != DETACHED ]]`, then iterates branches only. A detached worktree is never passed to `delete_candidate` or `remove_worktree_safe`, so it is never removed.
- `verify_consolidation_merged` returns `MERGED_CLEAN` for a consolidation branch whose tip equals `main`, so `run_apply` unlocks its deletion before any consolidated content exists.
- No error is raised in either case; the omissions are silent.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
$ git worktree list --porcelain | awk 'BEGIN{RS="";FS="\n"} /detached/'
worktree C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-21T17-18/3a9f9b03-f2e5-4fee-a94a-e4f2849de2d5/scratchpad/base-wt
HEAD fb30a9a58b8422e610a09b07361421e97367807a
detached
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Stale detached worktrees accumulate and must be removed by hand; in the 2026-09-06 run they were more than half of all registrations. The ordering hazard can delete a consolidation branch during the window between creation and first commit. No data loss was observed.

## Suspected Cause / Notes

- `scripts/bash/cleanup_worktrees_actions_lib.sh`, `run_apply`: the `wt_of` map skips `DETACHED` entries and deletion is keyed on branch names.
- `scripts/bash/cleanup_worktrees_lib.sh`, `classify_branch` and `run_report`: the ladder is only ever invoked with a branch name from `enumerate_branches`; a detached HEAD commit is never fed to it. The individual rungs (`classify_ancestry`, `classify_content_neutral`, `classify_cherry_equivalent`, `classify_residual_commit`) accept any committish and can be reused for a SHA.
- `compute_protected` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh`) already handles the caller's own detached HEAD by protecting the worktree path, so path-based protection is available for a detached candidate.
- `verify_consolidation_merged` (`scripts/bash/cleanup_worktrees_actions_lib.sh`) uses only `merge-base --is-ancestor`, which is true for a branch whose tip equals `main`; a zero-commits-ahead check (`git rev-list --count main..documentationandmemories`) or a tip-equals-main comparison is missing.
- File-size constraint: `cleanup_worktrees_lib.sh` is 479 lines against the 500-line cap, so the detached-worktree classification and removal logic should live in a new sourceable library file (or in the 382-line actions library) rather than in the classification library.
- The `.claude/skills/cleanup-merged-worktrees/SKILL.md` report-line contract and workflow prose describe only branch candidates and must be updated to describe the detached-worktree record and its apply-mode handling.
- Sibling epic children extend the same libraries (dirt classifier, report-mode additions, untracked-file consolidation); keep the detached-worktree code in its own function group so those children do not collide on the same file regions.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: new bats cases driven by checked-in scenario fixtures under `tests/fixtures/cleanup_worktrees/scenarios/` for a merged detached worktree (removed), an unmerged detached worktree (no-op), a dirty merged detached worktree (`BLOCKED-DIRTY`, no force), a locked detached worktree (skipped), the caller's own detached worktree (`PROTECTED_CURRENT`, never removed), and a zero-commit consolidation branch (never deleted).
- [x] Integration scenario to retest: run report and apply modes against the live checkout and confirm the `base-wt` detached worktree on `fb30a9a5` is classified and removed.
- [x] Manual verification notes: `git worktree list` no longer shows the removed registration; no `--force` argv appears in the stub log; `git worktree prune` is never invoked.

## Acceptance Criteria

- [ ] Report mode emits exactly one `WORKTREE|<path>|DETACHED|<state>` record for every registered worktree whose porcelain stanza carries `detached`, excluding the main worktree, where `<state>` is produced by the existing classification ladder applied to the worktree's HEAD SHA against `main` and is one of `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`; branch-backed worktree records keep their existing `WORKTREE|<path>|<branch>|<flags>` shape.
- [ ] Apply mode removes, via `git worktree remove <path>` with no force flag, every detached worktree whose fresh same-process re-classification is `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, or `MERGED_EQUIVALENT`, emitting `ACTION|worktree-remove|<path>|OK` on success.
- [ ] Apply mode never attempts removal of a detached worktree classified `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`, never removes the main worktree, and never removes the caller's current worktree (path match via `compute_protected`).
- [ ] A dirty delete-eligible detached worktree is reported with `DIRTY|<path>|<status-line>` records and `ACTION|worktree-remove|<path>|BLOCKED-DIRTY`; a `locked` detached worktree is skipped with `ACTION|worktree-remove|<path>|BLOCKED-LOCKED` and no `git worktree remove` invocation; a `prunable` detached worktree remains report-only with no removal or prune invocation.
- [ ] A hard git failure during detached-worktree classification maps to `ANCESTRY_ERROR`, performs no removal, and yields a non-zero apply return code.
- [ ] An apply pass cannot delete a zero-commit `documentationandmemories` branch or its worktree: when the branch tip equals `main`, `verify_consolidation_merged` does not return `MERGED_CLEAN` and `run_apply` emits `ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` (or refuses apply mode with a diagnostic while the consolidation worktree exists with no commits).
- [ ] New bats tests under `tests/shell/` exercise each of the behaviors above through the checked-in git stub and scenario fixtures (`CLEANUP_WT_GIT_BIN` seam), without creating temporary files or scratch repositories.
- [ ] `.claude/skills/cleanup-merged-worktrees/SKILL.md` documents the detached `WORKTREE|` record state field, the detached-worktree apply-mode behavior, the `BLOCKED-LOCKED` result, and the zero-commit consolidation guard; the `cleanup-worktrees.sh --help` text reflects the detached record.
- [ ] `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`, and `bash scripts/bash/shell-qc.sh test --coverage` pass in a single clean loop with the reported `Bash coverage (lines)` value at or above 85%, and no shell file in `scripts/bash/` exceeds 500 lines.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
