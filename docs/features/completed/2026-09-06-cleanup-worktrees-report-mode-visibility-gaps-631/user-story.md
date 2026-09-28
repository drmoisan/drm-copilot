This user-story.md is included despite full-bug work mode because epic_planner_readiness.py
requires it for every prepared epic child folder.

# cleanup-worktrees-report-mode-visibility-gaps (User Story)

- **Issue:** #631
- **Parent:** Epic `cleanup-merged-worktrees-hardening` (`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`), child B
- **Last Updated:** 2026-09-06

## Story

As an agent or operator running `/cleanup-merged-worktrees` in report mode, I want the report to
surface orphaned worktree directories, stale remote-tracking refs, and lost worktree
registrations, and to skip redundant per-commit classification for branches that are already
known ancestors of another unmerged branch, so that I can see the full picture of cleanup-eligible
filesystem and ref state in one report and complete a large-checkout run without either missing
findings or waiting through unnecessary re-classification work.

## Why this matters

The 2026-09-06 TaskMaster cleanup run left four unregistered directories, 17 stale
`refs/remotes/child/*` refs, and two worktrees with dangling `.git` registrations invisible to
report-mode output, and spent roughly six minutes re-classifying branches that were already
provably unmerged ancestors of another unmerged branch. None of these are apply-mode defects —
they are report-mode blind spots that leave manual cleanup decisions under-informed and make
large-checkout runs slower than they need to be.

## Acceptance Criteria

These criteria mirror `spec.md`'s Acceptance Criteria section; see that section for the full
verification detail (bats test structure, fixture requirements, and toolchain commands). This
list restates them from the operator's point of view and must not be treated as an independent or
divergent source of truth.

- [ ] When I run report mode against a checkout with an unregistered, `.git`-less directory under
      a known worktree-tracking root, I see an `ORPHAN_DIR|<path>|<size>` line for it, and I do
      not see one for a properly registered worktree. (spec.md AC 1)
- [ ] When I run report mode against a checkout with a stale `refs/remotes/<name>/*` ref left
      over from a prior run, I see a `STALE_REF|<refname>` line for it regardless of what the
      stale remote's name is, and I do not see one when the remote still exists. (spec.md AC 2)
- [ ] When a branch I'm reviewing is a git ancestor of another branch that the report already
      resolved as `NOT_MERGED`, I see both its unchanged `BRANCH|<branch>|NOT_MERGED` line and a
      new `CHILD_OF|<branch>|<ancestor>` line, and the report reaches that conclusion without
      running the expensive per-commit classification rungs for it. When the ancestor resolves to
      anything other than `NOT_MERGED`, I see the branch fully classified through the normal
      ladder with no `CHILD_OF` line. (spec.md AC 3)
- [ ] When a worktree's on-disk `.git` file points at a `.git/worktrees/<name>` entry that no
      longer exists, I see a `WARN|registration-lost|<path>` line for it, and I do not see one
      when the pointer still resolves. (spec.md AC 4)
- [ ] I can trust that the `CHILD_OF` short-circuit never changes an apply-mode outcome: a branch
      that would have been left in place before this change is still left in place after it,
      whether or not the short-circuit fired for it. (spec.md AC 5)
- [ ] Running the full existing test suite still passes unchanged after the shared `git` stub's
      `for-each-ref` key-specificity update, so I know this change did not silently break
      classification for every other scenario the tool already handles. (spec.md AC 6)
- [ ] I can look up all four new report-line shapes in the skill's Report Line Contract
      documentation, in both the repo copy and the pushed-down extension copy. (spec.md AC 7)
- [ ] `cleanup_worktrees_lib.sh` stays under its 500-line cap after this change. (spec.md AC 8)
- [ ] The full format/lint/test/coverage toolchain passes with line coverage at or above 85%.
      (spec.md AC 9)
- [ ] Deletion of anything this feature reports (orphan directories, stale refs) remains a manual
      action I confirm myself; the report never deletes on my behalf. (spec.md AC 10)
- [ ] None of the new detection logic or its tests hardcode the specific counts observed in the
      2026-09-06 run (four directories, 17 refs); the detection works generically for whatever a
      given checkout actually contains. (spec.md AC 11)
