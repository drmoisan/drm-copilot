# cleanup-worktrees-scan-roots-and-orphan-root-split (Issue #741)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-scan-roots-and-orphan-root-split/ (Issue #741)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #741
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/741
- Last Updated: 2026-09-27
## Summary

After #706 fixed the Windows drive-letter false positive for `registration-lost`, two more defects remain in `scripts/bash/cleanup-worktrees.sh`: report mode scans a fixed pair of roots, and orphan-root parsing breaks on Windows drive letters.

## Environment

- OS/version: Windows (Git Bash)
- Python version: n/a (bash)
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh`; `CLEANUP_WT_ORPHAN_ROOTS`
- Data source or fixture: #706 final report (FU-706-1, FU-706-2 and FU-706-7)

## Steps to Reproduce

1. Report mode scans only `<main>-wt/` and `<main>/.claude/worktrees/`. Worktrees elsewhere, such as scratchpad plan homes and `drm-copilot-parallel-*-plan` directories, are not scanned. This is likely why 4 of 71 worktrees went unflagged on 2026-09-25 (unconfirmed).
2. `CLEANUP_WT_ORPHAN_ROOTS` is split on `:` (`cleanup_worktrees_report_records_lib.sh:129-136`), so `C:/...` roots are cut apart.
3. The `load_helper` wrapper is duplicated across three tests, and the drive-letter check duplicates `cleanup_worktrees_preserve_lib.sh:161`.

## Expected Behavior

Scan roots derive from every registered worktree's parent (`git worktree list`) plus the configured roots. The root list uses a Windows-safe separator.

## Actual Behavior

As above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #706 FU-706-1, FU-706-2 and FU-706-7.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Roots were hard-coded for the common layout.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: derive the scan roots from the registrations; accept a `;`- or newline-separated `CLEANUP_WT_ORPHAN_ROOTS`, or split with drive letters in mind; add bats cases for `C:/` roots; deduplicate the helpers.
- [ ] Integration scenario to retest: report mode on a Windows checkout finds worktrees in non-standard directories.
- [ ] Manual verification notes: mind the kcov `set -u` + `bash -c` trap (memory note kcov-bash-c-source-set-u).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
