# cleanup-worktrees-skips-detached-head-worktrees (Issue #630)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-skips-detached-head-worktrees/ (Issue #630)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #630
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/630
- Last Updated: 2026-09-06
## Summary

The `cleanup-merged-worktrees` skill and its script `scripts/bash/cleanup-worktrees.sh` never delete a worktree whose HEAD is detached, even when that HEAD commit is already an ancestor of `main`. Apply mode is driven by local branch enumeration, and the worktree map it builds explicitly skips `DETACHED` registrations, so a detached-HEAD worktree is listed in the report but is never classified and never becomes a deletion candidate.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; script executed under Git Bash (GNU bash 5.2.37 msys) and WSL Ubuntu (bats 1.13.0, kcov 43).
- Python version: not applicable (native bash tool).
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh` (report) and `bash scripts/bash/cleanup-worktrees.sh --apply`.
- Data source or fixture: the live `drm-copilot` checkout on this machine, which has 33 registered worktrees, one of them detached at `.../scratchpad/base-wt` on commit `fb30a9a5`.

## Steps to Reproduce

1. Register a worktree with a detached HEAD on a commit that is already reachable from `main`, for example `git worktree add --detach <path> <merged-sha>`.
2. Run `bash scripts/bash/cleanup-worktrees.sh`. Observe the report emits `WORKTREE|<path>|DETACHED|detached` and no classification record for that worktree.
3. Run `bash scripts/bash/cleanup-worktrees.sh --apply`. Observe no `ACTION|worktree-remove|<path>|...` line is emitted for the detached worktree and the registration remains in `git worktree list`.

## Expected Behavior

A detached-HEAD worktree is classified against `main` with the same ladder used for branches (ancestry, content-neutral, cherry-equivalence, rename-aware blob fallback). When the detached HEAD is delete-eligible (`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, or `MERGED_EQUIVALENT`), apply mode removes the worktree registration without force after same-process re-verification, exactly as it does for a branch-backed worktree. When it is not delete-eligible, dirty, locked, prunable, or the caller's own worktree, it is left in place and reported, exactly as a branch-backed worktree would be.

## Actual Behavior

- `run_report` (`scripts/bash/cleanup_worktrees_lib.sh`) emits only the `WORKTREE|...|DETACHED|...` registration line for a detached worktree; no classification is performed because classification iterates `enumerate_branches` output only.
- `run_apply` (`scripts/bash/cleanup_worktrees_actions_lib.sh`) builds its `wt_of` branch-to-path map with the guard `[[ -n $wbranch && $wbranch != DETACHED ]]`, then iterates branches only. A detached worktree is never passed to `delete_candidate` or `remove_worktree_safe`, so it is never removed.
- No error is raised; the omission is silent.

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
- [ ] High
- [x] Medium
- [ ] Low

Stale detached worktrees accumulate and must be removed by hand; the skill's report gives no signal that they are safe to delete. No data loss occurs.

## Suspected Cause / Notes

- `scripts/bash/cleanup_worktrees_actions_lib.sh`, `run_apply`: the `wt_of` map skips `DETACHED` entries and deletion is keyed on branch names.
- `scripts/bash/cleanup_worktrees_lib.sh`, `classify_branch` and `run_report`: the ladder is only ever invoked with a branch name from `enumerate_branches`; a detached HEAD commit is never fed to it. The individual rungs (`classify_ancestry`, `classify_content_neutral`, `classify_cherry_equivalent`, `classify_residual_commit`) accept any committish and can be reused for a SHA.
- `compute_protected` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh`) already handles the caller's own detached HEAD by protecting the worktree path, so path-based protection is available for a detached candidate.
- File-size constraint: `cleanup_worktrees_lib.sh` is 479 lines against the 500-line cap, so the detached-worktree classification and removal logic should live in a new sourceable library file (or in the 382-line actions library) rather than in the classification library.
- The `.claude/skills/cleanup-merged-worktrees/SKILL.md` report-line contract and workflow prose describe only branch candidates and must be updated to describe the detached-worktree record and its apply-mode handling.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: new bats cases driven by checked-in scenario fixtures under `tests/fixtures/cleanup_worktrees/scenarios/` for a merged detached worktree (removed), an unmerged detached worktree (no-op), a dirty merged detached worktree (`BLOCKED-DIRTY`, no force), a locked detached worktree (skipped), and the caller's own detached worktree (`PROTECTED_CURRENT`, never removed).
- [x] Integration scenario to retest: run report and apply modes against the live checkout and confirm the `base-wt` detached worktree on `fb30a9a5` is classified and removed.
- [x] Manual verification notes: `git worktree list` no longer shows the removed registration; no `--force` argv appears in the stub log; `git worktree prune` is never invoked.

## Acceptance Criteria

- [ ] Report mode emits exactly one `DETACHED|<path>|<sha>|<state>` record for every registered worktree whose porcelain stanza carries `detached`, excluding the main worktree, where `<state>` is produced by the existing classification ladder applied to `<sha>` against `main` and is one of `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`.
- [ ] Apply mode removes, via `git worktree remove <path>` with no force flag, every detached worktree whose fresh same-process re-classification is `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, or `MERGED_EQUIVALENT`, emitting `ACTION|worktree-remove|<path>|OK` on success.
- [ ] Apply mode never attempts removal of a detached worktree classified `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`, never removes the main worktree, and never removes the caller's current worktree (path match via `compute_protected`).
- [ ] A dirty delete-eligible detached worktree is reported with `DIRTY|<path>|<status-line>` records and `ACTION|worktree-remove|<path>|BLOCKED-DIRTY`; a `locked` detached worktree is skipped with `ACTION|worktree-remove|<path>|BLOCKED-LOCKED` and no `git worktree remove` invocation; a `prunable` detached worktree remains report-only with no removal or prune invocation.
- [ ] A hard git failure during detached-worktree classification maps to `ANCESTRY_ERROR`, performs no removal, and yields a non-zero apply return code.
- [ ] New bats tests under `tests/shell/` exercise each of the five behaviors above through the checked-in git stub and scenario fixtures, without creating temporary files or scratch repositories.
- [ ] `.claude/skills/cleanup-merged-worktrees/SKILL.md` documents the `DETACHED|` report record, the detached-worktree apply-mode behavior, and the `BLOCKED-LOCKED` result; the `cleanup-worktrees.sh --help` text lists the `DETACHED|` record.
- [ ] `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`, and `bash scripts/bash/shell-qc.sh test --coverage` pass in a single clean loop with the reported `Bash coverage (lines)` value at or above 85%, and no shell file in `scripts/bash/` exceeds 500 lines.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
