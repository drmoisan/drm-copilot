# completion-consistency-codex-copy-and-fail-open-divergence (Issue #736)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/completion-consistency-codex-copy-and-fail-open-divergence/ (Issue #736)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #736
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/736
- Last Updated: 2026-09-27
## Summary

#708 (PR #726) fixed the Claude completion-consistency hook to read the Edit call's own target file. The Codex copy still has the original defect, and review found three related defects. One of them is a policy divergence: fail-open on Claude versus fail-closed on Codex.

## Environment

- OS/version: any
- Python version: n/a (PowerShell hooks)
- Command/flags used: Edit calls on orchestration checkpoints
- Data source or fixture: #708 `evidence/other/follow-ups.md` on main

## Steps to Reproduce

1. `.codex/hooks/enforce-completion-consistency.ps1:308` (and its bundle copy) still resolves the checkpoint from a relative path; `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:392-403` pins that behaviour.
2. The hook's patch step uses `String.Replace`, which replaces EVERY occurrence of `old_string`. The Edit tool replaces a single occurrence unless `replace_all` is set, so the reconstructed checkpoint can differ from what the Edit will actually produce.
3. When the targeted checkpoint is missing or unreadable, the Claude hook ALLOWS the Edit and the Codex hook DENIES it.
4. `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1:47-51` uses the default reader with a relative path, so it depends on the working directory. No test drives the default reader against a real file.

## Expected Behavior

Both surfaces read the targeted file, reproduce the Edit tool's replace semantics exactly, and behave identically on a missing checkpoint (fail-closed is the repository norm).

## Actual Behavior

As described in steps 1-4.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #708 follow-ups 1-4 and 6.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

#708 was scoped to the Claude surface under its D-decisions.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: port the #708 fix to Codex (rewrite the pinning test); honour `replace_all` (a single replacement by default); align both surfaces on fail-closed and record the decision; make the default-reader tests hermetic.
- [ ] Integration scenario to retest: an isolated-worktree subagent completing its checkpoint by Edit on both surfaces.
- [ ] Manual verification notes: post-merge live confirmation (#708 follow-up 5).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
