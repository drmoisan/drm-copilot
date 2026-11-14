# worktree-agent-inherits-main-venv (Issue #1127)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/worktree-agent-inherits-main-venv/ (Issue #1127)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1127
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1127
- Last Updated: 2026-11-08
- Work Mode: full-bug

## Summary

An agent running `poetry install` in a sibling worktree changes the packages in the main checkout's `.venv`, because the session environment points Poetry at that environment. Agent worktrees should use their own virtual environment.

## Environment

- OS/version: Windows 11 Pro, PowerShell 7, Claude Code
- Python version: 3.13 through Poetry
- Command/flags used: `poetry install` in an agent worktree under `.claude/worktrees/`
- Data source or fixture: observed in iar-migration (E1/E2, 2026-11-07/08), and repeatedly in this repository (drm-copilot `.pth` files repointed at a worktree during Epic #1019)

## Steps to Reproduce

1. From a session whose `VIRTUAL_ENV` (or Poetry configuration) points at the main checkout's `.venv`, create an agent worktree.
2. Run `poetry install` in the worktree.
3. Observe that the main checkout's `.venv` packages and editable-install `.pth` files now point at the worktree.

## Expected Behavior

Each agent worktree uses its own virtual environment, so installs in a worktree never change the main checkout's environment.

## Actual Behavior

The main checkout's `.venv` is modified. In iar-migration an agent restored it with `poetry sync`; in drm-copilot the coordinator restored it with `poetry install` from the main checkout. Agents worked around it with `env -u VIRTUAL_ENV`, which in a worktree with no `.venv` creates a nearly empty one.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: drm-copilot 2026-11-06, `drm_copilot_discovery.pth` pointed at `.claude/worktrees/docs-1031-r2` after a worktree `poetry install`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The session environment carries `VIRTUAL_ENV` and Poetry resolves the active environment from it, not from the worktree. Fix options: `POETRY_VIRTUALENVS_IN_PROJECT=true` per worktree, or an explicit `poetry env use` in a worktree bootstrap. The fix must cover how agent worktrees are created and the instructions agents receive.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: the worktree bootstrap sets an in-project environment and never inherits the session `VIRTUAL_ENV`.
- [ ] Integration scenario to retest: `poetry install` in a fresh worktree leaves the main checkout's `.venv` byte-identical (compare `.pth` files and the installed package list).
- [ ] Manual verification notes: document the rule in the `execution-environment` skill and its mirrors; state whether destination repositories need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
