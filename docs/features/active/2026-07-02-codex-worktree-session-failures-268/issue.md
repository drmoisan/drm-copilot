# codex-worktree-session-failures (Issue #268)

- Date captured: 2026-07-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-worktree-session-failures/ (Issue #268)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #268
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/268
- Last Updated: 2026-07-02
- Work Mode: full-bug

## Summary

`drm-copilot: New Codex Worktree Session` currently emits invalid PowerShell for Codex trust setup, later relies on a bare `codex` command that may not exist on `PATH`, and does not ensure new worktrees receive this repository's Codex customizations before Codex starts.

## Environment

- OS/version: Windows / PowerShell
- Python version: Not applicable
- Command/flags used: VS Code command `drm-copilot: New Codex Worktree Session`
- Data source or fixture: Local `drm-copilot` worktree command implementation and tests

## Steps to Reproduce

1. Run `drm-copilot: New Codex Worktree Session` in a repository that uses the generated Codex trust setup command.
2. Observe the generated trust command fragment containing `if (...) { ... }; elseif (...) { ... }`.
3. Run the command in an environment where `codex` is not available on `PATH`.
4. Start a new Codex worktree where `.codex` and `.agents` are not already present in the destination.

## Expected Behavior

The command creates the git worktree, moves into it, configures Codex trust without a PowerShell parse error, installs and activates Poetry when applicable, runs the configured post-Codex script in a first-run-safe way, and starts Codex using a resolved executable path.

## Actual Behavior

The trust setup command can fail with `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` because the builder joins fragments with `; ` and emits `; elseif`.

The command can later fail with `codex: The term 'codex' is not recognized...` when `codex` is not available on `PATH`.

The new Codex worktree may start without repo-local `.codex` and `.agents` folders, so hooks, agents, and skills may not load from the worktree.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```text
elseif: The term 'elseif' is not recognized as a name of a cmdlet...
codex: The term 'codex' is not recognized...
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Likely files:

- `extensions/drm-copilot/src/codex-worktree-session.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `.codex/scripts/post-codex-worktree-session.ps1`
- PowerShell tests for the new script following existing conventions

The extension must remain generic. Repository-specific copy behavior belongs in the configured post-Codex script mechanism, not hardcoded extension logic.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [x] Manual verification notes

Acceptance criteria:

- Running the command no longer emits a PowerShell command containing `; elseif`.
- The trust setup command can run without the `elseif` parse error.
- Missing Codex CLI produces the clear preflight error, or the command uses a resolved executable path.
- `.codex/scripts/post-codex-worktree-session.ps1` exists in this repo.
- A new Codex worktree receives `.codex` and `.agents` before Codex starts.
- The copy behavior is repo-specific through the configured post-Codex script mechanism.
- The extension remains generic.
- Regression tests cover trust command parsing/formatting, Codex CLI resolution, post-Codex script first-run behavior, and copy behavior for `.codex` and `.agents`.
- No unrelated files are changed.
- Applicable TypeScript and PowerShell formatting, lint/typecheck, and test commands pass in the repository-required order.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
