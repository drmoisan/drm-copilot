# codex-worktree-session-regression (Issue #281)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-03-codex-worktree-session-regression-281/ (Issue #281)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #281
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/281
- Last Updated: 2026-07-03
- Work Mode: full-bug

## Summary

`drm-copilot: New Codex Worktree Session` still emits a malformed Codex trust command, does not copy the repo-local `.codex` and `.agents` customizations into the created worktree, and starts `codex` through an unresolved bare executable name. The behavior expected from Issue 268 is not present in the merged release state.

## Environment

- OS/version: Windows PowerShell on Windows
- Python version: 3.13 virtual environment created by `poetry install --with dev`
- Command/flags used: VS Code command `drm-copilot: New Codex Worktree Session`
- Data source or fixture: Worktree `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-08-58` created from `drm-copilot` at `476b110`

## Steps to Reproduce

1. From `C:\Users\DanMoisan\repos\drm-copilot`, run `drm-copilot: New Codex Worktree Session`.
2. Allow the command to create a new worktree and switch into it.
3. Observe the generated PowerShell command sequence through Codex launch.

## Expected Behavior

The command creates the git worktree, changes location to the new worktree, adds Codex trust without a PowerShell parse error, installs or activates Poetry when applicable, runs `.codex/scripts/post-codex-worktree-session.ps1`, copies `.codex` and `.agents` into the new worktree before launch, and starts Codex using extension-level executable resolution.

## Actual Behavior

The trust setup command emitted `elseif` at the start of a new prompt statement, which PowerShell treated as a command instead of part of the preceding `if` statement. The post-Codex script path check ran but neither `.codex` nor `.agents` was copied into the worktree. The final launch attempted a bare `codex` command and failed because the executable was not resolved.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```powershell
elseif: The term 'elseif' is not recognized as a name of a cmdlet, function, script file, or executable program.
codex: The term 'codex' is not recognized as a name of a cmdlet, function, script file, or executable program.
```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The bundled post-worktree script currently derives the source root from its own copied `.codex/scripts` path, so a destination worktree copy resolves the destination as both source and destination and returns without copying. The root `.codex/scripts/post-codex-worktree-session.ps1` in the failed worktree is only a strict-mode stub. The extension command builder should also be checked for trust command line-break serialization and Codex executable resolution.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: trust command serialization, Codex executable resolution, post-worktree copy script source-root resolution, rerun behavior
- [x] Integration scenario to retest: generated terminal command sequence contains the configured post-Codex script and launches resolved Codex executable
- [x] Manual verification notes: simulate a new worktree with `.codex` and `.agents` absent before running the post-Codex script

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
