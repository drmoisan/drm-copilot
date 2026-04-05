# orchestrator-not-following-sequential-tasks (Issue #101)

- Date captured: 2026-03-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-not-following-sequential-tasks/ (Issue #101)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #101
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/101
- Last Updated: 2026-03-14
- Work Mode: full-bug

## Summary

When `csharp-orchestrator` classifies a request as the small path, it skips the mandatory short-path promotion/folder lifecycle and delegates straight to `csharp-atomic-planning` (and then execution). This bypass leaves the orchestration variables unset, prevents potential/issue/folder artifacts from being created, and violates the repository’s shared `feature-promotion-lifecycle` contract for short-path work.

## Environment

- OS/version: Windows (user environment on 2026-03-14; exact version not captured in prompt transcript)
- Python version: N/A — failure occurs in C# orchestration workflow, not Python execution
- Command/flags used: `/orchestrate-csharp-work In the current add-in, when I click the Sort Email button, it automatically begins the form applying Dark Mode. This add-in should be able to detect whether the system is in Dark Mode or Light Mode and follow the system. Please create this functionality and orchestrate the work to completion`
- Data source or fixture: `.github/agents/csharp-orchestrator.agent.md`, `.github/prompts/orchestrate-csharp-work.prompt.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, and `artifacts/orchestration/csharp-orchestrator-state.json`

## Steps to Reproduce

1. Invoke `csharp-orchestrator` through `.github/prompts/orchestrate-csharp-work.prompt.md` with a small, bounded C# request (for example, the Dark Mode detection request that was estimated at 2 production C# files and 1 test file).
2. Allow the orchestrator to complete budget estimation and route to the small path.
3. Observe the next action and the resulting checkpoint state.
4. Confirm that the orchestrator delegates directly to `csharp-atomic-planning`, then to `csharp-atomic-executor`, without first creating/filling a potential entry, promoting to issue, creating a branch, or creating an active feature folder.
5. Inspect `artifacts/orchestration/csharp-orchestrator-state.json` and confirm that `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, and `${feature-folder}` all remain `null` even though the workflow is marked complete.

## Expected Behavior

After choosing the small path, the orchestrator should still follow the mandatory short-path sequence defined by the shared lifecycle rules: establish classification variables, create/fill the potential entry, promote with `minor-audit` mode, create the branch and active feature folder, then hand off to planning/execution using the generated artifacts and persisted variables. At minimum, the orchestrator should not report completion while the required orchestration variables and feature artifacts were never created.

## Actual Behavior

The orchestrator routed directly from budget estimation to `csharp-atomic-planning`, followed by `csharp-atomic-executor`, and then marked the mission complete. The checkpoint shows:

- `"path_selected": "small"`
- `"completed_steps": ["phase-0-intake", "budget-estimate", "delegate-csharp-atomic-planning", "delegate-csharp-atomic-executor"]`
- all lifecycle variables still `null` (`promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`)

This means the orchestrator never performed the mandatory sequential lifecycle steps before planning/execution.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:

	From `.github/agents/csharp-orchestrator.agent.md` small path:
	`1. Delegate to csharp-atomic-planning via handoff Build C# atomic plan (preflight all clear).`

	From `.github/skills/feature-promotion-lifecycle/SKILL.md` canonical short path:
	`When orchestrator routing selects short path, promotion/folder initialization still occurs and MUST use minor-audit mode.`

	From `artifacts/orchestration/csharp-orchestrator-state.json` after the run:
	`"promotion-type": null,`
	`"short-name": null,`
	`"relativeFile": null,`
	`"long-name": null,`
	`"issue-num": null,`
	`"feature-folder": null`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

There appear to be contradictory orchestration contracts for small-path work:

- `.github/agents/csharp-orchestrator.agent.md` defines the small path as direct planning/execution only.
- `.github/prompts/orchestrate-csharp-work.prompt.md` defines the small path differently again, as a direct delegation to `csharp-typed-engineer`.
- `.github/skills/feature-promotion-lifecycle/SKILL.md` explicitly says short-path workflows still require promotion/folder initialization in `minor-audit` mode.

Because the orchestrator agent’s embedded small-path workflow omits those lifecycle steps entirely, the agent followed its local sequence and never set the persisted variables required by its own checkpoint schema. The failure is therefore likely an instruction precedence/design bug rather than a one-off execution mistake.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
	- Add workflow-contract coverage for `csharp-orchestrator` small-path routing so a small-scope request must produce non-null lifecycle variables or explicitly documented short-path artifacts.
	- Add a consistency check that the agent file, orchestration prompt, and shared lifecycle skill do not define conflicting small-path sequences.
- [x] Integration scenario to retest
	- Re-run `/orchestrate-csharp-work` with a known small-scope request and verify the resulting flow includes potential entry creation/fill, promotion in `minor-audit` mode, branch creation, active feature folder creation, then planning/execution.
	- Verify `artifacts/orchestration/csharp-orchestrator-state.json` contains populated values for `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, and `${feature-folder}` before the workflow can complete.
- [x] Manual verification notes
	- Inspect the created feature folder and confirm that `issue.md` exists with the persisted work-mode marker before the plan handoff occurs.
	- Confirm the orchestrator does not mark completion if the lifecycle variables are still `null`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch