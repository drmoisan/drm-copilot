# cleanup-worktrees-consolidation-pr-merge-gate (Issue #634)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-consolidation-pr-merge-gate/ (Issue #634)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #634
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/634
- Last Updated: 2026-09-07
## Summary

The `cleanup-merged-worktrees` skill produces a consolidation pull request
(`documentationandmemories` into `main`), but the merge of that pull request is denied by
`.claude/hooks/enforce-epic-merge-gate.ps1`, because none of the gate's three accept paths can
ever describe a consolidation pull request. The skill's End-to-End Workflow step 5 therefore
depends on a merge that no agent running the skill can perform.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (the gate is PowerShell; no Python leg by standing policy)
- Command/flags used: the `gh` pull-request merge invocation carrying the merge-commit flag,
  issued against the consolidation pull request
- Data source or fixture: `.claude/hooks/enforce-epic-merge-gate.ps1`,
  `.claude/skills/cleanup-merged-worktrees/SKILL.md`

## Steps to Reproduce

1. Run the `cleanup-merged-worktrees` skill through its End-to-End Workflow to the point where
   step 4 has pushed the `documentationandmemories` branch and `Agent(pr-author)` has opened the
   consolidation pull request against `main`.
2. Confirm the required checks are green on that pull request.
3. Attempt to merge the consolidation pull request from the agent session.

## Expected Behavior

The skill's own workflow is executable end to end by the agent that runs it, or the skill states
plainly that the merge is a human step and does not present it as an agent action.

## Actual Behavior

The merge is denied with `EPIC_MERGE_GATE_BLOCKED`. The gate allows the merge only when one of
three checkpoint shapes is present:

1. a per-feature `artifacts/orchestration/orchestrator-state.json` with `epic_mode == true` and
   `step9_status == "passed"`;
2. an `artifacts/orchestration/epic-orchestrator-state.json` with
   `epic_merge_pr.ci_gate.conclusion == "success"` and, when the command names an explicit pull
   request number, a matching `epic_merge_pr.pr_number`;
3. an `artifacts/orchestration/parallel-orchestrator-state.json` with `route_id == "parallel"`
   whose target item, matched by `pr_number`, has `merge_status == "ci_green"`.

A cleanup run is neither a per-feature orchestration, nor an epic integration, nor a parallel
run, so it writes none of those three checkpoints. The gate correctly fails closed, and the
skill's step 5 is unreachable from the agent session that authored the pull request.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `EPIC_MERGE_GATE_BLOCKED: ... No checkpoint satisfied this gate.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The cleanup workflow is not blocked outright — a human can perform the merge — but every cleanup
run that consolidates content stalls at step 5 and requires an out-of-band human action that the
skill text does not disclose. The cost is an undocumented handoff, not data loss or an unsafe
allow.

## Suspected Cause / Notes

The gate was designed around three orchestration surfaces (per-feature, epic, parallel). The
cleanup skill is a fourth surface that produces a merge-eligible pull request but was never given
a checkpoint shape. Files to inspect:

- `.claude/hooks/enforce-epic-merge-gate.ps1` (451 lines; 49 lines of headroom against the
  500-line cap)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (264 lines; step 5 at the End-to-End
  Workflow section)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (455 lines)

Two candidate resolutions exist and must be weighed explicitly in `spec.md`:

- Document the consolidation merge as a human-only step in the skill. No enforcement surface is
  widened; the cost is an unautomatable step in every cleanup run.
- Add a fourth checkpoint shape (`artifacts/orchestration/cleanup-worktrees-state.json` carrying
  `consolidation_pr: {pr_number, head_sha, ci_gate.conclusion}`) and let the skill write it after
  the required checks pass. This removes the human step but widens a merge gate's allow side, so
  the constraint that prevents a self-recorded success conclusion must be stated and pinned by
  tests.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` — the
      three existing accept paths must keep behaving identically, pinned by regression tests.
- [x] Integration scenario to retest: a cleanup run reaching step 5 with the chosen resolution
      applied.
- [x] Manual verification notes: any `.claude/**` edit must be mirrored byte-identically into
      `extensions/drm-copilot/resources/claude-customizations/.claude/**` per
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
