# orchestrator-state-routing-contract-mismatch (Issue #230)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-state-routing-contract-mismatch/ (Issue #230)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #230
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/230
- Last Updated: 2026-06-24
- Work Mode: full-bug

## Summary

The strict `require_complete` orchestrator-state validation (the routing contract in `scripts/dev_tools/_orchestrator_state_routing.py` against `config/orchestration-routing.json`) cannot be satisfied with truthful receipts in the current runtime. The matrix requires agent names and discrete skill/MCP receipts that do not match the agents/skills/tools actually available.

## Environment

- OS/version: repository orchestration runtime
- Python version: project default (Poetry)
- Command/flags used: `validate_orchestration_artifacts` with `require_complete: true` (artifact_type `orchestrator-state`)
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json`, `config/orchestration-routing.json`

## Steps to Reproduce

1. Complete a `large`-route orchestration through PR creation and the CI green gate.
2. Validate the checkpoint with `validate_orchestration_artifacts` using `require_complete: true`.
3. Observe the routing-contract errors.

## Expected Behavior

A truthfully completed orchestration produces a checkpoint that passes `require_complete: true` validation, with required agents/skills/MCP receipts that correspond to the agents and tools the runtime actually provides.

## Actual Behavior

The completion gate reports, for the `large` route:
- `required_agents must match routing matrix` and `missing required agent receipt: feature-reviewer` / `commit-steward` — but the available review agent is `feature-review` (not `feature-reviewer`), and there is no `commit-steward` agent (commits are made directly per the orchestrate skill's Pre-Feature-Review Commit step).
- `required_skills`/`required_mcp_tools must match` and missing `skill_receipts` / `mcp_call_receipts` for skills/tools such as `orchestrator-workflow`, `repo-automation-adapter`, and `collect_commit_context` that are not emitted as discrete receipts.

The default (non-strict) structural validation passes; only the strict completion gate is unsatisfiable.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `Checkpoint missing required agent receipt: feature-reviewer.` / `Checkpoint missing required agent receipt: commit-steward.` (and analogous required_skills / required_mcp_tools errors) from `require_complete: true`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The enforced structural validation passes, so DONE is not blocked, but the strict completion gate cannot be used as an acceptance check because it diverges from the real agent/skill/tool inventory.

## Suspected Cause / Notes

The routing matrix (`config/orchestration-routing.json`) and `_orchestrator_state_routing.py` encode a canonical agent/skill/tool naming scheme (`feature-reviewer`, `commit-steward`, `orchestrator-workflow`, `repo-automation-adapter`, `collect_commit_context`, etc.) that does not match the actual `.claude/agents/` roster (`feature-review`, no `commit-steward`) or the runtime receipts. Files to inspect: `config/orchestration-routing.json`, `scripts/dev_tools/_orchestrator_state_routing.py`, `.claude/agents/`.

## Proposed Fix / Validation Ideas

- [ ] Reconcile the routing matrix names with the actual agent roster (e.g., `feature-review`), and either provide a `commit-steward` agent or remove it from the required set and represent the orchestrator's direct commit step.
- [ ] Define how `skill_receipts` and `mcp_call_receipts` are emitted, or relax the required lists to the tools that are actually receipted.
- [ ] Unit coverage: a truthful completed-large checkpoint passes `require_complete`; missing/renamed receipts fail with clear messages.
- [ ] Integration scenario: re-run a `large` orchestration completion and confirm `require_complete: true` passes.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch