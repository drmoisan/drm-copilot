# new-claude-worktree-session-commands-concatenated-in-container (Issue #1003)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/new-claude-worktree-session-commands-concatenated-in-container/ (Issue #1003)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1003
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1003
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

Running `drm-copilot: New Claude Worktree Session` from a dev container on a destination repo fails with a PowerShell `ParserError`. The extension's separate commands arrive at the terminal as one concatenated line, so the session never starts.

## Environment

- OS/version: Linux dev container (PowerShell, workspace `/workspaces/iar-migration`)
- Python version: not applicable
- Command/flags used: command palette `drm-copilot: New Claude Worktree Session`
- Data source or fixture: destination repo `iar-migration`

## Steps to Reproduce

1. Open a destination repo in a dev container with the drm-copilot extension.
2. Run `drm-copilot: New Claude Worktree Session`.
3. Read the terminal output.

## Expected Behavior

Each command runs on its own line: create the parent directory, `git worktree add`, `Set-Location`, `poetry install --with dev`, venv activation, the pre-claude hook, then `claude`.

## Actual Behavior

The terminal echoes the commands correctly, then receives them joined with no separators:

```
New-Item -ItemType Directory -Force -Path '/workspaces/iar-migration-wt' | Out-Nullgit -C '/workspaces/iar-migration' worktree add ... -b 'iar-migration-wt-2026-10-30T10-27'Set-Location '...'poetry install --with dev& './.venv/Scripts/Activate.ps1'if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { ... }claude --dangerously-skip-permissions
ParserError:
Line |   1 | … 7'poetry install --with dev& './.venv/Scripts/Activate.ps1'if (Test-P …
     |   ~~ Unexpected token 'if' in expression or statement.
```

No worktree is created and Claude does not launch.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The command is unusable in this container environment. Local Windows use is unaffected.

## Suspected Cause / Notes

`extensions/drm-copilot/src/extension.ts` (around lines 203 to 234) sends each command with `terminal.sendText(command, true)`. In the container's PowerShell terminal the newlines are lost, so the commands are pasted as one line. Possible causes: the sends arrive faster than the shell can accept them, or the remote terminal path drops the trailing newline.

A second defect is visible in the same output. The activation command is `./.venv/Scripts/Activate.ps1`, which is the Windows layout. Linux venvs use `.venv/bin/Activate.ps1`, so activation would fail on Linux even after the concatenation is fixed. The Codex worktree session sends commands the same way (lines 313 to 328) and probably has the same fault.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: command builder returns a platform-correct activation path; the session launcher emits the commands as one script, or as `;`-separated statements in one `sendText`, instead of many sends.
- [ ] Integration scenario to retest: Linux dev container and Windows host.
- [ ] Manual verification notes

Prefer a single script block per session so the result does not depend on terminal timing. Apply the same change to the Codex worktree session.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
