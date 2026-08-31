# 2026-08-31-portable-prepared-orchestration-handoff — Spec

- **Issue:** #614
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-31T07-58
- **Status:** Draft
- **Version:** 0.1

## Overview

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

The target users are repository operators who need to change orchestration providers without
restarting completed work and maintainers who must evolve Claude and Codex integrations without
coupling their native launch and model-selection mechanisms. Success is a bidirectional,
provenance-preserving transition that resumes the exact prepared plan at the exact next lifecycle
phase, fails deterministically before mutation when its bindings are invalid, and works in a
consumer repository without importing unshipped drm-copilot source modules.

The completed research artifact
`research/20260831-portable-prepared-orchestration-handoff-implementation-research.md` is sufficient
to define the contract, interfaces, transition behavior, implementation boundaries, and test matrix
for this specification.

## Behavior

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

The end-to-end main flow is:

1. The operator selects the exact source checkpoint, its expected raw-byte SHA-256, the prepared
   plan path and hash, the destination provider, and an explicit workspace root.
2. A read-only validation pass selects the schema version and provider adapter, validates the raw
   source hash and append-only history, and checks objective, repository, workspace, issue, feature,
   work mode, branch lineage, plan, scheduler, transition, and capability bindings in the defined
   precedence order.
3. The destination resolves its own execution topology and provider-specific routing requirements.
   Source-provider model names, reasoning settings, profiles, launch attestations, and receipts are
   retained as opaque source evidence and are not translated into destination evidence.
4. Dry-run transition validation produces a complete proposed destination projection and result
   without changing the active checkpoint or user files.
5. Materialization repeats all contract and binding checks, then runs a read-only clean-worktree
   preflight. Any unrelated mutation blocks before archival, checkpoint replacement, delegation, or
   execution.
6. On success, the transition service archives the original source bytes by content digest, writes
   and validates a destination checkpoint candidate beside the active checkpoint, and atomically
   replaces `artifacts/orchestration/orchestrator-state.json` on the same filesystem.
7. The destination ordinary orchestrator reads the exact pinned plan, resolves and records new
   destination routing evidence for its first new delegation, and resumes at the recorded
   `next_transition`. Every phase in `completed_phases` is forbidden from replay.
8. When the work is a scheduled parallel or epic child, the ordinary orchestrator returns only the
   bounded child result defined by the handoff. The parent scheduler retains cohort/wave ordering,
   barriers, fan-in, integration, worktree cleanup, and overall run completion authority.

Alternate and error flows are fail-closed:

- A checkpoint without a portable schema version is treated as legacy v1. Migration requires an
  explicit source provider, source-provider validation when available, an exact verified plan, and
  hash-bound scheduler kickoff and parent state when the child was scheduled. Ambiguous facts remain
  unknown and block migration; they are never inferred from the four-field legacy checkpoint.
- A newer schema minor version may be accepted only when all declared vocabularies and required
  capabilities are supported. An unknown major version, required field, or transition is rejected.
- A malformed or unregistered MCP identifier, an unrelated semantic operation, an invalid path, a
  symlink escape, a digest mismatch, a wrong workspace or branch lineage, missing destination
  authority, or a replay request returns its defined failure code without changing files.
- Candidate validation or atomic replacement failure leaves the original canonical checkpoint
  intact and does not record a completed transition.

## Inputs / Outputs

- Inputs:
  - Explicit resolved `workspace_root`; implicit current-directory selection is not sufficient.
  - Exact source checkpoint path and expected raw-byte SHA-256.
  - Exact handoff-envelope path and expected raw-byte SHA-256.
  - Destination provider (`claude` or `codex`) and operation mode (`dry_run` or `materialize`).
  - Objective identity, issue number, feature folder, work mode, repository identity, branch,
    source HEAD, and allowed HEAD relationship.
  - Normalized repository-relative POSIX plan path, raw-byte SHA-256, and atomic-plan contract
    version.
  - Ordered completed logical phases, exact next transition, route intent, logical C1-C4
    complexity, and replay policy.
  - Optional scheduler context. It becomes required for a parallel or epic child and includes the
    run/item identity, kickoff or manifest path and hash, parent checkpoint path and hash,
    cohort/wave, scheduler owner, child owner, and return contract.
  - Required capability identifiers for schema major, transition, plan contract, semantic tools,
    validation authority, routing authority, and atomic materialization.
- Outputs:
  - A structured result with `validated`, `materialized`, or `blocked` status; handoff identity;
    source and envelope digests; requested transition; destination checkpoint path and digest when
    materialized; and one deterministic failure code plus details when blocked.
  - A versioned provider-neutral handoff envelope under `artifacts/orchestration/handoffs/`.
  - A raw-byte, content-addressed source archive under
    `artifacts/orchestration/handoffs/sources/sha256/` before canonical replacement.
  - A provider-native destination projection at
    `artifacts/orchestration/orchestrator-state.json`, linked to the accepted envelope and history
    digest.
  - An append-only, digest-linked handoff-history entry. Failed operations must never be represented
    as a completed transition.
  - A bounded scheduled-child result when scheduler context is present.
- Config keys and defaults:
  - A versioned semantic-tool and provider-adapter registry maps only registered transport aliases
    to canonical semantic operations and provider-native routing policies.
  - Logical complexity has no destination-model default in portable state. The destination applies
    its current provider policy before each new delegation.
  - No environment variable may override repository, workspace, plan, source digest, destination,
    or transition identity supplied by the validated request.
- Versioning and backward compatibility:
  - The portable envelope uses JSON Schema Draft 2020-12, an explicit `$schema`, and a semantic
    `schema_version`.
  - Schema major versions are compatibility boundaries. Supported newer minor versions require
    successful vocabulary and capability negotiation.
  - Existing provider-native checkpoints remain valid in their source runtime. Legacy migration is
    opt-in and produces a new envelope without rewriting the source bytes.

## API / CLI Surface

The public automation boundary is MCP. No general shell command, direct JSON edit, or ordinary
`apply_patch` operation may remove a preparation route or materialize a destination checkpoint.

- Extend `validate_orchestration_artifacts` to validate the portable envelope, provider source
  expression, proposed destination projection, workspace binding, plan identity, scheduler context,
  semantic capabilities, and ordered failure result through an explicit `workspace_root`.
- Add `transition_prepared_orchestration` as the sole mutating operation authorized through the
  preparation gate. Its request contract contains:

  ```text
  workspace_root: AbsolutePath
  source_checkpoint_path: RepositoryRelativePath
  expected_source_checkpoint_sha256: Sha256Hex
  handoff_envelope_path: RepositoryRelativePath
  expected_handoff_envelope_sha256: Sha256Hex
  destination_provider: claude | codex
  mode: dry_run | materialize
  ```

- `mode: dry_run` performs all non-mutating validation and returns the proposed destination
  projection identity. `mode: materialize` repeats validation, performs the clean-worktree check,
  archives source bytes, validates the candidate, and atomically replaces the canonical checkpoint.
- A successful result includes the source, envelope, history, and destination digests needed for
  later audit. A blocked result includes exactly one primary failure code selected by the contract
  order and may include structured affected paths or unsupported capabilities.
- Provider adapters implement portable-to-native checkpoint projection and native source
  validation. They do not expose a model-name translation API and do not modify historical receipts.
- Hooks and validators parse only registered identifiers using the `mcp__SERVER__OPERATION` grammar.
  They lowercase and normalize the registered `drm-copilot` server aliases (`_` and `-`) before
  exact operation comparison. Approximate operation matching and arbitrary server normalization are
  prohibited.

Validation uses this primary failure precedence across MCP, Python, TypeScript, and hook results:

1. `HANDOFF_UNSUPPORTED_VERSION`
2. `HANDOFF_SOURCE_HASH_MISMATCH`
3. `HANDOFF_HISTORY_INVALID`
4. `HANDOFF_REPOSITORY_MISMATCH`
5. `HANDOFF_WORKSPACE_MISMATCH`
6. `HANDOFF_ISSUE_FEATURE_MISMATCH`
7. `HANDOFF_BRANCH_LINEAGE_MISMATCH`
8. `HANDOFF_PLAN_PATH_INVALID`
9. `HANDOFF_PLAN_HASH_MISMATCH`
10. `HANDOFF_SCHEDULER_BINDING_MISMATCH`
11. `HANDOFF_TRANSITION_NOT_ALLOWED`
12. `HANDOFF_CAPABILITY_UNAVAILABLE`
13. `HANDOFF_VALIDATOR_UNAVAILABLE`
14. `HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE`
15. `HANDOFF_PROVIDER_ROUTING_UNAVAILABLE`
16. `HANDOFF_DIRTY_WORKTREE`

## Data & State

The contract separates portable state from provider-native and scheduler-native expressions:

| Layer | Contents | Owner | Mutation rule |
| --- | --- | --- | --- |
| General handoff envelope | Identity, bindings, lifecycle, plan, provenance, scheduler context, capabilities, and digest-linked history. | Shared schema and semantic validator. | History is append-only; hashed source and prior entries are immutable. |
| Provider expression | Claude or Codex checkpoint fields, model/profile evidence, launch attestations, and provider hook authorization. | Provider adapter and native validators. | Source expression stays opaque; destination adds evidence only for new work. |
| Operational projection | Active destination `orchestrator-state.json`. | Explicit transition service. | Validate a same-directory candidate, archive source bytes, then replace atomically. |
| Scheduler projection | Parallel/epic run and item identity, cohort/wave, ownership, and bounded result. | Parent scheduler adapter and validator. | Child updates only its allowed status/result fields. |

Required invariants are:

- Portable phase identifiers are `intake`, `promotion`, `research`, `feature_documents`,
  `atomic_planning`, `preflight`, `atomic_execution`, `qa`, `feature_review`, `pr_creation`,
  `ci_verification`, and `completion`.
- `completed_phases` is ordered, `next_transition` is exact, and
  `replay_policy: forbid_completed_phases` rejects an earlier-phase transition unless a separately
  versioned remediation transition explicitly permits it.
- The plan path is normalized, repository-relative, and POSIX-formatted. Absolute paths, `..`,
  directory rediscovery, symlink escapes, and raw-byte hash drift are invalid.
- Source provenance contains provider, exact checkpoint path, raw-byte digest, content-addressed
  archive path, provider expression schema/version, and opaque receipt references or digests.
- Handoff history uses monotonic sequence numbers and digest chaining over the previous entry. Each
  entry records source and destination provider, adapter version, timestamp, related digests,
  outcome, and a deterministic failure code when applicable.
- The destination checkpoint and parent scheduler retain the accepted envelope/history digest so
  later rewriting can be detected.
- The portable layer records logical complexity such as `C3`, not a provider model name. Each
  destination resolves and persists its own model, reasoning, profile, topology, and launch evidence
  only when performing a new delegation.
- Parallel and epic children retain scheduler ownership metadata. An ordinary orchestrator cannot
  advance a cohort or wave, fan in branches, remove worktrees, or declare the parent run complete.

Persistence is filesystem-based and intentionally uncached. All hashes are calculated over raw
bytes. Validation re-reads authoritative files before materialization so stale cached state cannot
authorize a transition.

Legacy migration does not backfill or rewrite historical provider records. It creates a v2 envelope
beside the source, archives exact source bytes, retains unknown historical facts as opaque or
unknown, and stops if the exact plan, lifecycle, or scheduler binding cannot be proven.

## Constraints & Risks

- Functional parity is required; a direct port of Claude implementation details is not.
- Historical checkpoints must remain auditable. In-place destructive conversion and lossy receipt
  normalization are prohibited.
- An ecosystem-specific model selection is not portable state. Only logical complexity and the fact
  that provider resolution is required are shared; each destination resolves future delegation
  evidence under its current policy.
- Plan discovery by directory is insufficient. Handoff requires an exact repository-relative plan
  path plus a verified content hash.
- Workspace binding must reject a different repository, branch lineage, issue, feature folder, or
  stale plan unless an explicit versioned migration rule authorizes the transition.
- Path resolution must reject traversal and symlink escape before any source archive, candidate
  write, or canonical replacement.
- Validation, routing resolution, digest calculation, and read-only Git status are local and bounded
  by artifact and worktree size. The transition introduces no network dependency in its critical
  section.
- The source archive and destination candidate must be on the same filesystem as the canonical
  checkpoint for atomic replacement semantics. A cross-filesystem destination is invalid.
- Root runtime files, extension resource copies, selected pack manifests, and installed consumer
  payloads can drift. Source/bundle/pack/install parity tests are release gates.
- Failures after preparation but before materialization must leave the source checkpoint active and
  usable by its original provider. A rollback must restore source authority, not weaken hooks or
  accept an unvalidated projection.
- This issue does not implement the complete Codex parallel scheduler from #467 or change the
  provider-specific epic ready-gate behavior tracked by #543.

## Implementation Strategy

- Implementation scope:
  - Add a Draft 2020-12 provider-neutral handoff schema, lifecycle vocabulary, semantic-tool and
    provider-adapter registry, digest/archive utilities, legacy-v1 reader, deterministic validator,
    destination materializer, and scheduled-child result contract.
  - Add Claude-to-Codex and Codex-to-Claude adapters while preserving each provider's native launch,
    worktree, model routing, receipt, and enforcement mechanisms.
  - Extend the extension MCP service with workspace-explicit portable validation/resolution and the
    explicit transition operation. Consumer repositories must not depend on
    `scripts.dev_tools.resolve_codex_topology` or other unshipped source modules.
  - Update `.codex/hooks/enforce-epic-planning-only.ps1` and its published copy to authorize the
    registered semantic transition operation while retaining denial of shell and direct-patch route
    changes.
  - Publish every runtime schema, registry, adapter, hook, and skill through both repository source
    and extension resource surfaces, register them in applicable core/variant manifests, and test
    the installed consumer payload.
- Existing boundaries to update include `scripts/dev_tools/validate_orchestrator_state.py`, shared
  handoff validation modules, `extensions/drm-copilot/src/lib/validate/`,
  `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`,
  `extensions/drm-copilot/src/repo-automation-tool-names.ts`, MCP service dispatch, provider
  orchestrate/state skills, routing/schema resources, customization bundles, pack manifests, and
  their parity and installed-consumer tests.
- Dependencies:
  - Add no third-party package. Use existing Python, Node.js/TypeScript, PowerShell, JSON Schema, Git,
    hashing, and filesystem capabilities already approved by the repository.
  - Issue #467 and issue #543 are related scope owners, not implementation dependencies for #614.
- Logging and diagnostics:
  - Return structured status, normalized semantic operation, selected adapter, validated digests,
    transition, primary failure code, and affected paths or missing capabilities where applicable.
  - Do not log source checkpoint bodies or provider credentials. Historical receipts remain in their
    governed artifacts rather than being copied into diagnostic text.
  - Do not mark any handoff-history entry completed until canonical replacement and destination
    validation both succeed.
- Rollout:
  1. Land the schema, registry, read-only validators, legacy migration reader, and bidirectional unit
     fixtures.
  2. Add dry-run transition and workspace-explicit consumer authority; prove deterministic parity
     across Python, TypeScript, and hooks.
  3. Add controlled materialization, provider projections, preparation-hook semantic authorization,
     and scheduled-child return validation.
  4. Publish and verify root/bundle/pack/install parity, then run TaskMaster #469 and inverse
     end-to-end fixtures plus all negative cases.
  5. On any rollout regression, keep or restore the original checkpoint as active authority and
     disable destination materialization without broadening preparation-shell permissions.

## Acceptance Criteria

- [ ] AC1: A Draft 2020-12, semantically versioned portable handoff envelope validates schema
  identity, objective, repository, workspace, branch lineage, issue, feature folder, work mode,
  ordered completed phases, exact next transition, logical complexity, capabilities, and exact plan
  path/hash before a destination runtime may continue.
- [ ] AC2: Source checkpoint identity uses the raw-byte SHA-256, the original bytes are archived by
  content digest before canonical replacement, prior provider receipts remain opaque and unchanged,
  and handoff history is monotonic and digest-linked.
- [ ] AC3: Plan validation accepts only the pinned normalized repository-relative path and raw-byte
  hash; it rejects absolute paths, `..`, symlink escape, directory rediscovery, and stale content.
- [x] AC4: Claude-to-Codex and Codex-to-Claude adapters carry portable complexity, lifecycle, route,
  plan, and ownership semantics while retaining provider-specific model, reasoning, profile,
  topology, launch, and receipt evidence only in the expression that produced it.
- [ ] AC5: A destination projection resumes the exact recorded transition and rejects replay of
  every listed completed phase; destination receipts begin only with the first new destination
  delegation and never represent historical source work.
- [ ] AC6: Parallel and epic child handoffs validate run/item, kickoff or manifest, parent checkpoint,
  cohort/wave, owner, and result bindings; an ordinary child can return its bounded result but cannot
  assume scheduler, barrier, fan-in, integration, cleanup, or parent-completion authority.
- [x] AC7: Hook and validator allowlists share one semantic MCP alias registry, accept both
  `mcp__drm-copilot__validate_orchestration_artifacts` and
  `mcp__drm_copilot__validate_orchestration_artifacts` as the same registered operation, and reject
  malformed identifiers, unrelated servers, and approximate or unregistered operations.
- [ ] AC8: Consumer repositories can perform workspace-explicit handoff validation, destination
  topology resolution, and provider routing through the published extension authority without
  importing unshipped drm-copilot Python modules; unavailable authority returns the specified single
  blocked result before delegation.
- [ ] AC9: `transition_prepared_orchestration` is the only preparation-gate operation permitted to
  materialize a destination checkpoint; ordinary shell and patch route changes remain denied, and
  dry-run mode performs no canonical-checkpoint or user-file mutation.
- [ ] AC10: Materialization repeats validation, performs a read-only clean-worktree preflight, writes
  and validates a same-directory candidate, archives source bytes, and atomically replaces the
  canonical checkpoint; any failure leaves the source checkpoint intact and records no completed
  transition.
- [ ] AC11: Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered
  `HANDOFF_*` precedence. The TaskMaster fixture's unrelated `.csproj` changes produce only
  `HANDOFF_DIRTY_WORKTREE` after all earlier contract and authority checks pass, with the dirty paths
  reported and unmodified.
- [ ] AC12: Legacy-v1 migration requires an explicit source provider and independently proven plan,
  lifecycle, and scheduled-parent facts. The four-field TaskMaster checkpoint cannot fabricate
  missing history; ambiguous migration stops before source archive or active-checkpoint change.
- [ ] AC13: End-to-end TaskMaster issue #469 fixtures pin source and plan raw-byte hashes, prove
  Claude-prepared to Codex-execution-ready continuation without completed-phase replay or historical
  receipt fabrication, and prove the symmetric Codex-to-Claude transition.
- [ ] AC14: Root, extension-resource, core/variant-pack, and installed-consumer parity tests prove all
  required runtime files ship together and the consumer flow works without drm-copilot source
  modules.
- [ ] AC15: Regression tests demonstrate that issue #467 remains the sole owner of full Codex-native
  parallel scheduling and issue #543 remains the sole owner of the provider-specific epic-planner
  ready-gate defect; #614 changes neither behavior.

## Definition of Done

- [ ] Acceptance criteria in both `spec.md` and `user-story.md` are individually mapped to named
  automated tests or an explicit deterministic demonstration.
- [ ] Bidirectional ordinary, parallel-child, and epic-child handoff behavior matches the documented
  lifecycle and ownership contracts.
- [ ] Schema, adapter, migration, validator, hook-process, extension MCP, publishing-parity,
  installed-consumer, and TaskMaster #469 fixture tests are added or updated.
- [ ] Unsupported versions, tampered history/source/plan, invalid paths, wrong bindings, unavailable
  capabilities/authorities, replay, dirty worktrees, candidate failure, and atomic-replacement failure
  are covered without mutating the source state.
- [ ] Provider orchestrate/state documentation, schema/registry documentation, MCP interface
  documentation, pack manifests, and consumer runtime guidance are updated together.
- [ ] Structured transition results and deterministic failure logging are implemented without
  copying sensitive checkpoint bodies into diagnostics.
- [ ] The required formatting, linting, type-checking, architecture, unit, contract, integration, and
  publishing-parity gates complete in one clean pass with required coverage and canonical evidence.

## Seeded Test Conditions (from potential)

- [ ] Schema and adapter fixtures cover both directions, legacy checkpoint migration, supported and
  unsupported future schema versions, tampered source hashes, stale plan hashes, wrong
  workspace/repository/branch/issue/feature bindings, unknown transitions, and preservation of opaque
  historical receipts.
- [ ] Hook process tests cover hyphenated and underscore-normalized MCP identifiers, malformed
  identifiers, unrelated tools, unregistered operations, and exact allow/deny output and exit
  behavior.
- [ ] Published consumer-repository tests run workspace-explicit topology resolution and validation
  without importing unshipped drm-copilot source modules.
- [ ] End-to-end TaskMaster #469 fixtures verify preparation-to-execution continuation without phase
  replay and verify clean-worktree blocking independently of handoff-schema acceptance.
- [ ] Parallel and epic regression fixtures prove scheduled child preparation can be completed
  piecemeal by an ordinary destination orchestrator without changing scheduler ownership.
