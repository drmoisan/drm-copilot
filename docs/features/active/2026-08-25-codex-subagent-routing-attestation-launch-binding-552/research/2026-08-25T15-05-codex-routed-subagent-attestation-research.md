<!-- markdownlint-disable-file -->

# Task Research Notes: Codex routed-subagent attestation launch binding (Issue #552)

## Research Executed

### File Analysis

- `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/issue.md`, `spec.md`, and `plan.2026-08-25T14-58.md`
  - All three are initial scaffolds. The plan requires fail-before/pass-after regression evidence, a full toolchain loop, and recorded evidence locations; it does not yet identify the runtime failure.
- `.codex/config.toml:109-117` and `.codex/hooks/record-subagent-routing-attestation.ps1:363-410`
  - Every routed family matched by `SubagentStart` invokes the recorder. The recorder loads only the three on-disk checkpoint files, constructs an attestation, writes it to the non-workspace authority store, and returns a non-blocking context message when routing is invalid.
- `.codex/hooks/codex-agent-profile-attestation.ps1:88-195` and `.codex/hooks/enforce-codex-model-routing.ps1:36-198`
  - A receipt must name the exact `deployment_agent`; the subsequent mutation hook re-reads the profile, model, reasoning effort, path, and SHA-256 before allowing a mutation. It denies a routed agent with no matching start attestation or any model/profile drift.
- `scripts/dev_tools/resolve_codex_deployment.py` and `scripts/dev_tools/generate_codex_agent_variants.py`
  - The resolver maps a logical agent plus band/context/ceiling to an exact generated profile. The generator renders C1, C2, C3, C3-elevated, and C4 files from canonical base profiles, maintains bundle copies, and exposes a check-only drift mode.
- `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`, `tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1`, `tests/scripts/dev_tools/test_resolve_codex_deployment.py`, and `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`
  - Existing coverage verifies exact profile matching, reasoning mismatch rejection, path/SHA drift rejection, no model fallback, C3 elevation rules, and generated-profile/bundle parity. It does not test a nested normal routed delegation whose receipt is absent or persisted after `SubagentStart`.

### Code Search Results

- `SubagentStart`, `MODEL_ROUTING_ATTESTATION_BLOCKED`, `deployment_agent`, and `Find-CodexModelRoutingReceipt`
  - The startup recorder searches `codex_model_routing_receipts` and legacy `model_routing_receipts` across checkpoints, then returns the last exact-agent match. The mutation gate uses the attestation keyed by transcript path and falls back to an authority-store lookup by agent ID.
- Source/bundle parity check
  - SHA-256 comparisons showed identical root and bundle copies for the recorder, model gate, profile-attestation helper, stop validator, configuration, and `task-researcher-c3` profile.
- Authority-store and rollout evidence
  - The current repository session contains valid `orchestrator-c3` and `task-researcher-c3` attestations: actual and expected model are `gpt-5.6-terra`; actual and expected reasoning effort are `high`; the profile paths are the corresponding generated C3 TOML files; and `routing_valid` is `true`.
  - The 2026-08-25 12:14 session is accessible but belongs to `TaskMaster-wt`, not this repository. It records a depth-three `atomic-executor` start and an immediate intentional interruption; it is not failure evidence for Issue #552.
  - A 2026-08-25 rollout record captures the recurring failure before the research worker's first read: `MODEL_ROUTING_ATTESTATION_BLOCKED: agent 'task-researcher-c3' has model, reasoning, or profile drift from its persisted deployment receipt`. Its recorded corrective action states that the top-level S2 task-researcher deployment receipt was missing and must be corrected before relaunch.

### External Research

- #githubRepo:"openai/codex routed subagent profile and launch attestation"
  - No public repository result was used as an authority for the local hook contract. The checked-in runtime, generator, tests, and authority-store records are the authoritative implementation sources for this repository.
- #fetch:https://developers.openai.com/api/docs/guides/latest-model
  - Official OpenAI model guidance identifies `gpt-5.6-terra` as the balanced model and requires intentional reasoning-effort selection. It also states that workflow-specific routing instructions and required evidence should be explicit rather than inferred from tool availability.

### Project Conventions

- Standards referenced: `.github/agents/task-researcher.agent.md`, `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, and `.agents/skills/codex-model-routing/SKILL.md`.
- Instructions followed: research-only scope, feature-associated research root, ISO-8601 timestamp filename, no source/configuration/test edits, and only verified findings.

## Key Discoveries

### Project Structure

The runtime has three ordered controls:

1. `resolve_codex_deployment.py` selects the exact profile.
2. The coordinator persists a matching deployment receipt before spawning that profile.
3. `SubagentStart` records the actual profile binding; `PreToolUse` and `SubagentStop` consume it.

The current recorder cannot repair an ordering error. At startup it can only inspect checkpoint files that already exist. A missing or late exact receipt produces an invalid attestation, which the mutation hook correctly rejects.

### Implementation Patterns

- `task-researcher`, `atomic-planner`, `atomic-executor`, and other routed families require the exact generated name, not the logical family alias.
- Standalone C3 under a C3 ceiling resolves to `<family>-c3`, `gpt-5.6-terra`, and `high`; C3 in an epic-child context or under a C4 ceiling resolves to `<family>-c3-elevated`, `gpt-5.6-sol`, and `high`.
- The existing epic-child mechanism is stricter: it validates a session-bound launch receipt and inherited execution-context, profile, model, reasoning, worktree, and delegation fields. Normal nested routed delegation has no equivalent explicit pre-start launch binding.

### Complete Examples

```json
{
  "logical_agent": "task-researcher",
  "deployment_agent": "task-researcher-c3",
  "complexity_band": "C3",
  "execution_context": "standalone",
  "orchestration_complexity_ceiling": "C3",
  "model": "gpt-5.6-terra",
  "model_reasoning_effort": "high"
}
```

The resolver returns this shape for a standalone C3 task-researcher. Before its `spawn_agent` call, this result must be present in the selected checkpoint's `codex_model_routing_receipts` with the delegation phase and flushed to disk.

### API and Schema Documentation

The launch-critical receipt fields verified by the hook are `deployment_agent`, `model`, and `model_reasoning_effort`; the persisted attestation additionally records the profile name, profile path, profile SHA-256, actual model, actual reasoning effort, and `routing_valid`. The mutation hook revalidates those values against the current profile file.

### Configuration Examples

```toml
[[hooks.SubagentStart]]
matcher = "epic-planner|epic-orchestrator|orchestrator|atomic-planner|atomic-executor|feature-review|feature-reviewer|task-researcher|prd-feature|pr-author|typed-engineer|-c"
```

This is configured once in the root `.codex/config.toml` and has an identical bundled copy. Any remediation must retain the event and fail-closed downstream checks.

### Technical Requirements

- Receipt persistence must finish before `spawn_agent`, not during or after the child starts.
- The spawned agent must equal the resolver's `deployment_agent`; model and reasoning effort must equal the resolver receipt and generated TOML fields exactly.
- Nested delegates must be resolved independently from their parent. A parent's C3 profile does not authorize a child logical alias; the child's context and monotonic ceiling determine its profile.
- No fallback to a base alias, an alternate model, or a legacy receipt may satisfy the launch contract.
- Root and bundled customization copies, generated profiles, and pack manifests must remain synchronized.

## Recommended Approach

Require an explicit pre-spawn launch-binding transaction in every routed delegation path, while keeping the existing `SubagentStart` recorder and mutation/stop gates unchanged.

1. Resolve the child through `resolve_codex_deployment.py` using its own logical agent, complexity band, execution context, and current monotonic ceiling.
2. Confirm the returned generated TOML profile exists and matches the returned model and reasoning effort.
3. Append the exact receipt to the checkpoint that the startup hook will inspect, including a non-empty phase and delegation identifier; complete the durable write before the `spawn_agent` call.
4. Spawn only the returned `deployment_agent`.
5. Treat a `SubagentStart` attestation with `routing_valid: false` as a launch failure, not as a child result; do not allow the coordinator to accept output or mutations from it.

This is the smallest remediation because it corrects the evidenced missing/late receipt without weakening existing attestation, profile-hash, authority-store, or downstream fail-closed behavior. It also preserves the generator as the single source for deployment profiles.

Rejected alternatives:

- Relax `PreToolUse` when an attestation is missing or invalid. Rejected because it would permit mutations from an unverified profile and directly defeats the existing enforcement boundary.
- Add the full epic-child external launch-authority protocol to every normal delegate immediately. It would provide stronger lineage isolation, but it is a larger contract change and is not necessary to fix the evidenced receipt-order failure. Reconsider only if a correctly persisted pre-spawn receipt still fails in nested routes.

## Implementation Guidance

- **Objectives**: Make the generated deployment receipt durable before `SubagentStart`; keep exact profile enforcement and source/bundle parity.
- **Key Tasks**: Update the routed-delegation coordinator/launcher to perform the five-step transaction above; add a narrow test seam that simulates a nested C3 `task-researcher` launch; retain all current gates.
- **Dependencies**: `scripts/dev_tools/resolve_codex_deployment.py`, generated `.codex/agents/*-c*.toml`, the selected orchestration checkpoint, and the root/bundle push-down contract.
- **Success Criteria**: A nested child with an exact preexisting receipt reaches `routing_valid: true`; no mutation is allowed for a missing, late, logical-alias, model-mismatched, reasoning-mismatched, profile-path-mismatched, or profile-SHA-mismatched receipt; generator and push-down parity checks pass.
- **Likely implementation files**: the routed delegation launcher/orchestrator surface that writes `codex_model_routing_receipts`, `.codex/hooks/record-subagent-routing-attestation.ps1` only if a deterministic selected-checkpoint handoff is needed, its bundle copy, and any generated/customization carriage contract that changes.
- **Test targets**: `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` (nested pre-spawn receipt, absent/late receipt, exact-agent rejection); `tests/scripts/dev_tools/test_resolve_codex_deployment.py` (C3/C3-elevated selection); `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` (profile and bundle parity); and the existing push-down contract tests for source/bundle carriage.
