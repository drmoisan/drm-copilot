# completion-gate-rejects-adopted-feature-folder (Issue #992)

- Date captured: 2026-10-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/completion-gate-rejects-adopted-feature-folder/ (Issue #992)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #992
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/992
- Last Updated: 2026-10-28
- Work Mode: full-bug

## Summary

The orchestrator completion gate requires a successful `new_active_feature_folder` MCP receipt in the finishing run's own checkpoint. An item whose issue and feature folder were created before the run started (by an earlier session, `/orchestrate` pause, or the parallel planner) cannot satisfy that check, although the folder exists and is committed. The `issue_adoption` waiver covers `potential_to_issue` and `new_potential_bug_entry` only.

## Environment

- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `.claude/hooks/validate-orchestrator-output.ps1` (SubagentStop) and `validate_orchestration_artifacts.py orchestrator-state --require-complete`
- Data source or fixture: parallel run `pr-author-and-file-size`, item #989 (PR #991)

## Steps to Reproduce

1. Promote an item and create its feature folder in one session, then pause the orchestration and move its checkpoint to `artifacts/orchestration/handoff/`.
2. Include the item in a parallel run. The planner prepares it and the execution run adopts the existing issue (`issue_adoption`, waiving the two promotion tools).
3. Let the execution run reach DONE with PR open and CI green.

## Expected Behavior

An existing, committed feature folder is accepted as adopted work, with the same kind of evidence that `issue_adoption` accepts for the issue. The run reaches DONE.

## Actual Behavior

The stop hook returned `ROUTING_CONTRACT_BLOCKED: Checkpoint missing successful MCP receipt: new_active_feature_folder.` The run's own residual note records that the tool is outside the waivable set. The run could not record DONE until the receipt was copied by hand from the earlier checkpoint. Adding it under `delegation_receipts.promotion.feature_folder` was not enough; the check reads `mcp_call_receipts[]`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `ROUTING_CONTRACT_BLOCKED: Checkpoint missing successful MCP receipt: new_active_feature_folder.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Any item prepared outside its execution run stalls at the final gate and needs manual checkpoint editing. This affects every parallel or epic run whose items are prepared by a planner or an earlier session.

## Suspected Cause / Notes

The gate verifies that this run called the tool, not that the folder exists and was created correctly. `issue_adoption` has no counterpart for the feature folder. Not yet confirmed against the hook source. Check `validate-orchestrator-output.ps1`, the `issue_adoption` handling, and `.claude/rules/orchestrator-state.md`, plus the mirrors under `extensions/drm-copilot/resources/`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: extend the adoption waiver to `new_active_feature_folder` when the checkpoint's `feature-folder` exists on disk and is tracked in git; a missing or untracked folder still fails.
- [ ] Integration scenario to retest: a checkpoint with `issue_adoption` and an existing folder reaches DONE without a folder receipt.
- [ ] Manual verification notes: confirm a run that skips both promotion and adoption evidence is still blocked.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
