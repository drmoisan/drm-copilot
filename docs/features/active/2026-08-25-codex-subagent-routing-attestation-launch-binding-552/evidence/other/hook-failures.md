# Hook Failures

## Historical nested preflight launch failure

- Attempted action/path: Atomic-planner nested preflight launch for Issue #552; expected `.codex/agents/atomic-executor-c3.toml`, observed logical alias `atomic-executor`.
- Hook: Codex model-routing attestation gate (`SubagentStart` / mutation gate).
- Exact output/reason: `MODEL_ROUTING_ATTESTATION_BLOCKED`; persisted baseline fields record `source: atomic-planner-c3 nested preflight attempt`, `observed_agent_type: atomic-executor`, and `expected_deployment_agent: atomic-executor-c3`.
- Impact: The attempt was classified as expected baseline evidence and was not accepted as preflight.
- Corrective action: Persist and use the exact generated `atomic-executor-c3` deployment receipt before retrying.

## Corrected routed retry

- Attempted action/path: Issue #552 S9 commit-steward routing preflight and execution through `.codex/agents/atomic-executor-c3.toml`.
- Hook: Codex model-routing attestation gate.
- Exact output/reason: `PLAN_READY; PREFLIGHT: ALL CLEAR`; the persisted execution receipt uses delegation ID `issue-552-s9-commit-steward-routing-execution`, deployment agent `atomic-executor-c3`, model `gpt-5.6-terra`, reasoning `high`, and C3 overlay disabled.
- Impact: The validated remediation plan was authorized for execution.
- Corrective action: Applied. The current P4 resolver regression also confirms standalone `commit-steward` C3 resolves exactly to `commit-steward-c3` with `gpt-5.6-terra` and `high`.
