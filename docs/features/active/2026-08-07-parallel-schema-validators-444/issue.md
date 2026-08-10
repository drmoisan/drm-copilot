# parallel-schema-validators (Issue #444)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-schema-validators/ (Issue #444)
- Epic: `parallel-orchestration` (child feature F3, wave 1)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` sections 11 and 12

- Issue: #444
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/444
- Last Updated: 2026-08-07
- Work Mode: full-feature

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

## Proposed Behavior

Deliver the manifest schema, the checkpoint schema, and their validators:

- **Manifest schema** (design section 11) for `docs/features/parallel/<slug>/parallel.md`
  frontmatter: `parallel`, `mode` (`closed | open`, default `closed`), `max_concurrency`
  (default 4), `created_at`, and `items[]` carrying `issue_num`, `feature_folder`, `kind`,
  `state`, and a nested `blast_radius` block (`paths`, `modules`, `shared_surfaces`, `contracts`,
  `source`, `computed_at`).
- **Checkpoint schema** (design section 12) for
  `artifacts/orchestration/parallel-orchestrator-state.json`, including `current_cohort`,
  `recolor_generation`, `cohorts[]`, `items[]`, `conflict_edges[]`, `mutations[]`,
  `drift_events[]`, and the three receipt arrays.
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
- `scripts/dev_tools/validate_parallel_planner_state.py`.
- MCP `artifact_type` wiring so `validate_orchestration_artifacts` accepts
  `parallel-orchestrator-state` and `parallel-planner-state`.
- `.claude/rules/parallel-orchestration.md` recording the invariants as prose.
- `route_id: parallel` added to `config/orchestration-routing.json`.

This feature owns `mutations[]`, `drift_events[]`, and `conflict_edges[]` in full, including their
field shapes, so the wave-4 features consume those structures rather than extending the schema.

## Acceptance Criteria (early draft)

- [ ] The manifest schema is defined and validated per design section 11, with `mode` defaulting to `closed` and `max_concurrency` defaulting to 4.
- [ ] The checkpoint schema is defined and validated per design section 12, including all arrays named there.
- [ ] `validate_parallel_orchestrator_state.py` exists and enforces the checkpoint invariants.
- [ ] `validate_parallel_planner_state.py` exists and enforces the planner-checkpoint invariants.
- [ ] `validate_orchestration_artifacts` accepts `parallel-orchestrator-state` and `parallel-planner-state` as `artifact_type` values.
- [ ] `.claude/rules/parallel-orchestration.md` records the invariants as prose, in the manner of `.claude/rules/orchestrator-state.md`.
- [ ] `route_id: parallel` is present in `config/orchestration-routing.json`.
- [ ] No `depends_on` field exists anywhere in the manifest or checkpoint schema.
- [ ] No integration-branch or final-integration-PR field exists anywhere in the schemas.
- [ ] The existing epic validators are unmodified.

## Constraints & Risks

- **No `depends_on` field.** Ordering is expressed as blast-radius overlap and derived by the
  scheduler (design sections 4 and 11). Dependency edges must not be added.
- **`issue_num` is the primary key**, matching the epic manifest convention so the identifier does
  not drift when a feature moves from `active/` to `completed/`.
- **No integration branch.** Each parallel item PRs to `main` independently (design section 4).
  The schema must carry no integration-branch or final-integration-PR fields.
- **No foreign JSON Schema.** Per `.claude/rules/orchestrator-state.md`, this repository enforces
  checkpoint invariants through Python validator logic and prose rules, not imported schema files.
- **Additive only.** The existing epic validators must not be modified or refactored.
- **The checkpoint is a cache**, not the source of truth: every field is re-derivable from
  `git worktree list --porcelain`, `git branch`, and
  `gh pr view --json state,mergedAt,headRefOid`.
- **Upstream coupling.** The `blast_radius` block serializes F1's output shape (design section 5)
  and `cohorts[]` / `recolor_generation` serialize F2's output (design section 6). If those
  features' specs have not landed, the design sections are the contract and the assumption must be
  recorded.
- **File-size limit.** No production or test file may exceed 500 lines; the validators must be
  decomposed into helper modules in the manner of `_orchestrator_state_*.py`.

## Test Conditions to Consider

- [ ] Unit coverage for each checkpoint invariant: valid case, each malformed case, and the absent-key backward-compatible case.
- [ ] Unit coverage for each manifest invariant, including the `mode` and `max_concurrency` defaults.
- [ ] Enum-membership coverage for item `state`, per-item `merge_status`, `blast_radius.source`, and `mutations[].op`.
- [ ] Negative coverage asserting that a `depends_on` field is rejected or absent from the schema surface.
- [ ] Coverage that `conflict_edges[]`, `mutations[]`, and `drift_events[]` validate their full field shapes.
- [ ] MCP dispatch coverage that `parallel-orchestrator-state` and `parallel-planner-state` route to the correct validators and that unknown `artifact_type` values still fail.
- [ ] A regression assertion that the existing epic validators and their tests are unchanged.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/parallel-schema-validators/` folder from the template
