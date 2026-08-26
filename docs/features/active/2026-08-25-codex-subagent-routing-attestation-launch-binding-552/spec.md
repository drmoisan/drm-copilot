# 2026-08-25-codex-subagent-routing-attestation-launch-binding (Spec)

- **Issue:** #552
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-25T14-58
- **Status:** Draft
- **Version:** 0.1

## Context
Issue #552 fixes normal nested routed-delegation launch ordering. A coordinator can start a generated child before its matching deployment receipt is durable in a checkpoint; the `SubagentStart` recorder then writes an invalid authority-store attestation and the mutation gate blocks the child.

The provided research is sufficient to define required behavior, preserved controls, and validation targets. It does not authorize relaxing the profile, authority-store, mutation, or stop-time enforcement gates.

Environment:
- OS/version: Windows/PowerShell repository runtime.
- Python version: Repository Python runtime used by `scripts/dev_tools/resolve_codex_deployment.py` and pytest.
- Command/flags used: Nested C3 routed `spawn_agent` delegation.
- Data source or fixture: Selected orchestration checkpoint, `codex_model_routing_receipts`, generated TOML profiles, and authority-store attestation records.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Resolve a logical nested `task-researcher` at C3 but do not persist its returned `task-researcher-c3` receipt to the selected checkpoint before `spawn_agent`.
2. Start the generated profile and allow `record-subagent-routing-attestation.ps1` to read checkpoint inputs at `SubagentStart`.
3. Invoke the first child mutation; the invalid attestation causes the mutation hook to block it.

Expected:
Before `SubagentStart`, the selected checkpoint contains a complete exact child receipt: `logical_agent`, `deployment_agent`, `model`, `model_reasoning_effort`, a non-empty `phase`, and a delegation identifier. The child is that generated `deployment_agent`; its model, reasoning effort, path, and SHA-256 match; and its authority-store attestation is `routing_valid: true`.

Actual:
The top-level receipt is absent or late. `SubagentStart` writes an invalid authority-store attestation, and the first mutation fails with `MODEL_ROUTING_ATTESTATION_BLOCKED: actual model/profile does not match the persisted routing receipt.`

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `MODEL_ROUTING_ATTESTATION_BLOCKED: agent 'task-researcher-c3' has model, reasoning, or profile drift from its persisted deployment receipt`.


## Scope & Non-Goals
- In scope: durable pre-spawn receipts for normal routed delegations; independent nested-child selection; exact generated-profile binding; start-only authority-store failure coverage; and root/bundle/profile parity.
- Out of scope / non-goals: model-policy changes, logical-alias fallback, relaxing `PreToolUse` or `SubagentStop`, replacing normal routing with the full epic-child authority protocol, or unrelated workflow changes.
- Explicitly excluded systems, integrations, or datasets: external services and public model documentation are not implementation authorities; checked-in resolver, hooks, generated profiles, and tests are authoritative.

## Root Cause Analysis
`.codex/hooks/record-subagent-routing-attestation.ps1` calls `Find-CodexModelRoutingReceipt` only against checkpoint files present at `SubagentStart`. It correctly marks routing invalid when no receipt exactly names the started `deployment_agent`; it cannot correct a record written after startup. Normal nested routing lacks a durable pre-spawn transaction, so downstream profile and mutation enforcement correctly blocks that child.


## Proposed Fix

### Design summary (what changes where):
The normal routed-delegation coordinator/launcher resolves every child through `scripts/dev_tools/resolve_codex_deployment.py`, validates the returned generated profile, appends the exact receipt to the selected checkpoint, flushes it, and only then calls `spawn_agent` with the returned `deployment_agent`. The recorder, profile-attestation helper, authority store, mutation gate, and stop validator remain fail-closed consumers.

### Boundaries and invariants to preserve:
- A receipt is durable before `SubagentStart`; a late receipt does not authorize an already-started child.
- `deployment_agent` is the exact generated profile, never a logical family alias such as `task-researcher`.
- A nested child resolves independently from its logical family, complexity band, execution context, and monotonic ceiling; a parent's C3 profile cannot authorize it.
- Receipt model/reasoning exactly match the launched profile; profile path and SHA-256 remain binding.
- A false `routing_valid` authority-store attestation is a launch failure. The coordinator cannot accept output or mutations from that route.
- Root `.codex` content, bundled customization content, generated profiles, and pack manifests remain synchronized.

### Dependencies or blocked work:
The coordinator must determine the same checkpoint `SubagentStart` inspects and atomically/durably write it before launch. Implementation must stop if that selected-checkpoint handoff is ambiguous.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- The existing normal routed-delegation coordinator/launcher that writes `codex_model_routing_receipts` to the selected orchestration checkpoint.
- `scripts/dev_tools/resolve_codex_deployment.py` only if needed to expose or verify a required resolver output.
- `.codex/hooks/record-subagent-routing-attestation.ps1` and its bundled copy only if a narrow selected-checkpoint consumer handoff is necessary; retain `Get-CodexSubagentAttestation` and `Find-CodexModelRoutingReceipt` fail-closed semantics.
- `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`, `tests/scripts/dev_tools/test_resolve_codex_deployment.py`, `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, and applicable source/bundle push-down contract tests.

#### Functions/classes/CLI commands impacted:
- Resolver output (`deployment_agent`, `model`, `model_reasoning_effort`) remains the single profile-selection authority.
- `Find-CodexModelRoutingReceipt` and `Get-CodexSubagentAttestation` continue exact agent matching and calculate `routing_valid` from persisted receipt and profile binding.
- `Get-CodexAgentProfileAttestation` and `Test-CodexAgentProfileBinding` continue to validate profile name, model, reasoning effort, path, and SHA-256.
- The normal coordinator's `spawn_agent` call accepts only the resolver-returned `deployment_agent` after receipt flushing completes.

#### Data flow and validation changes:
- Input: logical child family, complexity band, execution context, and current monotonic ceiling.
- Transform: resolve the generated profile, validate it, and construct an exact receipt with non-empty phase and delegation identifier.
- Persistence: append to the selected checkpoint, complete the durable write, then invoke `spawn_agent`.
- Consumption: `SubagentStart` writes the authority-store attestation; downstream mutation/stop hooks revalidate the actual profile.
- Rejection: missing, late, generic-alias, model, reasoning, profile-path, and profile-SHA mismatches must not authorize a route.

#### Error handling and logging updates:
- Preserve `MODEL_ROUTING_ATTESTATION_BLOCKED` for invalid start-time routing and the authority-store path in hook context.
- The coordinator emits an explicit launch failure if persistence or profile validation fails; it does not start the child or treat a blocked child as successful delegated work.
- Preserve non-blocking `SubagentStart` transport and fail-closed mutation/stop enforcement.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Revert only a verified incompatible coordinator producer change; do not weaken attestation enforcement as rollback.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input receipt fields: `logical_agent`, `deployment_agent`, `model`, `model_reasoning_effort`, complexity context, non-empty `phase`, and a delegation identifier.
- Persisted output: a `codex_model_routing_receipts` entry in the selected checkpoint before process start.
- Startup output: authority-store JSON with actual/expected model and reasoning, profile name/path/SHA-256, `routing_valid`, and timestamp.

#### Required configuration keys and defaults:
- Continue generated-profile `name`, `model`, and `model_reasoning_effort`. No default can substitute a base alias, alternate model, or legacy receipt for the exact `deployment_agent`.

#### Backward-compatibility expectations:
- Valid exact existing receipts remain valid. Missing, late, and generic-alias routes fail before launch instead of starting children that fail later.

#### Performance constraints (latency/throughput/memory):
- Bounded resolver/profile validation plus one durable checkpoint write per child; it does not broaden concurrency or weaken the monotonic ceiling.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): The selected checkpoint is writable before launch and the generated profile exists under `.codex/agents/`.
- Constraints (budget, performance, compatibility): Preserve generated-profile routing, hook ordering, fail-closed mutation/stop behavior, and root/bundle parity.
- External dependencies (services, libraries, releases): No new third-party dependency.

## Data / API / Config Impact
- User-facing or API changes: No public CLI or API change.
- Data or migration considerations: Corrected receipt entries use the existing checkpoint schema; valid entries need no migration.
- Logging/telemetry updates (if any): Retain the authority-store attestation and add only specific launch-failure context.
- Compatibility notes (CLI flags, config schemas, versioning): Resolver and generated-profile contracts remain authoritative; no alias fallback is introduced.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` must cover exact nested C3 admission and every rejected receipt shape.
- [ ] Integration scenario to retest: a normal nested C3 child receives a receipt before `SubagentStart`, records `routing_valid: true`, and reaches its first permitted mutation.
- [ ] Manual verification notes: inspect the selected checkpoint before launch and the authority-store attestation after `SubagentStart`; verify root/bundle/profile parity.

- Regression tests to add or update: In `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`, add Pester cases named `records a valid authority-store attestation for a nested C3 child with a durable exact receipt`, `records a routing-invalid attestation before mutation when a nested receipt is absent or late`, and `rejects a generic nested-agent alias despite a matching logical family receipt`.
- Unit tests (pytest) for the fixed behavior and boundaries: In `tests/scripts/dev_tools/test_resolve_codex_deployment.py`, add `test_standalone_c3_task_researcher_receipt_uses_generated_profile` and `test_nested_c3_elevated_task_researcher_receipt_uses_elevated_profile`; in `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, add `test_generated_profiles_and_bundle_copies_remain_in_sync` when equivalent coverage is not already present.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): generic alias, alternate model, reasoning mismatch, profile-path mismatch, profile-SHA mismatch, missing phase/delegation identifier, absent/late receipt, and independently elevated nested context.
- Error handling and logging verification: Assert the exact `MODEL_ROUTING_ATTESTATION_BLOCKED` path remains fail-closed and that a start-only invalid route is in the authority store before mutation.
- Coverage impact and targets for changed lines/modules: Cover every introduced receipt-persistence branch. Store baseline, post-change, and comparison evidence under `evidence/baseline/`, `evidence/regression-testing/`, and `evidence/qa-gates/`.
- Toolchain commands to run (format → lint → type-check → test): Run the applicable formatter, linter, type checker, and deterministic Pester/pytest suites in that order; restart from formatting if any step changes files or fails.
- Manual validation steps (if required): Capture fail-before or a canonical exception dossier, then pass-after and QA evidence with ISO-8601 filenames in this feature's canonical evidence directories.


## Acceptance Criteria
- [x] Before every normal routed `spawn_agent` call, the selected checkpoint durably contains a non-empty-phase, delegation-identified receipt whose `deployment_agent`, model, and reasoning effort exactly match the child being started.
- [x] The launched child is exactly the resolver-returned generated profile, and `Get-CodexAgentProfileAttestation`/`Test-CodexAgentProfileBinding` confirm matching profile name, model, reasoning effort, path, and SHA-256.
- [x] A generic logical alias, absent receipt, late receipt, model mismatch, reasoning mismatch, profile-path mismatch, or profile-SHA mismatch is rejected and cannot authorize a routed child.
- [x] A nested child is independently resolved from logical family, complexity band, execution context, and monotonic ceiling; a parent C3 profile cannot authorize it, and C3-elevated selection remains correct when context requires it.
- [x] `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` proves start-only authority-store behavior: an exact pre-spawn nested receipt records `routing_valid: true`, while absent or late receipt records `routing_valid: false` before the child attempts a mutation.
- [x] Root and bundled hook/configuration copies, generated profiles, and pack manifests remain compliant with existing source/bundle parity checks.
- [x] Updated Pester and pytest regression tests pass, including resolver selection and generated-profile parity coverage, and changed branches meet repository coverage policy.
- [x] The applicable formatting, linting, type-checking, and test loop passes in one final run; fail-before, pass-after, baseline/comparison, and QA evidence is under the feature's canonical `evidence/` directories.

## Risks & Mitigations
- Technical or operational risks: Persisting to a checkpoint other than the one `SubagentStart` reads recreates the failure; accepting an alias hides a wrong selection; a source-only update can create bundle drift.
- Mitigations and rollbacks: Select and validate the same checkpoint before persistence, reject aliases before launch, run source/bundle/profile parity tests, retain fail-closed hooks, and revert only a verified incompatible producer change.

## Rollout & Follow-up
- Release/rollout steps: Apply through the standard routed-delegation workflow after canonical evidence is present; no separate deployment flag is expected.
- Post-fix monitoring or clean-up tasks: Review the next nested delegation's checkpoint receipt and authority-store attestation for exact binding; do not treat an alias or late record as successful.
- Links: Issue #552; `research/2026-08-25T15-05-codex-routed-subagent-attestation-research.md`; `plan.2026-08-25T14-58.md`.
