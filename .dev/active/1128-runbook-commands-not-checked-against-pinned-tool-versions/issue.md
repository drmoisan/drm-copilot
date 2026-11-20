# runbook-commands-not-checked-against-pinned-tool-versions (Issue #1128)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/runbook-commands-not-checked-against-pinned-tool-versions/ (Issue #1128)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1128
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1128
- Last Updated: 2026-11-08
- Work Mode: full-bug

## Summary

The `human-exception-runbook` skill wrote a Windows packaging runbook that told the user to run `python -m nuitka --clean-cache=clcache`. Nuitka 4.3.4, the version pinned in the lockfile, rejects that value; `--clean-cache=all` works. Runbook commands are not checked against the pinned tool version.

## Environment

- OS/version: Windows 11 Pro, Claude Code
- Python version: per the iar-migration lockfile
- Command/flags used: `python -m nuitka --clean-cache=clcache`
- Data source or fixture: iar-migration E1 Windows packaging runbook, 2026-11-07/08

## Steps to Reproduce

1. Have the orchestrator invoke `human-exception-runbook` for a step that needs a tool command, in a repository whose lockfile pins the tool (Nuitka 4.3.4).
2. Read the generated runbook.
3. Run the command it gives.

## Expected Behavior

Every tool command in a runbook is either checked against the version pinned in the lockfile, or clearly marked as not verified, with the pinned version stated.

## Actual Behavior

The runbook gave a flag value the pinned version rejects, with no indication that the command had not been verified.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: Nuitka 4.3.4 rejects `--clean-cache=clcache`; `--clean-cache=all` is accepted.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The skill sources procedures MCP-first and web-second, and nothing ties a command to the installed or pinned version. Fix options: resolve the pinned version from the lockfile and check the command against that version's help or documentation; or mark each unverified command with an explicit "not verified against <tool> <version>" note. Do not weaken the runbook's purpose.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: version resolution from a lockfile fixture; an unverified command is marked; a verified command carries the version it was checked against.
- [ ] Integration scenario to retest: a runbook for a pinned tool produces either a verified or a marked command.
- [ ] Manual verification notes: update the `human-exception-runbook` skill and agent text and mirrors; state whether destination repositories need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
