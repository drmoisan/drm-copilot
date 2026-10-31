# merge-gate-epic-mode-string-false-treated-as-true (Issue #1001)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/merge-gate-epic-mode-string-false-treated-as-true/ (Issue #1001)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1001
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1001
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

Branch 1 of `.claude/hooks/enforce-epic-merge-gate.ps1` casts the checkpoint's `epic_mode` value with `[bool]`, so the string `"false"` evaluates to true and the epic-child branch is entered. Found during the #997 work and recorded in PR #1000.

## Environment

- OS/version: Windows 11, PowerShell 7
- Python version: not applicable
- Command/flags used: `gh pr merge <N> --merge` intercepted by the PreToolUse merge gate
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` with `"epic_mode": "false"`

## Steps to Reproduce

1. Write a checkpoint whose `epic_mode` is the JSON string `"false"`.
2. Run the merge gate against `gh pr merge <N> --merge`.
3. Observe that branch 1 treats the checkpoint as epic mode.

## Expected Behavior

Only the JSON boolean `true` enters the epic-child branch, as the green-CI branch added in #997 already requires.

## Actual Behavior

Any non-empty string, including `"false"`, casts to true.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none; found by code reading.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

The misparse grants no access beyond what a real `epic_mode: true` already grants. It is a correctness defect in an authorization hook.

## Suspected Cause / Notes

The `[bool]` cast in branch 1 of `enforce-epic-merge-gate.ps1`. Check the other branches and sibling hooks for the same cast.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester rows for `"false"`, `"true"`, `$true`, `$false`, and absent `epic_mode`.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Accept only a real boolean `true`. Mirror the change into the extension resources copy.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
