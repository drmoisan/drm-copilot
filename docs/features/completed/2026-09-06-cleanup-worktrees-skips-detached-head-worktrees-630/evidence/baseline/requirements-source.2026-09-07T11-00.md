# Requirements Source Resolution (Issue #630)

Timestamp: 2026-09-07T11-00

Task: [P0-T2]

## Work Mode Marker

`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/issue.md` line 12 contains:

```
- Work Mode: full-bug
```

Command: `sed -n '12p' docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/issue.md`

EXIT_CODE: 0

Output: `- Work Mode: full-bug`

## Resolved AC Source

Under work mode `full-bug`, `.claude/skills/acceptance-criteria-tracking/SKILL.md` resolves the acceptance-criteria source to `spec.md` **only**. `user-story.md` is present in the feature folder but carries no acceptance criteria and is not an AC source under this mode. The `## Acceptance Criteria` section of `issue.md` is context only and is superseded, as the plan's Requirements Source section states.

Sole AC source: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`

## AC Inventory

Command: `grep -cE '^- \[ \] AC[0-9]+ ' docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`

EXIT_CODE: 0

Output: `24`

Command: `grep -cE '^- \[x\] AC[0-9]+ ' docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`

EXIT_CODE: 1

Output: `0`

Output Summary: `spec.md` contains exactly 24 acceptance-criteria checkbox items under `## Acceptance Criteria`, numbered AC1 through AC24 consecutively with no gaps and no duplicates. All 24 are unchecked (`- [ ]`) at the Phase 0 baseline; the checked count is 0, and `grep -c` exits 1 for a zero count, which is the observed exit code above.

## Check-Off Scope for This Delegation

No acceptance criterion is checked off in this delegation. AC check-off is scheduled for [P7-T11] per the plan.
