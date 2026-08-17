# promotion-lifecycle-loses-promoted-record (Issue #487)

- Date captured: 2026-08-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/promotion-lifecycle-loses-promoted-record/ (Issue #487)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #487
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/487
- Last Updated: 2026-08-17
- Work Mode: full-bug

## Summary

The promotion lifecycle — `potential_to_issue` followed by `new_active_feature_folder` — loses the promoted lifecycle record under `docs/features/potential/promoted/`. The `potential_to_issue` receipt reports a `destination_path` that is later absent from disk, and the pre-promotion source is gone, so the local lifecycle record is lost. This entry is scoped to the lifecycle as a whole rather than to `potential_to_issue` alone; a fourth observation with clean bracketing points at `new_active_feature_folder` as the removing operation.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `mcp__drm-copilot__potential_to_issue` with `promotion_type: bug`, `work_mode: full-bug`, followed by `mcp__drm-copilot__new_active_feature_folder` with `type: bug`, `work_mode: full-bug`
- Data source or fixture: `docs/features/potential/2026-08-15-blast-radius-module-map-forces-serial-runs.md`

## Steps to Reproduce

1. Create a potential bug entry with `new_potential_bug_entry` and author its content.
2. Call `potential_to_issue` against that entry.
3. Immediately list both `docs/features/potential/<name>.md` and the reported `destination_path` under `docs/features/potential/promoted/`.
4. Call `new_active_feature_folder` for the promoted issue.
5. List the same two paths again, and compare the mtimes of `docs/features/potential/promoted/` and of the newly created active feature folder.

## Expected Behavior

After promotion, the pre-promotion source is moved to `docs/features/potential/promoted/<name>.md`, and the path reported as `destination_path` in the tool receipt exists on disk. It continues to exist after `new_active_feature_folder` runs.

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

### Correction from a fourth observation (2026-08-16, issue #479)

**The attribution above is wrong, and the title of this entry is misleading.** A fourth observation with clean bracketing shows the promoted record SURVIVES `potential_to_issue` and is removed later:

1. `potential_to_issue` returned `ok: true` with a `destination_path`.
2. An immediate probe found the destination PRESENT at 6901 bytes, and the pre-promotion source correctly absent. The move had succeeded, contradicting observations 1-3.
3. `git checkout -b` ran (no file removal).
4. `new_active_feature_folder` ran.
5. A later probe found the destination ABSENT.
6. `docs/features/potential/promoted` and the newly created active feature folder carried the IDENTICAL mtime to the nanosecond (`2026-08-16 22:09:57.221665500 -0400`), indicating a single operation touched both.

The suspect is therefore `new_active_feature_folder`, not `potential_to_issue`. Observations 1-3 could not distinguish the two calls because each probed only once, after `potential_to_issue` but after `new_active_feature_folder` had also run, or well after both.

A further detail that made this hard to notice: because the promoted record is created and deleted within a single session and is never committed, its disappearance produces NO `git status` deletion entry. It simply stops appearing as untracked. Observation 3's claim that `git status` showed "a bare deletion" applies only when the source was already tracked from a prior commit.

Revised investigation target: inspect `new_active_feature_folder`'s implementation for a cleanup or move step that operates on `docs/features/potential/promoted/`. Re-scope this entry to the promotion lifecycle as a whole rather than to `potential_to_issue` alone, and rename it accordingly before promotion.

### Current repository state (2026-08-17)

The promoted records for the three most recent affected entries are present and committed on `main`. Each was added by its feature commit — `a43deb73`, `feca22fa`, and `a45a993b` respectively — not by the promotion tooling. This is consistent with agents having recreated the records by hand after noticing the loss, but it means the repository does not currently exhibit the absence this entry describes. Reproduction must therefore start from a fresh promotion rather than from an inspection of the committed tree.

The scope of this entry is the promotion lifecycle as a whole: `potential_to_issue` followed by `new_active_feature_folder`. The title names `potential_to_issue` only and is retained for continuity with the four prior observations; the fourth observation's bracketing points at `new_active_feature_folder` as the suspect.

### Re-scoping note (2026-08-17)

This entry is the re-scoped successor to `docs/features/potential/2026-08-15-potential-to-issue-loses-promoted-record.md`. The rename discharges the source entry's instruction to "re-scope this entry to the promotion lifecycle as a whole rather than to `potential_to_issue` alone, and rename it accordingly before promotion." All four prior observations and the correction above are retained verbatim from the source entry; only the H1 and the Summary were rewritten to name the lifecycle rather than the single tool.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: the promotion move step; assert the reported `destination_path` exists after a successful promotion. Additionally, `new_active_feature_folder`'s cleanup/move handling of `docs/features/potential/promoted/`.
- [ ] Integration scenario to retest: promote a potential entry and assert both that the source is absent and that the reported destination is present and byte-equal to the source; then create the active feature folder and assert the promoted record is still present.
- [ ] Manual verification notes: the receipt must not report success unless the destination file is present on disk.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
