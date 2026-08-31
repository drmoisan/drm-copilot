# portable-prepared-orchestration-handoff (Issue #614)

- Date captured: 2026-08-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/portable-prepared-orchestration-handoff/ (Issue #614)

- Issue: #614
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/614
- Last Updated: 2026-08-31
- Work Mode: full-feature

## Problem / Why

A completed orchestration preparation checkpoint cannot be handed from Claude to Codex, or from
Codex to Claude, as a deterministic continuation. The failure was reproduced while attempting to
continue TaskMaster issue #469 after Claude parallel preparation had completed and execution was the
next phase.

The first blocking condition was the combination of a Claude-produced ordinary checkpoint with
`route_id: preparation` and `.codex/hooks/enforce-epic-planning-only.ps1`. The Codex runtime treated
the preparation route as immutable, blocked even the initial read/topology-resolution command, and
rejected the active normalized MCP validator identifier
`mcp__drm_copilot__validate_orchestration_artifacts` because the hook allowlist used the
hyphenated server spelling `mcp__drm-copilot__validate_orchestration_artifacts`. The existing
artifact had no provider-neutral transition that could preserve completed preparation provenance
while authorizing the destination ecosystem to begin execution.

Two later conditions also prevented recovery: the TaskMaster consumer checkout did not contain the
canonical Codex topology resolver, and 16 unrelated modified `.csproj` files made the mandatory
clean execution and pre-review staging workflow unsafe. Those are secondary blockers. They did not
cause the initial denial, but the durable handoff contract must detect and report both conditions
before execution starts.

Open issue #467 covers the broader Codex-native parallel orchestration surface. Open issue #543
covers a provider-specific epic-planner ready-gate defect. This issue does not merge either scope;
it defines the portable transition needed when preparation is already complete and a different
ecosystem must continue the same work.

## Proposed Behavior

Provide a deterministic, provider-neutral, provenance-preserving handoff for prepared ordinary
orchestration work, including work prepared through parallel or epic scheduling:

- Define a versioned general checkpoint/handoff schema for objective identity, lifecycle identity,
  work mode, completed phases, exact next transition, repository/workspace binding, plan identity
  and content hash, source and destination ecosystems, and append-only handoff history.
- Define canonical Claude and Codex expressions/adapters for the general schema. Provider-specific
  model and agent evidence remains provider-specific, but logical complexity, route intent, phase
  state, plan identity, and transition semantics remain portable.
- Preserve the source checkpoint and its historical receipts without alteration. The destination
  runtime records new provider-specific receipts only for work it performs after the handoff; it
  must not replay completed lifecycle or preparation phases or fabricate destination receipts for
  historical source-runtime actions.
- Normalize MCP tool identity before allowlist comparison so transport spellings such as
  `drm-copilot` and `drm_copilot` resolve to one semantic tool identity.
- Publish portable topology/model-resolution and checkpoint-validation authority to consumer
  repositories, or expose an equivalent workspace-explicit MCP authority, so a consumer checkout
  can validate and route a resumed delegation without requiring drm-copilot source modules.
- Run a clean-worktree preflight before execution transition and report unrelated mutations as a
  distinct blocker without altering, staging, or mixing them into the resumed feature.
- Use TaskMaster issue #469 as an end-to-end fixture: accept its completed Claude preparation state,
  retain the exact plan path and hash, transition to Codex execution readiness, and also prove the
  inverse Codex-to-Claude path with equivalent fixture data.

## Acceptance Criteria (early draft)

- [ ] A versioned provider-neutral handoff validates objective, repository, workspace, feature,
      issue, work mode, completed-phase, next-transition, and exact plan path/hash identity before a
      destination runtime may continue.
- [ ] A valid handoff preserves the source checkpoint and historical receipts byte-for-byte or by
      recorded content hash, appends a transition record, and never synthesizes destination-runtime
      receipts for completed source-runtime actions.
- [ ] Claude-to-Codex and Codex-to-Claude adapters map logical complexity and route/phase semantics
      while keeping model, reasoning-effort, agent-profile, and launch-attestation evidence in the
      ecosystem-specific expression that produced it.
- [ ] A completed preparation state advances to its recorded execution transition without replaying
      promotion, research, feature-document authoring, planning, or preflight.
- [ ] Hook and validator allowlists compare normalized semantic MCP identities and accept both
      supported transport spellings for the same `drm-copilot` operation while rejecting unrelated
      tools.
- [ ] Consumer repositories receive or can call a workspace-explicit portable topology resolver and
      validator; missing authority produces one deterministic blocked status before delegation.
- [ ] Execution transition performs a non-mutating clean-worktree preflight and reports unrelated
      dirty files separately from schema, routing, or hook failures.
- [ ] TaskMaster issue #469 fixtures prove the original Claude-prepared checkpoint can transition to
      Codex execution readiness with the exact existing plan identity and no historical-receipt
      fabrication; symmetric fixtures prove Codex-to-Claude continuation.
- [ ] Regression coverage confirms issue #467 remains the owner of Codex-native parallel scheduling
      functionality and issue #543 remains the owner of the epic-planner ready-gate defect.

## Constraints & Risks

- Functional parity is required; a direct port of Claude implementation details is not.
- Historical checkpoints must remain auditable. In-place destructive conversion and lossy receipt
  normalization are prohibited.
- An ecosystem-specific model selection is not portable state. Only the logical complexity and the
  fact that a provider resolution is required are shared; each destination resolves its own future
  delegation evidence under its current policy.
- Plan discovery by directory is insufficient. Handoff requires an exact repository-relative plan
  path plus a verified content hash.
- Workspace binding must reject a different repository, branch lineage, issue, feature folder, or
  stale plan unless an explicit versioned migration rule authorizes the transition.
- This issue does not implement the complete Codex parallel scheduler from #467 or change the
  provider-specific epic ready-gate behavior tracked by #543.

## Test Conditions to Consider

- [ ] Schema and adapter fixtures cover both directions, legacy checkpoint migration, future schema
      versions, tampered source hashes, stale plan hashes, wrong workspace/repository bindings,
      unknown transitions, and preservation of opaque historical receipts.
- [ ] Hook process tests cover hyphenated and underscore-normalized MCP identifiers, malformed
      identifiers, unrelated tools, and exact allow/deny output and exit behavior.
- [ ] Published consumer-repository tests run topology resolution and validation without importing
      unshipped drm-copilot source modules.
- [ ] End-to-end TaskMaster #469 fixtures verify preparation-to-execution continuation without phase
      replay and verify clean-worktree blocking independently of handoff-schema acceptance.
- [ ] Parallel and epic regression fixtures prove scheduled child preparation can be completed
      piecemeal by an ordinary destination orchestrator without changing scheduler ownership.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/portable-prepared-orchestration-handoff/` folder from the template
