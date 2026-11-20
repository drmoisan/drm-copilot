# codex-subagent-routing-attestation-launch-binding (Issue #552)

- Date captured: 2026-08-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-subagent-routing-attestation-launch-binding/ (Issue #552)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #552
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/552
- Last Updated: 2026-08-25
- Work Mode: full-bug

## Summary

Nested routed Codex workers can start before their exact deployment receipt is durable in the checkpoint that `SubagentStart` reads. The authority-store attestation is therefore invalid and the downstream mutation gate blocks the child before it can perform meaningful work.

## Environment

- OS/version: Windows/PowerShell repository runtime.
- Python version: Repository Python runtime used by `scripts/dev_tools/resolve_codex_deployment.py` and pytest.
- Command/flags used: Normal nested C3 routed `spawn_agent` delegation.
- Data source or fixture: Selected orchestration checkpoint, `codex_model_routing_receipts`, generated `.codex/agents/<deployment_agent>.toml`, and the `SubagentStart` authority-store attestation.

## Steps to Reproduce

1. Resolve a nested C3 `task-researcher` delegation but do not durably append the returned exact receipt before `spawn_agent`.
2. Start `task-researcher-c3`, causing `.codex/hooks/record-subagent-routing-attestation.ps1` to run at `SubagentStart`.
3. Attempt the child's first mutation; the mutation hook reads the invalid authority-store attestation and rejects the child.

## Expected Behavior

Before a routed child starts, the coordinator resolves it independently, validates the generated profile, and durably persists its exact receipt. `SubagentStart` then records `routing_valid: true`; the child can continue only if its profile name, model, reasoning effort, path, and SHA-256 match the receipt.

## Actual Behavior

The top-level exact receipt is absent or written after `SubagentStart`. The recorder writes an invalid attestation and the next mutation is denied with `MODEL_ROUTING_ATTESTATION_BLOCKED: agent 'task-researcher-c3' has model, reasoning, or profile drift from its persisted deployment receipt`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `MODEL_ROUTING_ATTESTATION_BLOCKED: actual model/profile does not match the persisted routing receipt.`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The recorder correctly reads only already-persisted checkpoint receipts and cannot repair an ordering error. Normal nested routing lacks the explicit pre-spawn launch-binding transaction used by the stricter epic-child path. Existing profile, authority-store, mutation, and stop gates must remain fail-closed.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: deterministic `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` coverage for a nested C3 child with a preexisting exact receipt, and absent, late, generic-alias, model, reasoning, profile-path, and profile-SHA mismatch cases.
- [ ] Integration scenario to retest: persist the nested receipt before `spawn_agent`, verify `SubagentStart` records `routing_valid: true`, and admit the first mutation only for the exact generated profile.
- [ ] Manual verification notes: run the full formatting, linting, type-checking, and test loop; record fail-before, pass-after, baseline/comparison, and QA results under this feature's canonical `evidence/` subdirectories.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
