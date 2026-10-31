# cleanup-preserve-copies-older-snapshot-over-newer-main (Issue #1027)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-preserve-copies-older-snapshot-over-newer-main/ (Issue #1027)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1027
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1027
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

`cleanup-worktrees.sh --preserve` copies a `preserved_files[]` source file whole onto `target_path`. For `change_class: modified` records, the worktree's copy is often an older snapshot of a note that `main` has since extended, so copying it whole silently drops `main`'s newer lines.

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `cleanup-worktrees.sh --preserve` from the `cleanup-merged-worktrees` skill
- Data source or fixture: a manifest with a `preserved_files[]` record whose `change_class` is `modified` and whose `main` version is newer than the worktree's copy

## Steps to Reproduce

1. Have a worktree holding an older snapshot of a documentation or memory note that `main` has since extended.
2. Write a manifest with a `preserved_files[]` record for it, with `change_class: modified`.
3. Run `cleanup-worktrees.sh --preserve`.
4. Compare the staged file on the consolidation branch with `main`'s version.

## Expected Behavior

- For `modified` records, stage only the worktree's added lines onto `main`'s current version (a three-way merge against the merge-base, or an "added lines only" mode).
- Otherwise refuse the record with `ACTION|preserve-stage|<path>|REFUSED-WOULD-REGRESS`.
- Never overwrite a target whose `main` version has lines absent from the source.

## Actual Behavior

The source file is copied whole onto `target_path`, so `main`'s newer lines are silently lost.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none; the failure is silent.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The loss is silent and affects lesson and memory notes, which are the content the workflow exists to preserve.

## Suspected Cause / Notes

`--preserve` treats every record as a whole-file copy. It has no merge-base comparison and no regression check against the current `main` version. Same workflow as the sibling bug on checkpoint gates blocking the cleanup workflow; this defect is independent of it and can be fixed separately.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `--preserve` on a `modified` record whose `main` version is newer is either merged without losing `main` lines or refused with `REFUSED-WOULD-REGRESS`, and is never overwritten; an unmodified `main` version still copies as before; an `added` record is unaffected. Bats cases where the script is tested.
- [ ] Integration scenario to retest: the full cleanup workflow end to end (see the sibling bug).
- [ ] Manual verification notes

Language note: the script is bash; the fix stays in bash.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
