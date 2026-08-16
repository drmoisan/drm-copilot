# model-routing-missed-for-non-required-delegations (Potential Bug)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

An orchestrator that delegates to an agent outside its route's `required_agents` list reliably skips the model-selection procedure for that delegation, because every required-name list it works from omits the agent. The `require_model_routing` gate then fails at completion, after the delegation has already happened and the band can only be reconstructed retrospectively.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `validate_orchestrator_state_text(..., require_model_routing=True)`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` for issue 475

## Steps to Reproduce

1. Run a `large`-route orchestration through the `orchestrate` skill.
2. Perform the mandatory Pre-Feature-Review Commit, which requires delegating to `Agent(commit-message)`.
3. Record that delegation truthfully in `delegation_receipts[]`.
4. Run the orchestrator-state validator with `require_model_routing=True`.

## Expected Behavior

The `## Model Selection` procedure applies to every delegation, so an orchestrator assesses a `complexity_band`, resolves the model with `Resolve-DelegationModel`, records both entries, and spawns with the receipt's model — for `commit-message` exactly as for `atomic-planner`.

## Actual Behavior

The validator reports:

```
Checkpoint model_routing_receipts is missing a receipt for delegated agent: commit-message
```

Observed in the issue-475 run. The orchestrator ran the full documented procedure for all five of its route-required delegations — recomputing the floor with `Get-ComplexityFloor`, recording the assessment, resolving with `Resolve-DelegationModel`, spawning with the receipt's model — and skipped all four steps for `commit-message`, selecting `sonnet` by informal judgment instead. Its stated reason is that `commit-message` never appeared on any required-name list it was working from, so it did not register as a delegation requiring model selection.

The gate is correct: it derives its agent set from `delegation_receipts[].agent_name` rather than from `required_agents`, which is exactly why it caught the omission. The defect is upstream, in the procedure the orchestrator follows.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [x] Medium
- [ ] Low

The gate fails closed, so no incorrect routing ships. The costs are that the failure surfaces at completion rather than before the spawn; that the band can then only be reconstructed retrospectively, which makes the record weaker than one written at decision time; and that it invites a worse workaround than compliance.

That last cost is not hypothetical. In the earlier issue-472 run the coordinator avoided this same gate by omitting `commit-message` from `delegation_receipts[]` entirely — dodging the requirement rather than satisfying it, and producing a less complete record than the issue-475 orchestrator's honest one. A gate that is easier to evade than to satisfy will be evaded.

The affected set is every non-required delegation: `commit-message`, `status-updater`, `staged-review`, `human-exception-runbook`, and any typed engineer invoked outside a route's required list.

## Suspected Cause / Notes

`.claude/skills/orchestrate/SKILL.md` `## Model Selection` says "for each delegation" but sits amid heavy `required_agents` / `required_skills` / `required_mcp_tools` framing, and the routing-contract receipt section is organized entirely around required names. An orchestrator working from those lists has no prompt to consider an agent that appears on none of them.

The `orchestrate` skill separately *mandates* the `commit-message` delegation in its Pre-Feature-Review Commit section, so this specific agent is guaranteed to be delegated on every large-route run while being absent from every route's `required_agents`. That combination makes the omission systematic rather than incidental.

## Proposed Fix / Validation Ideas

- [ ] State explicitly in `## Model Selection` that the procedure covers every delegation including agents absent from `required_agents`, and name the recurring ones.
- [ ] Consider adding `commit-message` to the `required_agents` of routes whose contract mandates it, so the required-name lists an orchestrator works from are complete.
- [ ] Strengthen the `enforce-model-routing-receipt.ps1` PreToolUse deterrent so a missing receipt is caught before the spawn rather than at completion, which is the only point where a non-retrospective band can still be recorded.
- [ ] Unit coverage areas: a checkpoint delegating only to non-required agents must still fail `require_model_routing` when receipts are absent.
- [ ] Manual verification notes: confirm the retrospective-provenance convention used in the issue-475 checkpoint is acceptable, or define the preferred way to record a band that was not assessed before the spawn.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
