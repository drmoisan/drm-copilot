# Stage I Cycle 3 Overlap Check: #1142 and the Early-Start Rule

Timestamp: 2026-11-08T20-02
Command: read of .claude/hooks/epic-invocation-nesting-depth.ps1 (Test-EpicInvocationNestingDepthApplies, Get-EpicInvocationNestingDepthDenyReason), the delegation path of .claude/hooks/enforce-epic-invocation-origin.ps1 (Invoke-EpicInvocationOriginDecision), `## Nesting Depth` of .claude/skills/epic-orchestrate/SKILL.md and .claude/skills/epic-run/SKILL.md, the Agent-tool preflight and the `Exception (issue #1097)` paragraph of .claude/agents/epic-orchestrator.md, and `## Early Dependent Starts (early_start)`; sh SCRATCH/issue-1097-c3-p2t1c.sh (function-sharing check); sh SCRATCH/issue-1097-c3-esscheck.sh (bundle re-copy and a focused debugging run of the two contract files, not gate evidence)
EXIT_CODE: 0
Output Summary:
  (a) No contradiction. The nesting-depth decision depends only on target, caller, and the configured setting.
  (b) Silent before this cycle; fixed in commit 8abf90f98 (subject carries `reduction: 0010`).
  (c) No contradiction. No function of the #1142 hook files is shared with the wave-barrier hooks.
  Focused debugging run (not evidence): early-start-skill-contract.Tests.ps1 and NestingDepthContract.Tests.ps1, 65 passed, 0 failed; the new case passed for the skill and its bundle copy.

## (a) Nesting-depth decision and the early-start kickoff lines

`Get-EpicInvocationNestingDepthDenyReason` takes `-Target` and `-Caller` only. It calls `Test-EpicInvocationNestingDepthApplies`, which returns true for a main-thread delegation to `epic-planner`, `epic-orchestrator`, `parallel-planner`, or `parallel-orchestrator`, and for one of those four calling `orchestrator`, and then reads only `Get-SubagentSpawnDepthSetting` (the environment value). `Invoke-EpicInvocationOriginDecision` in `enforce-epic-invocation-origin.ps1` passes the target from `Get-EpicInvocationOriginTargetSubagent` and the caller from `Get-EpicInvocationOriginCallerAgentType`; the delegation prompt is not read. An early-started dependent is an ordinary `Agent(orchestrator)` delegation from `epic-orchestrator` (step 3 of the procedure adds kickoff lines to the prompt only), so the decision is the same with or without the `Early start: true.` line.

## (b) Owners of the early-start parent steps under the main-session fallback

The fallback paragraph of `## Nesting Depth` has the main session launch each per-feature `Agent(orchestrator)` with the prompt the coordinator would have sent. Steps 1, 2, 9, and 10 of `## Early Dependent Starts (early_start)` are "Parent" steps, and `features[].early_start` and `early_start.synced_at` are written by `epic-orchestrator`, "the only writer of `features[]`". Neither the skill nor `.claude/agents/epic-orchestrator.md` (Agent-tool preflight, `Exception (issue #1097)` paragraph) stated an owner for the evidence wait, the checkpoint write and validation, the ancestry check, or the `synced_at` write under the fallback. The text was silent.

Fix (route of [P2-T1], decision D7 unchanged): one sentence after the opening paragraph of `## Early Dependent Starts (early_start)` in `.claude/skills/epic-orchestrate/SKILL.md`:

"Under the main-session fallback of `## Nesting Depth`, no `epic-orchestrator` runs the parent steps below, so the feature keeps the wave barrier and its `early_start_on` field is not acted on."

- Bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` re-copied (SHA-256 equal).
- New case `ESS-CLAUDE-FALLBACK-KEEPS-BARRIER` in `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1` (over the `ClaudeSkill` rows: the skill and its bundle copy). The file has 189 lines, below the 500-line tier.
- Codex skills (`.agents/skills/epic-orchestrate/SKILL.md`) are unchanged: #1142 added no `## Nesting Depth` section there.
- Test dispositions: `NestingDepthContract.Tests.ps1` unchanged (the sentence adds no `## Nesting Depth` heading line; the heading count stays 1); every other `ESS-` case unchanged; `test_frozen_epic_surface_matches_pinned_baseline_digest` is updated in [P2-T2] because the skill digest moves; `test_epic_skill_script_citations_shipped.py` unchanged (no script cited).
- Fix paths for 0010 `## Files Changed`: all three are already listed; no path is added in [P3-T2].

## (c) Shared hook functions

Functions defined in the #1142 hook files (9): Get-SubagentSpawnDepthSetting, Test-EpicInvocationNestingDepthApplies, Get-EpicInvocationNestingDepthDenyReason, Get-EpicInvocationOriginAllowDecision, Get-EpicInvocationOriginBlockDecision, ConvertFrom-EpicInvocationOriginPayload, Get-EpicInvocationOriginTargetSubagent, Get-EpicInvocationOriginCallerAgentType, Invoke-EpicInvocationOriginDecision. Occurrences of any of them in both `enforce-epic-wave-barrier.ps1` gates, both `epic-wave-barrier-early-start.ps1` twins, and `OrchestratorStateEpicWaveBarrier.psm1`: 0. Wave-barrier files that name either #1142 hook file: 0.
