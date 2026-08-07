---
epic: parallel-orchestration
integration_branch: epic/parallel-orchestration-integration
created_at: 2026-08-07T00:00:00Z
# Authoring-time manifest. issue_num values -1 through -8 are placeholders that are
# back-filled with the real GitHub issue numbers from each child's promotion receipt
# as preparation completes. feature_folder values are placeholder hints that resolve
# to concrete docs/features/active/<basename> paths after promotion. depends_on uses
# issue_num values (the canonical primary-key form). The DAG is cycle-free and every
# depends_on entry resolves.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A parallel-orchestration mechanism lets the repository execute multiple thematically unrelated bugs and features concurrently, scheduled by computed blast-radius contention rather than a hand-authored dependency graph, raising delivery throughput without relaxing the merge-safety guarantees the epic surfaces already enforce.
  leading_indicators:
    - A parallel run schedules two or more non-conflicting items into one cohort and merges each to main independently.
    - Blast-radius V1 coverage validation rejects an atomic plan whose task bodies name a path outside the declared radius.
    - A radius-drift event halts the later-started conflicting item rather than the drifting item, and is recorded in drift_events[].
  nfrs:
    - Cohort scheduling is deterministic; identical inputs produce identical cohort assignments across Python and PowerShell implementations.
    - The contention relation fails closed; an unmodeled overlap must serialize rather than parallelize.
    - Line coverage >= 85%, branch coverage >= 75% for every new module.
features:
  - issue_num: -1
    feature_folder: parallel-blast-radius
    depends_on: []
  - issue_num: -2
    feature_folder: parallel-cohort-scheduler
    depends_on: []
  - issue_num: -3
    feature_folder: parallel-schema-validators
    depends_on: [-1, -2]
  - issue_num: -4
    feature_folder: parallel-planner-surface
    depends_on: [-1, -2, -3]
  - issue_num: -5
    feature_folder: parallel-orchestrator-surface
    depends_on: [-3, -4]
  - issue_num: -6
    feature_folder: parallel-mutation-protocol
    depends_on: [-5]
  - issue_num: -7
    feature_folder: parallel-enforcement-hooks
    depends_on: [-3, -5]
  - issue_num: -8
    feature_folder: parallel-drift-detection
    depends_on: [-1, -3, -5]
---

# Epic: Parallel Orchestration (`parallel-plan` / `parallel-run`)

## Goal

Build a `parallel` orchestration surface, structurally parallel to the existing `epic` surface,
that executes multiple **independent** bugs and features concurrently under one central
orchestration with child orchestrations on isolated worktrees. Unlike an epic, the items share no
theme and no common deliverable: concurrency is decided by **computed blast-radius contention**
rather than a human-authored dependency graph, and the item set is **mutable mid-execution**.

The authoritative design input is
`docs/research/2026-08-07-parallel-orchestration-design-research.md`, committed to this
integration branch so every child worktree can read it. Section references below (§N) refer to
that document.

## Scope

The epic delivers the complete `parallel` surface:

- Skills `parallel-plan`, `parallel-run`, `parallel-orchestrate`.
- Agents `parallel-planner`, `parallel-orchestrator`.
- Home `docs/features/parallel/<slug>/`, manifest `parallel.md`, generated projection
  `parallel-status.md`.
- Route `route_id: parallel` in `config/orchestration-routing.json`.
- Checkpoints `artifacts/orchestration/parallel-planner-state.json` and
  `artifacts/orchestration/parallel-orchestrator-state.json`, each with a validator.
- Blast-radius computation (§5) and Welsh-Powell cohort scheduling (§6) as tested reference
  implementations with cross-language parity, in the manner of `epic_wave_computation.py` and
  the model-routing formulas.
- Radius-drift detection (§7), the mutation protocol (§8), and the two-layer enforcement design
  (§9).

## Non-Goals

- **Key-level partitioning of shared surfaces.** §5.4 fails closed: a shared surface creates a
  conflict by default. Partitioning disjoint keys of the same JSON map is a deliberate future
  refinement (§13.2), explicitly out of scope for this build.
- **Changing the atomic-plan contract.** §5.3 records the accepted decision to leave
  `.claude/skills/atomic-plan-contract/SKILL.md` unchanged and derive the blast radius
  heuristically instead. No child feature may add a machine-parseable per-task file list to the
  shared plan contract.
- **Optimal graph coloring.** §13.3 accepts greedy Welsh-Powell in exchange for determinism.
- **An integration branch for parallel runs.** §4: each item PRs to `main` independently. The
  epic-only artifacts `enforce-epic-merge-gate.ps1`, the final integration PR, and the fan-in
  merge-conflict path have no parallel counterpart.
- **Retiring or modifying the `epic` surface.** The `parallel` surface is additive. Reuse is by
  near-verbatim adaptation into new files, not by refactoring the epic implementations into a
  shared abstraction.

## Shared Design

Every child feature must honor these cross-cutting decisions from §3 and §4:

1. **Name.** The surface is `parallel` throughout: skills, agents, route id, checkpoint
   filenames, hook filenames, and validator module names.
2. **No `depends_on` field.** The manifest carries no dependency edges (§11). Ordering a human
   would express as a dependency is expressed as blast-radius overlap and derived by the
   scheduler.
3. **`issue_num` is the primary key**, matching the epic manifest convention, so identifiers do
   not drift when a feature moves from `active/` to `completed/`.
4. **Mode is `closed | open`, default `closed`** (§3, §8.7).
5. **Blast radius is planner-computed and validated against the approved atomic plan** (§3,
   §5.3), with V1 coverage and V2 shared-surface enumeration Blocking, and V3 over-breadth
   Advisory.
6. **In-flight removal is rejected without an explicit `detach | abandon` disposition** (§3,
   §8.4).
7. **Fail closed.** The contention relation (§5.4) must never assume safety it has not proven.

## Decomposition Rationale

The design document's §10 proposed seven features. This epic uses eight: §10's F7 is split into
enforcement hooks (F7) and radius-drift detection (F8). The two are separable — F7 is
cohort-ordering and lifecycle gating, F8 is diff-versus-declared-radius comparison and requeue
logic — and splitting them keeps each child inside a workable change budget while widening the
final wave from two concurrent features to three. The abandon gate from §9 is assigned to F6
rather than F7, because it enforces the `--disposition abandon` contract that F6 defines; keeping
them together avoids an otherwise unnecessary dependency edge.

Dependency edges are derived from real upstream contracts only:

| Feature | Depends on | Contract consumed |
| --- | --- | --- |
| F1 blast-radius library | — | — |
| F2 cohort scheduler | — | — |
| F3 schema and validators | F1, F2 | Serializes the radius shape (F1) and cohort/coloring output (F2) into the manifest and checkpoint schemas. |
| F4 `parallel-planner` surface | F1, F2, F3 | Calls radius derivation and V1–V3 validation (F1), seeds cohorts (F2), writes the manifest and planner checkpoint (F3). |
| F5 `parallel-orchestrator` surface | F3, F4 | Reads the manifest and orchestrator checkpoint (F3) and consumes the prepared plan the planner emits (F4). |
| F6 mutation protocol | F5 | Mutates a live run's cohort table and item states, which only exist once the orchestrator does. |
| F7 enforcement hooks | F3, F5 | Layer 2 adds an invariant to F3's orchestrator-state validator; Layer 1 gates F5's child delegations. |
| F8 drift detection | F1, F3, F5 | Compares an observed radius against a declared one (F1), records `drift_events[]` (F3), and requeues in-flight items (F5). |

### Computed Waves

Longest-path layering over the DAG above yields five waves:

| Wave | Features |
| --- | --- |
| 0 | F1 blast-radius library, F2 cohort scheduler |
| 1 | F3 schema and validators |
| 2 | F4 `parallel-planner` surface |
| 3 | F5 `parallel-orchestrator` surface |
| 4 | F6 mutation protocol, F7 enforcement hooks, F8 drift detection |

### Wave-4 Contention Note

F6, F7, and F8 execute concurrently and all three extend
`.claude/skills/parallel-orchestrate/SKILL.md` and, to a lesser degree,
`validate_parallel_orchestrator_state.py`. Each child's atomic plan must confine its edits to a
distinct, explicitly named new section of those files and must not reflow or reorder existing
sections. F3 owns the complete checkpoint schema — including `mutations[]`, `drift_events[]`, and
`conflict_edges[]` — so F6 and F8 consume those structures rather than adding schema fields.
This is a decomposition constraint, not a suggestion: it is what keeps wave-4 fan-in merges
mechanical.

## Per-Feature Scope and Complexity

### F1 — Blast-radius library (`C4`)

`scripts/dev_tools/compute_blast_radius.py`, `.claude/lib/blast-radius/BlastRadius.psm1`, the
shared-surface configuration truth table, a cross-language parity test, and the `conflicts(a, b)`
contention relation (§5.4). Implements the four-level radius model (§5.1), the three confidence
sources (§5.2), and derivation plus V1–V3 validation (§5.3).

Band `C4`: the derivation heuristic is novel, has no in-repository prior art, and §13.1 names
under-reporting the dominant risk of the entire design. Floor is `C3` from
`cross_module_contract_change`; judgment raises it because the work is genuinely ambiguous.

**Known constraint.** §5.1 specifies mapping paths to modules via `quality-tiers.yml`, but **no
`quality-tiers.yml` exists at the repository root** — only `.claude/rules/quality-tiers.md`,
which documents the tier system in prose without a machine-readable project map. F1's research
must resolve this explicitly: either create the missing `quality-tiers.yml`, or define an
alternative module-resolution source and record the deviation from §5.1.

### F2 — Cohort scheduler (`C3`)

`scripts/dev_tools/parallel_cohort_computation.py` implementing deterministic greedy coloring in
Welsh-Powell order (descending degree, ties broken by ascending item key), plus the
`max_concurrency` slot-filling rule (ascending item key) and a parity test. Band `C3`: floor
`C3` from `concurrency_or_ordering`; the algorithm is well known and closely patterned on
`epic_wave_computation.py`.

### F3 — Manifest and checkpoint schema (`C3`)

The §11 manifest schema and §12 checkpoint schema, `validate_parallel_orchestrator_state.py`,
`validate_parallel_planner_state.py`, MCP `artifact_type` wiring in the
`validate_orchestration_artifacts` tool, `.claude/rules/parallel-orchestration.md`, and
`route_id: parallel` in `config/orchestration-routing.json`. Band `C3`: floor `C3` from
`cross_module_contract_change`; large surface but strongly patterned on the existing epic
validators.

### F4 — `parallel-planner` agent and `parallel-plan` skill (`C3`)

Preparation fan-out reusing the `route_id: preparation` child contract unchanged, radius
computation and V1–V3 validation, cohort seeding, and the kickoff artifact. Band `C3`: floor
`C3` from `cross_module_contract_change`; patterned on `epic-planner` / `epic-plan`.

### F5 — `parallel-orchestrator` agent and `parallel-orchestrate` / `parallel-run` skills (`C3`)

Cohort scheduling and fan-out, per-item merge to `main` (not to an integration branch), and the
`parallel-status.md` generated projection. Band `C3`: floor `C3` from `concurrency_or_ordering`
and `cross_module_contract_change`.

### F6 — Mutation protocol (`C4`)

`/parallel-add`, `/parallel-remove`, `/parallel-close`, admission control (§8.3), the pinning
invariant (§8.1), the mutation log (§8.6), the item lifecycle (§8.2), mode-dependent completion
semantics (§8.7), and the abandon gate from §9.

Band `C4`: floor `C3` from `concurrency_or_ordering`; judgment raises it because dynamic
membership is a pure delta from the epic surface (§4) with no prior art to pattern-match, and the
pinning invariant must hold against a live, concurrently mutating set of in-flight items.

### F7 — Enforcement hooks (`C3`)

`.claude/hooks/enforce-parallel-cohort-barrier.ps1` (Layer 1), the cohort-ordering invariant in
`validate_parallel_orchestrator_state_text` (Layer 2),
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, and the extension of
`.claude/hooks/enforce-epic-invocation-origin.ps1` to deny `Agent(parallel-orchestrator)` and
`Agent(parallel-planner)` calls originating from `orchestrator`. Band `C3`: floor `C3` from
`concurrency_or_ordering`; adapted near-verbatim from proven epic hooks.

### F8 — Radius drift detection (`C3`)

The §7 six-step procedure evaluated at each child's pre-review commit: diff-versus-declared
comparison, `drift_events[]` recording, synthetic Blocking finding into the child's
`remediation-inputs.<timestamp>.md`, cohort quiesce, conflict recomputation, and halting the
**later-started** item of a newly conflicting pair. Includes the drift gate that blocks a child's
transition to review while an unresolved drift event exists. Band `C3`: floor `C3` from
`concurrency_or_ordering`; the procedure is precisely specified in §7.

## Reuse Inventory

Reusable near-verbatim from the epic surfaces (§10): the preparation-mode child contract, the
merge-on-green S9 extension, the worktree-removal gate, the invocation-origin gate, and the
R1–R5 remediation loop. Children should adapt these into new `parallel`-named files rather than
generalizing the epic implementations in place.

## Open Risks Carried From Design

1. **Heuristic derivation under-reports** (§13.1). Bounded by V1 at plan time (F1) and drift
   detection at execution time (F8), not eliminated.
2. **Shared-surface serialization** (§13.2). Failing closed may collapse most cohorts to size
   one. Measure before building key-level partitioning.
3. **Greedy coloring is not optimal** (§13.3). Accepted for determinism.
4. **Concurrency cost** (§13.4). `max_concurrency` default of 4 is a starting value, not a
   measured one.
