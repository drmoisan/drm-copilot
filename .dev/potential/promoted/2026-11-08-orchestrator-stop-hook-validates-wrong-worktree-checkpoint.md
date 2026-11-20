# orchestrator-stop-hook-validates-wrong-worktree-checkpoint (Issue #1145)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-stop-hook-validates-wrong-worktree-checkpoint/ (Issue #1145)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1145
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1145
- Last Updated: 2026-11-08
## Summary

The orchestrator SubagentStop hook validates the wrong checkpoint when the orchestrator worked in a different worktree from the one the hook runs in. It reads `artifacts/orchestration/orchestrator-state.json` from the hook's own working directory (the session root or the subagent's isolation worktree), not from the item worktree the orchestrator actually used, so it blocks or passes based on an unrelated checkpoint.

## Environment

- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08; also coordinator-launched orchestrators working in `.claude/worktrees/<name>`
- Data source or fixture: orchestrator delegation prompt naming the item worktree and branch; item checkpoint inside that worktree

## Steps to Reproduce

1. From a coordinator session, launch `Agent(orchestrator)` with a prompt that names an item worktree (for example `.claude/worktrees/<name>`, branch `bug/x`) and work only there.
2. The orchestrator writes and updates the checkpoint in that worktree.
3. The orchestrator stops; `validate-orchestrator-output.ps1` (SubagentStop) runs.

## Expected Behavior

The stop hook resolves the target worktree the orchestrator worked in (via `Resolve-HookTargetWorktree`, or a worktree path or branch recorded in the delegation prompt or checkpoint) and validates that worktree's checkpoint.

## Actual Behavior

The hook validates the checkpoint in its own cwd (main checkout or isolation worktree): it blocks the orchestrator for errors in an unrelated checkpoint, or passes a stop that should have been blocked.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: stop-hook block naming a checkpoint path outside the orchestrator's item worktree.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Hooks run with the session's or subagent's cwd and main's scripts; payload cwd does not identify a coordinator's target item. `Resolve-HookTargetWorktree` exists (PRs #1113/#1120 fixed similar resolution for other hooks) but the orchestrator stop hook does not use it, or the delegation prompt's worktree/branch lines are not consulted. Related, already merged: #1140 and #1143 added `hook-epic-fan-in.ps1` with a scope-object seam; #1142 added nesting-depth checks; #1128 added a runbook stop hook with a TargetWorktree test pattern. Never encode absolute paths in committed artifacts; resolve by branch/issue identity or payload data.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: stop hook resolves the item worktree from the transcript/prompt (`branch:` line, worktree path) or payload; validates that checkpoint; falls back to cwd only when no target is identifiable; never validates an unrelated checkpoint.
- [ ] Integration scenario to retest: coordinator-launched orchestrator working in `.claude/worktrees/<name>` stops with a valid item checkpoint while the session root has a different or invalid one.
- [ ] Manual verification notes: document the resolution order in the orchestrate skill and the hook-context brief; destinations need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
