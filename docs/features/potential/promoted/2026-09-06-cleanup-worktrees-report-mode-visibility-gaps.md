# cleanup-worktrees-report-mode-visibility-gaps (Issue #631)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-report-mode-visibility-gaps/ (Issue #631)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #631
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/631
- Last Updated: 2026-09-07
## Summary

`/cleanup-merged-worktrees` report mode does not surface orphaned worktree directories, stale
`refs/remotes/child/*` refs, or worktree-registration loss, and spends unnecessary time
re-classifying branches that are already known to be unmerged ancestors of another branch.

## Environment

- OS/version: Windows 11 (host), WSL Ubuntu (bash toolchain)
- Python version: not applicable (bash tool)
- Command/flags used: `/cleanup-merged-worktrees` (report mode)
- Data source or fixture: 2026-09-06 TaskMaster repository cleanup run

## Steps to Reproduce

1. Run `/cleanup-merged-worktrees` report mode against a large checkout that has accumulated
   orphaned worktree directories, stale remote-tracking refs from a prior epic run, up to 20
   epic child branches (some with up to 64 commits) descending from a common unmerged
   integration branch, and at least one worktree whose `.git` file references a
   `.git/worktrees/<name>` entry that has gone missing mid-run.
2. Observe the report output and the run duration.

## Expected Behavior

- Orphaned directories under `.claude/worktrees/` and `<repo>-wt/` that have no `.git` file and
  no worktree registration are reported as `ORPHAN_DIR|<path>|<size>`.
- Stale `refs/remotes/child/*` refs left over from an epic run (with no corresponding remote
  named `child`) are reported as `STALE_REF|<refname>`.
- A branch whose tip is already an ancestor of another `NOT_MERGED` branch is short-circuited
  and reported as `CHILD_OF|<branch>` instead of re-classifying every commit, reducing report
  runtime without changing the classification outcome relative to full classification.
- A worktree whose on-disk `.git` file points at a missing `.git/worktrees/<name>` entry is
  reported as `WARN|registration-lost|<path>`.
- Deletion of orphan directories and stale refs remains a manual, per-item confirmed action;
  report mode only surfaces the finding.

## Actual Behavior

- Four directories under `.claude/worktrees/` and `<repo>-wt/` had no `.git` file and no
  registration (one was a 6 GB checkout from July) and were not reported.
- 17 `refs/remotes/child/*` refs remained from a prior epic run, although no remote named
  `child` exists, and were not reported.
- Report mode took approximately 6 minutes, dominated by per-commit patch-id classification of
  20 epic child branches with up to 64 commits each, even though many of those branches were
  already ancestors of the epic integration branch and could have been short-circuited.
- `git worktree list` registrations for two session worktrees disappeared mid-run while their
  directories stayed on disk (cause not established; a concurrent session was active), and no
  warning was emitted for the resulting dangling `.git` file references.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: See run observations at
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`
  (gaps 7, 9c, 9d).

## Impact / Severity

- [ ] Blocker
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

- `scripts/bash/cleanup_worktrees_lib.sh` (`run_report`, `classify_branch`, `classify_ancestry`)
  has no orphan-directory or stale-ref scan, and `classify_branch` does not short-circuit on a
  known-ancestor branch.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (`parse_worktree_list`,
  `check_main_freshness`) has a precedent `WARN|main-divergence|` line but no equivalent for a
  missing `.git/worktrees/<name>` entry.
- `cleanup_worktrees_lib.sh` is at 479 of the 500-line cap in
  `.claude/rules/general-code-change.md`; new report-record logic must go in a new sibling
  library file.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: bats coverage for `ORPHAN_DIR`, `STALE_REF`, `CHILD_OF`, and
      `WARN|registration-lost` emission, driven through the `CLEANUP_WT_GIT_BIN` stub seam
      against new checked-in fixture scenarios.
- [x] Integration scenario to retest: a report-mode run against a fixture tree containing an
      orphan directory, a stale `child` remote-tracking ref, a branch that is an ancestor of
      another `NOT_MERGED` branch, and a worktree with a missing `.git/worktrees/<name>` entry.
- [ ] Manual verification notes

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
