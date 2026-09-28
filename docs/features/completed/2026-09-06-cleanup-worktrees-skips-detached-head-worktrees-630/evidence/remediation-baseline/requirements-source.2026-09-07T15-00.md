# Requirements Source and Acceptance-Criteria Preservation Baseline

Timestamp: 2026-09-07T15-00
Task: [P0-T2]

## Requirements source resolution

- Work Mode: `full-bug`. Under `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug`
  resolves the acceptance-criteria source to `spec.md` only. `issue.md` is context, not an AC source.
- Fix-list source for this cycle:
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/remediation-inputs.2026-09-07T12-45.md`,
  items R1 through R6.
- Acceptance-criteria source:
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`.
  It remains the sole acceptance-criteria source for this cycle.

## Command 1 — checked acceptance criteria

Command: `git grep -h -c "^- \[x\] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
EXIT_CODE: 0

```
24
```

## Command 2 — unchecked acceptance criteria

Command: `git grep -h -c "^- \[ \] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
EXIT_CODE: 1
ExpectedExitCode: 1

Stdout was empty. `git grep` exits 1 with empty stdout when the pattern matches nothing.

Output Summary: the checked acceptance-criterion count in `spec.md` is 24 and the unchecked search
matched nothing, so all 24 criteria are checked at cycle entry.
`remediation-inputs.2026-09-07T12-45.md` is the fix-list source for this cycle, and `spec.md`
remains the sole acceptance-criteria source. This cycle adds, rewords, removes, and re-marks no
acceptance criterion; the only `spec.md` edit it makes is the L5 limitation entry added by P5-T7.
