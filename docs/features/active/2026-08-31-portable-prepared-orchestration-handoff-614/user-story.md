# `2026-08-31-portable-prepared-orchestration-handoff` — User Story

- Issue: #614
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-31T07-58

## Story Statement

- As a repository operator, I want to transfer prepared orchestration work between Claude and Codex
  without replaying completed phases, so that I can continue the same verified plan when the current
  provider is unavailable or no longer suitable.
- As an orchestration maintainer, I want one provider-neutral lifecycle and provenance contract with
  provider-native adapters, so that Claude and Codex can provide equivalent continuation behavior
  without sharing model names, agent profiles, or launch implementations.

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

## Personas & Scenarios

- Persona: Repository operator completing prepared work
  - The operator owns a tracked issue and an already prepared atomic plan, and needs execution to
    continue in another provider because of availability, quota, or runtime constraints.
  - They care about retaining the exact plan, completed lifecycle evidence, repository state, and
    audit history rather than reconstructing or repeating preparation.
  - Their constraints include consumer repositories that do not contain drm-copilot developer
    modules, provider-specific model and launch policies, and unrelated worktree mutations that must
    not be staged, reset, or mixed into the feature.
  - Their goal is a single deterministic readiness or blocked result with no hidden state changes.
- Persona: Orchestration runtime maintainer
  - The maintainer evolves Claude and Codex orchestration independently while preserving common
    lifecycle, validation, ownership, recovery, and provenance semantics.
  - They care about versioned contracts, deterministic failure precedence, published consumer
    authority, provider-native routing, and source/bundle/pack parity.
  - Their constraint is functional parity rather than a direct code port: Claude and Codex retain
    different agent, model, worktree, and launch mechanisms.
  - Their goal is to add or change a provider adapter without rewriting historical evidence or
    weakening preparation, routing, review, or scheduler gates.
- Scenario: Resume TaskMaster issue #469 from Claude preparation in Codex
  1. Claude parallel preparation completes the child plan and records execution as the next phase.
  2. The operator selects the exact checkpoint, plan path and hashes, workspace, destination, and
     hash-bound parent scheduler context.
  3. The portable validator verifies provenance, identity, lifecycle, scheduler ownership, provider
     capabilities, and semantic tool authorization without modifying the checkout.
  4. If the worktree is clean, the transition service archives the source checkpoint, materializes
     a validated Codex projection atomically, and preserves every completed phase as non-replayable.
  5. Codex resolves its own topology and model for the first new delegation, resumes atomic
     execution, and returns the bounded child result to the parallel scheduler.
  6. If the unrelated `.csproj` mutations are present, the operator receives
     `HANDOFF_DIRTY_WORKTREE` with the paths, while the source checkpoint and files remain unchanged.
- Scenario: Resume Codex-prepared work in Claude
  1. The operator supplies a Codex source checkpoint and exact prepared plan through the same
     provider-neutral envelope.
  2. The Claude adapter validates the portable lifecycle and retains Codex model, profile, topology,
     and launch receipts as opaque historical evidence.
  3. Claude materializes its native destination checkpoint and records Claude-specific routing only
     for new work.
  4. Execution begins at the recorded next transition, and the same scheduler ownership and return
     boundaries apply when the work was prepared by a parallel or epic parent.

## Acceptance Criteria

- [ ] A versioned provider-neutral handoff validates objective, repository, workspace, branch
  lineage, issue, feature, work mode, completed phases, exact next transition, logical complexity,
  capability requirements, and exact plan path/hash before a destination may continue.
- [ ] A valid handoff archives the original source checkpoint bytes by raw SHA-256, preserves source
  receipts as immutable or opaque evidence, appends digest-linked history, and never synthesizes
  destination receipts for completed source-runtime work.
- [ ] Claude-to-Codex and Codex-to-Claude adapters preserve logical complexity, route, lifecycle,
  plan, and ownership semantics while each destination independently resolves model, reasoning,
  profile, topology, and launch evidence for new work only.
- [ ] A completed preparation state advances to its recorded execution transition without replaying
  promotion, research, feature-document authoring, atomic planning, or preflight, and any attempted
  replay is rejected before mutation.
- [ ] A parallel or epic child can be completed piecemeal by an ordinary destination orchestrator,
  but the parent scheduler retains cohort/wave ordering, barriers, fan-in, integration, cleanup, and
  overall completion authority.
- [ ] Hook and validator allowlists resolve both supported `drm-copilot` MCP transport spellings to
  the same registered semantic operation and reject malformed identifiers, unrelated tools, and
  unregistered operations.
- [ ] A consumer repository can perform workspace-explicit validation, topology resolution, and
  destination routing through published runtime authority without importing unshipped drm-copilot
  source modules; missing authority produces one deterministic blocked result before delegation.
- [ ] Dry-run transition changes no canonical checkpoint or user file. Materialization validates a
  same-directory destination candidate and atomically replaces the canonical checkpoint only after
  every contract, binding, capability, and clean-worktree check passes.
- [ ] An unrelated dirty worktree is reported separately as `HANDOFF_DIRTY_WORKTREE` after earlier
  validation succeeds; the result lists affected paths and does not stage, stash, reset, delete, or
  modify them.
- [ ] Unsupported schema versions, tampered source or history, wrong repository/workspace/branch/
  issue/feature, invalid or stale plan identity, scheduler mismatch, invalid transition, and missing
  capabilities or authorities each fail closed with the contract's deterministic primary code.
- [ ] TaskMaster issue #469 fixtures prove the original Claude-prepared checkpoint reaches Codex
  execution readiness with its pinned source and plan hashes, no completed-phase replay, and no
  historical-receipt fabrication; symmetric fixtures prove Codex-to-Claude continuation.
- [ ] Root, bundled, packed, and installed-consumer tests demonstrate that the schema, registry,
  adapters, hooks, skills, validators, and transition authority remain synchronized and usable from
  a consumer checkout.
- [ ] Regression coverage confirms issue #467 remains the owner of full Codex-native parallel
  scheduling and issue #543 remains the owner of the provider-specific epic-planner ready-gate
  defect; this feature changes neither behavior.

## Non-Goals

- Implementing the full Codex-native parallel planner, orchestrator, run, mutation, launcher, or
  scheduler surface tracked by issue #467.
- Correcting the provider-specific epic-planner ready-gate defect tracked by issue #543.
- Porting Claude implementation files directly to Codex or requiring both providers to use the same
  agents, models, reasoning settings, launch mechanisms, or worktree controls.
- Translating historical model names or fabricating destination topology, routing, launch,
  delegation, validation, or preflight receipts for work performed by the source provider.
- Allowing shell commands, direct checkpoint edits, or ordinary patches to remove
  `route_id: preparation` or bypass the explicit transition service.
- Rediscovering, rewriting, or converting an already selected atomic plan instead of validating its
  exact repository-relative path and raw-byte hash.
- Repairing, staging, stashing, resetting, deleting, or otherwise altering unrelated dirty-worktree
  content as part of a handoff.
- Giving an ordinary resumed child authority to advance a parallel cohort or epic wave, fan in or
  merge branches, remove worktrees, or declare the parent scheduler run complete.
- Inferring absent plan, lifecycle, receipt, or scheduler facts from an insufficient legacy
  checkpoint. Ambiguous migrations remain blocked until independently hash-bound evidence is
  supplied.
