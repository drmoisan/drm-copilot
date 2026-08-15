# potential-to-issue-loses-promoted-record (Potential Bug)

- Date captured: 2026-08-15
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The `potential_to_issue` MCP tool reports a `destination_path` under `docs/features/potential/promoted/` that it does not write, while deleting the pre-promotion source file. The promotion receipt therefore names a path that does not exist, and the local lifecycle record is lost.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `mcp__drm-copilot__potential_to_issue` with `promotion_type: bug`, `work_mode: full-bug`
- Data source or fixture: `docs/features/potential/2026-08-15-blast-radius-module-map-forces-serial-runs.md`

## Steps to Reproduce

1. Create a potential bug entry with `new_potential_bug_entry` and author its content.
2. Call `potential_to_issue` against that entry.
3. Immediately list both `docs/features/potential/<name>.md` and the reported `destination_path` under `docs/features/potential/promoted/`.

## Expected Behavior

After promotion, the pre-promotion source is moved to `docs/features/potential/promoted/<name>.md`, and the path reported as `destination_path` in the tool receipt exists on disk.

## Actual Behavior

Neither file exists. The receipt reported:

```
"destination_path":"c:/Users/DanMoisan/repos/drm-copilot/docs/features/potential/promoted/2026-08-15-blast-radius-module-map-forces-serial-runs.md"
```

Both `ls` probes failed with `No such file or directory`. The mtimes of both `docs/features/potential/` and `docs/features/potential/promoted/` were current, so the tool touched both directories: it removed the source and did not create the destination.

The GitHub issue and the active feature folder were unaffected, so no content was lost — the active folder's `issue.md` carries the full authored text.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Local lifecycle-record loss only. Content is recoverable from the active feature folder and from the GitHub issue, so the impact is a broken promotion audit trail rather than data loss. The severity is raised above Low because the tool receipt asserts a file exists when it does not, which makes the receipt untrustworthy as evidence.

## Suspected Cause / Notes

This is the third observation of the same mismatch:

1. The aborted issue-447 preparation run, where the receipt named a promoted `destination_path` that did not exist afterward.
2. Issue #469 (`2026-08-13-csharp-legacy-gate-command-correctness`), where both the promoted record and its pre-promotion source were later found missing.
3. This occurrence (issue #472), the first caught immediately after the call rather than later.

The first two were recorded as undetermined cause, partly because the check happened well after the call and other commands had run in between. This occurrence rules out that explanation: the probe ran in the same message batch as the following MCP call, no `git clean` ran, and no session command removes files.

The consistent shape — source deleted, destination reported but absent — suggests the move is performed as a delete plus a write whose write leg fails silently, or that the destination write targets a path different from the one reported. Inspect the promotion implementation's move step and confirm whether its reported `destination_path` is the path actually written.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: the promotion move step; assert the reported `destination_path` exists after a successful promotion.
- [ ] Integration scenario to retest: promote a potential entry and assert both that the source is absent and that the reported destination is present and byte-equal to the source.
- [ ] Manual verification notes: the receipt must not report success unless the destination file is present on disk.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
