# epic-preparation-orchestrators-lack-agent-tool-at-depth (Issue #1138)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-preparation-orchestrators-lack-agent-tool-at-depth/ (Issue #1138)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1138
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1138
- Last Updated: 2026-11-08
## Summary

`/epic-plan` and `/epic-run` break when the per-feature orchestrators they delegate to run two levels below the session root: those orchestrators had no Agent tool, so they could not delegate to task-researcher, atomic-planner, atomic-executor or the other specialists, and the epic stalled or the orchestrator did the work itself.

## Environment

- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a
- Command/flags used: `/epic-plan` and `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08
- Data source or fixture: epic-planner -> preparation-mode Agent(orchestrator) -> specialist chain

## Steps to Reproduce

1. From a session root, run `/epic-plan` (forks epic-planner) or `/epic-run` (epic-orchestrator).
2. epic-planner / epic-orchestrator delegates `Agent(orchestrator)` per feature.
3. The per-feature orchestrator attempts to delegate to atomic-planner or another specialist.

## Expected Behavior

Either the per-feature orchestrator has the Agent tool and delegates normally, or the workflow detects the missing Agent tool before starting work and fails fast with an actionable message, and the documented topology avoids the unsupported depth (for example, the coordinator session launches per-feature orchestrators directly, or the chain is flattened).

## Actual Behavior

Preparation orchestrators two levels down had no Agent tool. No preflight detected this; they proceeded without delegation or stalled. Note: in a separate drm-copilot session on 2026-11-08 an epic-run did delegate successfully at depth 2, so the condition depends on how the chain is entered (skill fork vs. direct agent, host, or version). Reproduce and characterize the exact condition first.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: per-feature orchestrator reported no Agent tool available.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Claude Code limits subagent nesting and/or does not give the Agent tool to subagents beyond a certain depth or when entered through a `context: fork` skill. The epic skills assume three levels (root -> epic agent -> orchestrator -> specialists) without stating or checking the assumption.

## Proposed Fix / Validation Ideas

- [ ] Preflight in orchestrator (and epic agents) that fails fast with a clear message when the Agent tool is missing.
- [ ] Document the depth assumption in epic-plan, epic-run, epic-orchestrate and orchestrate skills.
- [ ] Topology change: the coordinator session launches per-feature orchestrators (or the chain is flattened) so specialists are always reachable.
- [ ] Regression test for the preflight and the documented topology.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
