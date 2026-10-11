# epic-orchestrator-state-validator-crashes-on-unhashable-merge-status (Issue #793)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status/ (Issue #793)
- Related: #659

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #793
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/793
- Last Updated: 2026-09-30
## Summary

The Python epic orchestrator-state validator raises an uncaught `TypeError` instead of reporting a validation error when a feature's `merge_status` is a list or a dict. The TypeScript port handles the same input without crashing, so the two implementations diverge. Found during #659 preparation.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_orchestration_artifacts epic-orchestrator-state <checkpoint>` or a direct call to `_validate_merge_status_enum`
- Data source or fixture: an epic checkpoint whose `features[]` entry has `"merge_status": ["merged"]` or `"merge_status": {"x": 1}`

## Steps to Reproduce

1. From the repository root, run `python -c "from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_merge_status_enum([{'folder':'a','merge_status':['x']}]))"`.
2. Repeat with `'merge_status': {'x': 1}`.

## Expected Behavior

The validator returns an error such as `Epic checkpoint feature 'a' has invalid merge_status: ['x']`, as it does for an invalid string.

## Actual Behavior

```
File "scripts/dev_tools/validate_epic_orchestrator_state.py", line 235, in _validate_merge_status_enum
    if merge_status is not None and merge_status not in VALID_MERGE_STATUS:
TypeError: unhashable type: 'list'
```

The same error is raised with `unhashable type: 'dict'`. Reproduced on main at ae7c7779.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior. `VALID_MERGE_STATUS` and `MERGED_STATUSES` are sets (`validate_epic_orchestrator_state.py:50-60`), so a membership test with an unhashable operand raises. Other unguarded membership tests: line 296 (`dep_merge_status not in MERGED_STATUSES`) and line 385 (`feature.get("merge_status") not in MERGED_STATUSES`). `_epic_orchestrator_state_launch_binding.py:226` compares with `==` and is not affected.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

A malformed checkpoint produces a traceback instead of an actionable error, which also defeats any caller that parses validator output.

## Suspected Cause / Notes

The TypeScript port is not affected: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:225` and `:363` check `typeof mergeStatus === "string"` before the set lookup, and line 278 calls `MERGED_STATUSES.has(depMergeStatus)`, which does not throw in JavaScript.

## Proposed Fix / Validation Ideas

- [ ] Guard each membership test with an `isinstance(merge_status, str)` check at lines 235, 296, and 385 of `validate_epic_orchestrator_state.py`.
- [ ] Add unit rows for list, dict, int, and bool values of `merge_status` on each of the three paths, asserting an error and no exception.
- [ ] Add a matching row to the TypeScript suite confirming the two implementations agree.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
