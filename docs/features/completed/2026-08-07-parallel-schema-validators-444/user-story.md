# `2026-08-07-parallel-schema-validators` — User Story

- Issue: #444
- Owner: drmoisan
- Status: Ready for Planning
- Last Updated: 2026-08-07T12-30

## Story Statement

- As the author of the `parallel-planner` surface (F4), I want the manifest and planner-checkpoint
  schemas defined and validated before I build, so that the planner writes artifacts whose
  structure is enforced by a validator rather than invented per feature.
- As the author of the `parallel-orchestrator` surface (F5), I want the orchestrator-checkpoint
  schema — including `cohorts[]`, `conflict_edges[]`, and per-item merge state — owned by one
  upstream feature, so that resume and completion gating read a stable, validated contract.
- As an author of a wave-4 feature (F6 mutation protocol, F7 enforcement hooks, F8 drift
  detection), I want `mutations[]`, `drift_events[]`, and `conflict_edges[]` fully shaped by F3,
  so that my feature adds behavior only and never edits the shared schema concurrently with its
  siblings.
- As the repository operator resuming or reviewing a parallel run, I want checkpoint validation
  reachable through the `validate_orchestration_artifacts` MCP tool and CLI, so that no workflow
  builds on a structurally invalid checkpoint.

## Problem / Why

The `parallel-orchestration` epic builds a `parallel` orchestration surface that runs multiple
thematically unrelated bugs and features concurrently, scheduled by computed blast-radius
contention rather than a human-authored dependency graph. Every downstream feature in that epic
(the planner surface, the orchestrator surface, the mutation protocol, the enforcement hooks, and
drift detection) reads and writes two artifacts that do not yet exist:

1. The parallel-run manifest at `docs/features/parallel/<slug>/parallel.md`.
2. The parallel-orchestrator checkpoint at
   `artifacts/orchestration/parallel-orchestrator-state.json`, plus the planner checkpoint at
   `artifacts/orchestration/parallel-planner-state.json`.

Without a defined and validated schema for both, each downstream feature would invent its own
field shapes, and the wave-4 features (mutation protocol, enforcement hooks, drift detection)
would each add schema fields to the same files concurrently. The epic decomposition explicitly
assigns the complete schema to this feature so downstream features add behavior only.

The repository already has the structural precedent: `validate_epic_orchestrator_state.py` and
`validate_epic_planner_state.py`, the `epic` route in `config/orchestration-routing.json`, the
`.claude/rules/orchestrator-state.md` prose-and-validator enforcement pattern, and the
`validate_orchestration_artifacts` MCP tool's `artifact_type` dispatch. This feature adapts that
precedent to the `parallel` surface additively.

Upstream note: F1 (`parallel-blast-radius`) and F2 (`parallel-cohort-scheduler`) are wave-0
siblings prepared concurrently; their specs have not landed on this branch. The schema shapes this
feature serializes for them are taken from the accepted design document and recorded as explicit
assumptions A1–A8 in `spec.md` ("Upstream Assumptions"), so a later reconciliation against the
landed F1/F2 specs is possible.

## Personas & Scenarios

- Persona: downstream `parallel` surface implementer (F4/F5 executor agent)
  - Builds the planner and orchestrator agents/skills in later waves.
  - Cares about a stable artifact contract: required keys, enums, defaults, and error messages
    that do not change underneath the implementation.
  - Constrained by the epic wave-barrier: cannot negotiate schema changes with concurrent
    siblings.
  - Frustration this feature removes: discovering at integration time that two features shaped
    the same checkpoint field differently.
- Persona: wave-4 implementer (F6/F7/F8 executor agent)
  - Consumes `mutations[]`, `drift_events[]`, and `conflict_edges[]` while executing concurrently
    with two siblings against the same files.
  - Needs the complete field shapes plus a delimited insertion seam in the orchestrator validator
    (F7's Layer-2 invariant) so its edit is one appended helper call.
- Persona: repository operator / reviewer
  - Resumes interrupted parallel runs and reviews feature branches.
  - Needs the MCP tool and CLI to reject a malformed checkpoint before any workflow depends on
    it, and needs `.claude/rules/parallel-orchestration.md` as the citable prose rule during
    feature review.

- Scenario: planner checkpoint validation during a parallel run
  - The `parallel-planner` agent (F4) finishes preparation fan-out and writes
    `artifacts/orchestration/parallel-planner-state.json`.
  - Before declaring readiness, it calls the MCP tool `validate_orchestration_artifacts` with
    `artifact_type: parallel-planner-state` and `require_ready_for_execution` enabled.
  - The validator reports that one item has `preparation_status` other than `prepared` and that
    `next_step` is not `PARALLEL_EXECUTION_READY`; each error is a literal, context-prefixed
    string naming the offending item.
  - The planner completes preparation, rewrites the checkpoint, revalidates, and the ready gate
    passes. Execution starts against a structurally verified artifact.
- Scenario: wave-4 concurrent extension without schema contention
  - F6, F7, and F8 execute concurrently. F6 appends `mutations[]` entries using the S5 shape from
    `spec.md`; F8 records `drift_events[]` using the S6 shape; F7 appends its cohort-ordering
    invariant at the documented seam in `validate_parallel_orchestrator_state.py`.
  - None of the three edits a schema definition, so the wave-4 fan-in merges remain mechanical,
    as the epic's wave-4 contention rule requires.
- Scenario: malformed checkpoint rejected at resume
  - An interrupted run leaves a checkpoint in which an item has `merge_status: merged` but
    `state: in_flight`, and a `cohorts[]` entry references an `issue_num` that is no longer in
    `items[]`.
  - The operator validates the checkpoint via the CLI; the validator emits one error per violated
    invariant (state/merge-status consistency; unresolved cohort item key) and exits 1.
  - The operator re-derives the true state from `git worktree list --porcelain`, `git branch`,
    and `gh pr view` — the checkpoint is a cache, not the source of truth — and repairs the
    checkpoint before resuming.

## Acceptance Criteria

- [x] The manifest schema is defined and validated per design section 11, with `mode` defaulting to `closed` and `max_concurrency` defaulting to 4, via `scripts/dev_tools/parallel_manifest_contract.py` and its default-resolving accessors.
- [x] The checkpoint schema is defined and validated per design section 12, including `current_cohort`, `recolor_generation`, `cohorts[]`, `items[]`, `conflict_edges[]`, `mutations[]`, `drift_events[]`, and the three receipt arrays.
- [x] `scripts/dev_tools/validate_parallel_orchestrator_state.py` exists and enforces the checkpoint invariants, with completion gating (closed and open mode) only under `require_complete`.
- [x] `scripts/dev_tools/validate_parallel_planner_state.py` exists and enforces the planner-checkpoint invariants, with the readiness gate (including the `PARALLEL_EXECUTION_READY` sentinel and kickoff path) only under `require_ready_for_execution`.
- [x] `validate_orchestration_artifacts` accepts `parallel-orchestrator-state` and `parallel-planner-state` as `artifact_type` values on both the Python CLI and the MCP TypeScript surface, and unknown artifact types still fail.
- [x] The TypeScript validator cores produce error strings byte-identical to the Python validators (full-parity port, epic precedent).
- [x] `.claude/rules/parallel-orchestration.md` records the invariants as numbered prose in the manner of `.claude/rules/orchestrator-state.md`, including the cache-not-source-of-truth doctrine and the omitted-epic-fields table.
- [x] `route_id: parallel` is present in `config/orchestration-routing.json` and its byte-identical bundled mirror under `extensions/drm-copilot/resources/config/`.
- [x] No `depends_on` field exists anywhere in the manifest or checkpoint schema; the validators explicitly reject its presence.
- [x] No integration-branch or final-integration-PR field exists anywhere in the schemas; the validators explicitly reject `integration_branch` and `epic_merge_pr`.
- [x] `mutations[]`, `drift_events[]`, and `conflict_edges[]` are fully shaped by this feature per spec sections S5–S7, so F6, F7, and F8 need no schema additions.
- [x] The existing epic validators (`validate_epic_orchestrator_state.py`, `validate_epic_planner_state.py`, their helpers, TS cores, and tests) are unmodified.
- [x] Line coverage >= 85% and branch coverage >= 75% for every new module, with tests under `tests/scripts/dev_tools/` (Pytest) and `extensions/drm-copilot/test/` (Jest).

## Non-Goals

- **A `parallel-manifest` MCP artifact type.** Manifest validation ships as a standalone Python
  module (spec decision 3.2-A); the MCP surface grows by exactly the two promised artifact types.
  Adding a third type later is additive if F4 needs it.
- **F7's Layer-2 cohort-ordering invariant** (`PARALLEL_COHORT_BARRIER_VIOLATION`). F3 provides
  only the delimited insertion seam; the invariant itself is F7 scope.
- **Recoloring recomputation parity.** Cross-checking `cohorts[]` against
  `parallel_cohort_computation.py` output is F4's planner-side check (spec P5).
- **Deep readiness-integrity machinery** (git integrity, launch-evidence binding,
  kickoff-contract cross-checks). F3's ready gate is structural only; F4 may layer
  repository-aware checks behind an additional keyword without changing the schema.
- **State-transition legality.** Which item state may follow which is F6 behavior; F3 validates
  shape, enum membership, and null rules only.
- **Drift detection behavior.** Diff-versus-declared comparison, quiesce, and requeue are F8
  scope; F3 defines only the `drift_events[]` record shape.
- **Key-level partitioning of shared surfaces** (epic non-goal; design section 13.2).
- **Modifying the epic validators, the atomic-plan contract, or any `.github/` policy file.**
- **Authoring or importing any JSON Schema file.** Enforcement is Python validator logic plus
  prose rules per `.claude/rules/orchestrator-state.md`.
