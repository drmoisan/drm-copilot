# model-routing-receipt-gate-has-no-epic-seam (Issue #662)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/model-routing-receipt-gate-has-no-epic-seam/ (Issue #662)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #662
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/662
- Last Updated: 2026-09-08
## Summary

`.claude/hooks/enforce-model-routing-receipt.ps1` hard-codes `artifacts/orchestration/orchestrator-state.json` as its only checkpoint path and contains no reference to an epic checkpoint. An `epic-orchestrator` maintains `artifacts/orchestration/epic-orchestrator-state.json` by definition, so when it delegates `Agent(pr-author)` for the integration-to-`main` PR it cannot satisfy the presence-only gate however correctly it performed model selection.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Claude Code runtime.
- Python version: not applicable (PowerShell hook).
- Command/flags used: `Agent(pr-author)` delegation from `epic-orchestrator` at epic completion.
- Data source or fixture: epic #655, integration PR #656.

## Steps to Reproduce

1. Run an epic to completion of its final wave; the per-feature `orchestrator-state.json` in the worktree describes a child or a superseded run, not the epic.
2. From `epic-orchestrator`, delegate `Agent(pr-author)` for the integration PR.
3. Observe the model-routing receipt deterrent evaluating the per-feature checkpoint, which carries no receipt for this delegation.

## Expected Behavior

When the calling agent is `epic-orchestrator` (or the delegation prompt carries the epic kickoff marker), the gate reads `model_routing_receipts[]` from `epic-orchestrator-state.json`, which the epic-orchestrate skill should require to carry receipts for its own `pr-author` and `orchestrator` delegations.

## Actual Behavior

The gate reads only the per-feature checkpoint. During epic #655 the main session had to author a per-feature checkpoint describing the integration-PR run (keyed to a newly promoted epic issue) so that a receipt could be recorded where the gate looks.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
enforce-model-routing-receipt.ps1: checkpoint path = artifacts/orchestration/orchestrator-state.json (no epic branch)
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Blocks the integration PR of every epic unless a per-feature checkpoint is written for it.

## Suspected Cause / Notes

- Same enforcement-seam class as the parallel worktree-removal gate, the pr-author PR-creation preflight, the pr-author epic base-branch check, and the preimplementation readiness check; five gates share the assumption that every run has a per-feature checkpoint.
- A single shared resolver (caller agent type or prompt marker -> checkpoint path) would close all five consistently.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester cases where the envelope's `agent_type` is `epic-orchestrator` and the receipt exists only in the epic checkpoint (allow) or in neither (deny).
- [x] Integration scenario to retest: an epic integration-PR delegation with receipts recorded in the epic checkpoint only.
- [x] Manual verification notes: the per-feature path stays authoritative for standalone runs.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
