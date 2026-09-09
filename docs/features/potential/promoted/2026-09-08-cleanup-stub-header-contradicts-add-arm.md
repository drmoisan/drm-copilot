# cleanup-stub-header-contradicts-add-arm (Issue #661)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-stub-header-contradicts-add-arm/ (Issue #661)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #661
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/661
- Last Updated: 2026-09-08
## Summary

The header comment of `tests/fixtures/cleanup_worktrees/stub-bin/git` states that no arm is defined for any subcommand that writes to the index or object database, because the dirt classifier must reach its staged-tree answer by reading only. Child #637 (preserve-file consolidation) added an `add)` arm for its staging path; it sat outside every merge-conflict region and auto-merged silently, so the header sentence is now false in the merged file. The report-mode non-mutation assertion enumerates a fixed denylist that carries no `add` entry, so a future regression that made report mode issue `git add` would pass it.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; bats 1.13.0.
- Python version: not applicable (bash).
- Command/flags used: `bash scripts/bash/shell-qc.sh test` on the merged integration branch.
- Data source or fixture: `tests/fixtures/cleanup_worktrees/stub-bin/git` after PR #653 and #654 both merged; child #632 finding NF-2.

## Steps to Reproduce

1. Read the header block of `tests/fixtures/cleanup_worktrees/stub-bin/git` on `main` at 06ca8a81.
2. Search the same file for an `add)` case arm.
3. Observe both the statement that no index-writing arm exists and the `add)` arm.

## Expected Behavior

The header describes the arms that exist, and the report-mode non-mutation assertion is expressed as an allowlist of read-only subcommands (or asserts that `add` never appears in the report-mode argv log), so a widened stub cannot silently make it blind.

## Actual Behavior

The product is safe: the only `add` callers are in the preserve staging path, which report mode never reaches. The residual is in the assertion, which is blind to exactly one newly available arm.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
stub header: "no arm is defined for any subcommand that writes to the index or object database"
stub body:   add) respond "add" ;;   (added by #637)
```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Documentation correctness plus one blind spot in a regression assertion.

## Suspected Cause / Notes

- A denylist assertion is only as complete as the world it was written against; a sibling feature widened that world without touching it.
- Both #632 and #637 own regions of the same stub; the fix is a header rewrite and an assertion that names `add` explicitly or inverts to an allowlist.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: extend the report-mode non-mutation test to assert that the argv log contains no `add`, `commit`, `write-tree`, or `update-index` invocation; a negative control that a scratch report-mode `git add` call fails it.
- [ ] Integration scenario to retest: none.
- [x] Manual verification notes: rewrite the header to list the index-writing arms and the paths permitted to call them.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
