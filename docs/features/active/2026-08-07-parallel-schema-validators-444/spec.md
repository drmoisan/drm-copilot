# 2026-08-07-parallel-schema-validators — Spec

- **Issue:** #444
- **Parent (optional):** `parallel-orchestration` epic (child feature F3, wave 1)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T12-30
- **Status:** Ready for Planning
- **Version:** 1.0

## Overview

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

Authoritative requirements: `docs/research/2026-08-07-parallel-orchestration-design-research.md`
sections 11 and 12 (cited below as §N), with sections 5, 6, 7, and 8 defining the structures being
serialized. The feature research at
`research/2026-08-07T12-00-parallel-schema-validators-research.md` supplies the field-by-field
schemas, invariant sets, and edit-point trace carried into this spec.

## Upstream Assumptions (A1–A8) — carried explicitly for later reconciliation

The wave-0 siblings F1 (`parallel-blast-radius`) and F2 (`parallel-cohort-scheduler`) are prepared
concurrently with this feature and their specs have NOT landed on this branch (verified: no
`docs/features/active/*parallel*` folder exists other than this feature's own). The shapes below
are therefore taken from the accepted design document, not from landed sibling specs. If an F1 or
F2 spec lands with a divergent shape, the divergence must be reconciled at spec review, before
plan execution — not discovered at wave-4 integration.

- **A1 — Blast-radius shape** (design §5.1–§5.2, not a landed F1 spec): `blast_radius` is
  `{ paths: [glob...], modules: [project...], shared_surfaces: [path...],
  contracts: [identifier...], source: derived|declared|observed, computed_at: iso8601 }`. All
  four collection fields are lists of strings; `paths` is the primary signal.
- **A2 — Contention relation** (design §5.4, not a landed F1 spec):
  `conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR
  contract_dependency`, failing closed. This yields the `conflict_edges[].reason` enum
  `path_overlap | module_overlap | shared_surface_overlap | contract_dependency`, one value per
  disjunct.
- **A3 — Cohort shape** (design §6, §8.6, §12, not a landed F2 spec): a cohort is
  `{ index: int >= 0, generation: int >= 0, item_keys: [item_key...] }`; `recolor_generation`
  increments on each recompute; coloring is deterministic Welsh-Powell with ties broken by
  ascending item key; `max_concurrency` caps fan-out with slots filled in ascending item-key
  order.
- **A4 — Item key:** `issue_num` is the primary key (§11, epic shared-design decision 3), so
  `item_key` values in `cohorts[].item_keys`, `conflict_edges[].a/b`, `mutations[].item_key`, and
  `drift_events[].item_key` are integers equal to an `items[].issue_num`. "Ascending item key"
  is numeric ascending `issue_num`.
- **A5 — Planner-checkpoint shape:** design §3 names
  `artifacts/orchestration/parallel-planner-state.json` but §12 details only the orchestrator
  checkpoint. The planner-checkpoint shape in this spec is F3-proposed by adaptation of
  `validate_epic_planner_state.py`; F4 consumes it and must not add schema fields.
- **A6 — Kickoff path convention:** `artifacts/orchestration/parallel-kickoff-<slug>.md` is
  F3-proposed by adaptation of the epic kickoff-path invariant; F4 consumes it.
- **A7 — `max_concurrency` upper bound:** the design sets only the default of 4 (§11, §13.4).
  This spec ACCEPTS the recommended bound of 1 through 8, for symmetry with the epic surface
  (`max_parallel_features` validated as `1..8`). The bound is an F3 decision and must be recorded
  in `.claude/rules/parallel-orchestration.md`.
- **A8 — Drift-action enum and recording rule:** `drift_events[].action` in
  `{raised_blocking_finding, halted_later_started_item}` and the one-event-strongest-action
  recording rule are F3-owned decisions derived from the §7 procedure; F8 consumes without
  extending.

## Behavior

Deliver the manifest schema, the checkpoint schemas, and their validators:

- **Manifest schema** (§11, section "Schema Definitions" below) for
  `docs/features/parallel/<slug>/parallel.md` frontmatter, validated by a standalone module
  `scripts/dev_tools/parallel_manifest_contract.py` with default-resolving accessors.
- **Orchestrator checkpoint schema** (§12) for
  `artifacts/orchestration/parallel-orchestrator-state.json`, validated by
  `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
- **Planner checkpoint schema** (A5) for
  `artifacts/orchestration/parallel-planner-state.json`, validated by
  `scripts/dev_tools/validate_parallel_planner_state.py`.
- **MCP wiring** so `validate_orchestration_artifacts` accepts `parallel-orchestrator-state` and
  `parallel-planner-state` as `artifact_type` values, with full-parity TypeScript validator cores
  whose error strings are byte-identical to the Python source (epic precedent; decision 3.1-A of
  the research).
- **`.claude/rules/parallel-orchestration.md`** recording the invariants as numbered prose in the
  style of `.claude/rules/orchestrator-state.md`.
- **`route_id: parallel`** added to `config/orchestration-routing.json` and its byte-identical
  bundled mirror `extensions/drm-copilot/resources/config/orchestration-routing.json`.

This feature owns the COMPLETE schema, including `mutations[]`, `drift_events[]`, and
`conflict_edges[]` in full field shape, so the wave-4 features F6 (mutation protocol),
F7 (enforcement hooks), and F8 (drift detection) consume those structures and never add schema
fields (epic wave-4 contention rule).

Explicitly adopted decisions from the research:

- **Decision 3.1-A:** full-parity TypeScript port of both checkpoint validators (not a thin
  structural check). The parallel validators are pure structural checks with no Python reference
  formula, so the `require_model_routing` thin-check exception does not apply.
- **Decision 3.2-A:** manifest validation is a standalone Python module, not a third MCP artifact
  type. The MCP surface grows by exactly the two promised `artifact_type` values.
- **Invariant 13 strictness (research R5):** adopted as "exactly one" — every non-withdrawn,
  non-terminal item appears in exactly one current-generation cohort. This follows the §8.1
  pinning model (recoloring is a pure function over the unstarted subgraph, implying full
  coverage). If F4 finds partial colorings legitimate mid-mutation, F4 must raise the divergence
  at its spec review.

## Schema Definitions

### S1. Manifest — `docs/features/parallel/<slug>/parallel.md` frontmatter (§11)

| Field | Type | Required | Default | Constraint |
| --- | --- | --- | --- | --- |
| `parallel` | string | required | — | non-empty slug |
| `mode` | string | optional | `closed` | enum `closed \| open` |
| `max_concurrency` | int | optional | `4` | integer, `1 <= n <= 8` (A7) |
| `created_at` | string | required | — | non-empty ISO-8601 text |
| `items` | list | required | — | may be empty at authoring time; each entry an object |
| `items[].issue_num` | int | required | — | positive integer; unique across items (primary key, A4) |
| `items[].feature_folder` | string | required | — | non-empty resolvable-hint basename |
| `items[].kind` | string | required | — | enum `feature \| bug` |
| `items[].state` | string | required | — | item-state enum (S4) |
| `items[].blast_radius` | object | required | — | shape below (A1) |
| `items[].blast_radius.paths` | list[str] | required | — | list of non-empty glob/path strings |
| `items[].blast_radius.modules` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.shared_surfaces` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.contracts` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.source` | string | required | — | enum `derived \| declared \| observed` |
| `items[].blast_radius.computed_at` | string | required | — | non-empty ISO-8601 text |

Prohibited keys (explicit rejection, not mere absence): `depends_on` at any level;
`integration_branch` at top level.

### S2. Orchestrator checkpoint — `artifacts/orchestration/parallel-orchestrator-state.json` (§12)

Baseline keys (mirroring the epic baseline so existing structural hook checks can be reused
unmodified): `objective` (string), `completed_steps` (list), `next_step` (string),
`last_updated` (string). All required.

| Field | Type | Required | Constraint |
| --- | --- | --- | --- |
| `route_id` | string | required | exactly `"parallel"` |
| `parallel_slug` | string | required | non-empty |
| `parallel_manifest_path` | string | required | non-empty; expected form `docs/features/parallel/<slug>/parallel.md` |
| `parallel_status_doc_path` | string | required | non-empty; expected form `docs/features/parallel/<slug>/parallel-status.md` |
| `mode` | string | required | enum `closed \| open` (explicit in the checkpoint; the manifest default has been resolved by write time) |
| `max_concurrency` | int | required | integer `1..8` (A7) |
| `current_cohort` | int | required | `>= 0` |
| `recolor_generation` | int | required | `>= 0` |
| `cohorts` | list | required | entries `{ index: int >= 0, generation: int >= 0, item_keys: [int...] }` (A3) |
| `items` | list | required | entries per table below |
| `conflict_edges` | list | required | entries per S7 |
| `mutations` | list | required (may be empty) | entries per S5 |
| `drift_events` | list | required (may be empty) | entries per S6 |
| `delegation_receipts` | list | optional | list when present (loose receipt shape, matching `_orchestrator_state_routing._list_receipts` tolerance) |
| `skill_receipts` | list | optional | list when present |
| `mcp_call_receipts` | list | optional | list when present |

`items[]` entries:

| Field | Type | Required | Constraint |
| --- | --- | --- | --- |
| `issue_num` | int | required | positive; unique (primary key) |
| `feature_folder` | string | required | non-empty |
| `state` | string | required | item-state enum (S4) |
| `blast_radius` | object | required | S1 shape (A1) |
| `worktree_path` | string or null | optional | non-empty when string |
| `branch_name` | string or null | optional | non-empty when string |
| `pr_number` | int or null | optional | positive when int |
| `pr_url` | string or null | optional | non-empty when string |
| `merge_status` | string | optional | merge-status enum (S4); treated as `not_started` when absent |
| `merge_commit_sha` | string or null | optional | non-empty when string |
| `worktree_created_at`, `started_at`, `merged_at`, `worktree_removed_at` | string or null | optional | lifecycle timestamps; non-empty when string |

### S3. Planner checkpoint — `artifacts/orchestration/parallel-planner-state.json` (A5)

Required top-level keys: `objective`, `parallel_slug`, `parallel_manifest_path`, `mode`,
`max_concurrency`, `items`, `cohorts`, `conflict_edges`, `recolor_generation`,
`completed_steps`, `next_step`, `last_updated`. Optional: `kickoff_prompt_path` (string;
readiness-gated, invariant P9).

Required per-item keys: `issue_num`, `feature_folder`, `kind`, `state`, `blast_radius`,
`preparation_status`, `research_path`, `plan_path`, `preflight_status`. Optional per-item key:
`complexity_band`, validated against `C1..C4` when present (mirroring the epic planner).

Readiness sentinel: `next_step == "PARALLEL_EXECUTION_READY"` under the ready gate (mirror of
`EPIC_EXECUTION_READY`). No `epic_worthiness` analogue is carried: the parallel surface has no
worthiness verdict in the design; scale assessment happens before `/parallel-plan` is invoked.

Deliberately excluded from F3 (left to F4): deep readiness-integrity machinery
(`epic_planner_readiness.py`-style git integrity, launch-evidence binding, kickoff-contract
cross-checks). F3's `require_ready_for_execution` gate is structural only (invariants P6–P9);
F4 may layer repository-aware checks behind an additional keyword without changing the schema.

### S4. Enums (all owned by F3; F6/F7/F8 consume, never extend)

- `mode`: `closed | open` (default `closed`) — §3, §8.7.
- Item `state`: `proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked` — §8.2, §11.
- Per-item `merge_status`: `not_started | worktree_created | pr_open | ci_green | merged | worktree_removed | blocked_drift | blocked_ci_loop_limit` — §12.
- `blast_radius.source`: `derived | declared | observed` — §5.2.
- `items[].kind`: `feature | bug` — §11.
- `conflict_edges[].reason`: `path_overlap | module_overlap | shared_surface_overlap | contract_dependency` — one value per disjunct of the §5.4 relation (A2). One edge per pair, carrying the first matching disjunct in the order above, keeps recomputation deterministic.
- `mutations[].op`: `add | remove | close | requeue` — §8.6.
- `mutations[].disposition`: `detach | abandon | null` — §8.4.
- `drift_events[].action`: `raised_blocking_finding | halted_later_started_item` — A8. Recording rule (restated in the rule file): one event per drift occurrence carrying the strongest action taken (`halted_later_started_item` subsumes the finding).

### S5. `mutations[]` entry (§8.6)

`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`

| Field | Type | Constraint |
| --- | --- | --- |
| `op` | string | enum S4 |
| `item_key` | int or null | must resolve to an `items[].issue_num` for `add`/`remove`/`requeue`; must be null for `close` (a run-level operation) |
| `at` | string | non-empty ISO-8601 text |
| `prior_state` | string or null | item-state enum member or null; must be null for `add` and `close` |
| `new_state` | string or null | item-state enum member or null; must be null for `close` |
| `disposition` | string or null | must be null unless `op == "remove"`; must be exactly `detach` or `abandon` when `op == "remove"` and `prior_state == "in_flight"` (accepted in-flight-removal decision, §3/§8.4) |
| `recolor_generation` | int | `>= 0` and `<=` the top-level `recolor_generation` |

Transition legality (which state may follow which) is F6 behavior, not F3 schema; F3 validates
shape, enum membership, and the null-rules above only.

### S6. `drift_events[]` entry (§7)

`{ item_key, declared, observed, escaped_paths, at, action }`

| Field | Type | Constraint |
| --- | --- | --- |
| `item_key` | int | must resolve to an `items[].issue_num` |
| `declared` | list[str] | the declared `blast_radius.paths` at detection time; list of non-empty strings |
| `observed` | list[str] | the observed diff path set; list of non-empty strings |
| `escaped_paths` | list[str] | non-empty list of non-empty strings (an event with zero escaped paths is not a drift event) |
| `at` | string | non-empty ISO-8601 text |
| `action` | string | enum S4 (A8) |

### S7. `conflict_edges[]` entry (§12)

`{ a: int, b: int, reason: enum }` — `a` and `b` must resolve to distinct `items[].issue_num`
values; normalization `a < b` (numeric) so recomputation is deterministic and edge identity is
canonical; duplicate `(a, b)` pairs are malformed.

### S8. Epic-schema fields that MUST be omitted (no integration branch, §4)

There is no integration branch for a parallel run: each item PRs to `main` independently. The
schema carries no integration-branch or final-integration-PR fields. Dispositions of every
relevant epic field:

| Epic field | Disposition in parallel schema |
| --- | --- |
| `integration_branch` (top level) | OMITTED — no integration branch (§4); its presence is a prohibited-key violation |
| `epic_merge_pr` / `epic_merge_pr.merge_commit_sha` | OMITTED — no final integration PR; the completion gate checks per-item terminal states instead |
| `features[].depends_on` | OMITTED everywhere — ordering is derived from blast-radius overlap (§4, §11); presence is a prohibited-key violation |
| `waves[]`, `features[].wave_number`, `current_wave` | REPLACED by `cohorts[]` / `current_cohort` / `recolor_generation` |
| `max_parallel_features` | REPLACED by `max_concurrency` |
| `epic_feature_folder` | REPLACED by `parallel_slug` (+ `parallel_manifest_path`, `parallel_status_doc_path`) |
| merge-status values `merge_conflict`, `blocked_conflict_loop_limit` | REPLACED by `blocked_drift`, `blocked_ci_loop_limit` — the fan-in merge-conflict path does not exist; drift and per-item CI loops are the parallel failure modes |
| planner `epic_worthiness`, `NON_EPIC_RECOMMENDED` branch | OMITTED — no worthiness verdict in the parallel planner contract |

Per-item `merge_commit_sha` is retained (§12 lists it in `items[]`); only the run-level merge-PR
block is omitted.

## Validator Invariants

Error strings use the literal context-prefixed epic style with the prefixes `Parallel checkpoint`,
`Parallel planner checkpoint`, and `Parallel manifest`. Each validator returns a list of error
strings, never mutates its input, returns a single-element list for invalid JSON/YAML, and
rejects a non-object root. These invariants are carried nearly verbatim into
`.claude/rules/parallel-orchestration.md` as numbered prose.

### V-O. Orchestrator checkpoint (`validate_parallel_orchestrator_state_text`)

1. **Required keys.** The checkpoint must carry `objective`, `completed_steps`, `next_step`,
   `last_updated`, `route_id`, `parallel_slug`, `parallel_manifest_path`,
   `parallel_status_doc_path`, `mode`, `max_concurrency`, `current_cohort`,
   `recolor_generation`, `cohorts`, `items`, `conflict_edges`, `mutations`, and `drift_events`.
   One error per missing key.
2. **Route identity.** `route_id` must be exactly `'parallel'`.
3. **Mode enum.** `mode` must be `closed` or `open`.
4. **Bounded concurrency.** `max_concurrency` must be an integer from 1 through 8 (not a
   boolean).
5. **Item uniqueness and shape.** Each `items[]` entry must be an object whose `issue_num` is a
   positive integer unique across items and whose `feature_folder` is a non-empty string.
6. **Item state enum.** Each item's `state` must be one of the eight item-state values (S4).
7. **Merge-status enum.** Each item's `merge_status`, when present, must be one of the eight
   merge-status values (S4).
8. **State/merge-status consistency.** An item whose `merge_status` is `merged` or
   `worktree_removed` must have `state == 'merged'`; an item whose `merge_status` is
   `blocked_drift` or `blocked_ci_loop_limit` must have `state == 'blocked'`.
9. **Blast-radius shape.** Each item's `blast_radius` must be an object carrying `paths`,
   `modules`, `shared_surfaces`, and `contracts` as lists of non-empty strings, a `source` in
   `{derived, declared, observed}`, and a non-empty `computed_at` string.
10. **Prohibited dependency edges.** No object anywhere in the checkpoint's `items[]` (and no
    top-level key) may carry a `depends_on` key. Ordering is expressed only as blast-radius
    overlap (§4, §11).
11. **Prohibited integration-branch fields.** The checkpoint must not carry `integration_branch`
    or `epic_merge_pr` at any level. Each parallel item PRs to `main` independently (§4).
12. **Cohort shape and resolution.** Each `cohorts[]` entry must be an object with a non-negative
    integer `index`, a non-negative integer `generation` that is `<= recolor_generation`, and an
    `item_keys` list in which every entry resolves to an `items[].issue_num`.
13. **Current-generation cohort uniqueness.** Among the `cohorts[]` entries whose `generation`
    equals `recolor_generation`, `index` values must be unique and every non-withdrawn item must
    appear in exactly one such cohort's `item_keys`. An item in no current-generation cohort is
    permitted only in state `withdrawn`, `merged`, or `blocked`.
14. **Current-cohort bound.** `current_cohort` must be a non-negative integer; when any
    current-generation cohort exists, `current_cohort` must not exceed the maximum
    current-generation `index`.
15. **Conflict-edge shape.** Each `conflict_edges[]` entry must be an object whose `a` and `b`
    resolve to distinct `items[].issue_num` values with `a < b`, and whose `reason` is in the S4
    edge-reason enum. A self-edge, an unresolved endpoint, an unnormalized or duplicate pair, or
    an out-of-enum reason is a malformed edge.
16. **Mutation shape.** Each `mutations[]` entry must satisfy the S5 table: `op` in the enum;
    `item_key` resolving for `add`/`remove`/`requeue` and null for `close`; non-empty `at`;
    `prior_state`/`new_state` null or in the item-state enum, with the op-specific null rules;
    `recolor_generation` a non-negative integer `<=` the top-level `recolor_generation`.
17. **In-flight removal requires a disposition.** A `mutations[]` entry with `op == 'remove'` and
    `prior_state == 'in_flight'` must carry `disposition` exactly `'detach'` or `'abandon'`; a
    `disposition` on any other entry must be null (§3, §8.4).
18. **Drift-event shape.** Each `drift_events[]` entry must satisfy the S6 table, including a
    resolving `item_key`, list-of-string `declared`/`observed`, a non-empty `escaped_paths` list,
    a non-empty `at`, and an `action` in the enum.
19. **Receipt arrays.** `delegation_receipts`, `skill_receipts`, and `mcp_call_receipts`, when
    present, must each be a list. Per-receipt content validation follows the loose tolerance of
    the standard checkpoint validators.
20. **Completion gate (`require_complete`, closed mode).** Under `require_complete` with
    `mode == 'closed'`, every item whose `state` is not `withdrawn` must have `merge_status` in
    `{merged, worktree_removed}` (§8.7).
21. **Completion gate (`require_complete`, open mode).** Under `require_complete` with
    `mode == 'open'`, the checkpoint must additionally record a `mutations[]` entry with
    `op == 'close'` (the `/parallel-close` record, §8.5); invariant 20's per-item condition
    applies as well.

**F7 seam (explicit, not implemented here):** the retrospective cohort-ordering invariant
(`PARALLEL_COHORT_BARRIER_VIOLATION`, design §9 Layer 2) is F7's explicitly assigned addition to
this validator. The entry point must contain a clearly delimited, appendable helper-invocation
block so F7's edit is one appended helper call with no reflow of existing code (epic wave-4
contention rule).

### V-P. Planner checkpoint (`validate_parallel_planner_state_text`)

- **P1 — Required keys.** The S3 top-level key set must be present; one error per missing key.
- **P2 — Route-consistent identity.** `parallel_slug` and `parallel_manifest_path` must be
  non-empty strings; `mode` and `max_concurrency` satisfy orchestrator invariants 3 and 4.
- **P3 — Item shape.** Each `items[]` entry must carry the S3 per-item required keys;
  `issue_num` unique positive integer; `kind` in `{feature, bug}`; `state` in the item-state
  enum; `blast_radius` per orchestrator invariant 9; `complexity_band`, when present, in
  `{C1, C2, C3, C4}`. Prohibited keys per orchestrator invariants 10–11 apply.
- **P4 — Cohort and edge shape.** `cohorts[]`, `conflict_edges[]`, and `recolor_generation`
  satisfy orchestrator invariants 12–15.
- **P5 — Deterministic recoloring seam (deliberately absent).** F3 does not recompute the
  coloring. Recomputation parity against `parallel_cohort_computation.py` is F4's planner-side
  check (analogue of the epic planner's `compute_wave_numbers` cross-check). Recorded here so the
  omission is explicit.
- **P6 — Ready gate, cardinality.** Under `require_ready_for_execution`, `items` must contain at
  least two entries.
- **P7 — Ready gate, preparation.** Under `require_ready_for_execution`, each item must have
  `preparation_status == 'prepared'`, `preflight_status == 'PREFLIGHT: ALL CLEAR'`, non-empty
  `research_path` and `plan_path`, and `blast_radius.source == 'declared'` (§5.2: only the
  planner-computed radius is authoritative for scheduling).
- **P8 — Ready gate, sentinel.** Under `require_ready_for_execution`, `next_step` must be exactly
  `'PARALLEL_EXECUTION_READY'`.
- **P9 — Ready gate, kickoff path.** Under `require_ready_for_execution`, `kickoff_prompt_path`
  must be exactly `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md` (A6).

### V-M. Manifest (`validate_parallel_manifest_text`)

- **M1 — Frontmatter block.** The document must open with a `---` YAML frontmatter block
  terminated by `---`, parseable by `yaml.safe_load` into a mapping, tolerant of LF, CRLF, and CR
  line endings (precedent: commit `b845c505`).
- **M2 — Slug.** `parallel` must be a non-empty string.
- **M3 — Mode default.** `mode`, when present, must be `closed` or `open`; when absent it
  defaults to `closed` (accessor `manifest_mode(mapping)` returns the default; the validator
  emits no error for absence).
- **M4 — Concurrency default.** `max_concurrency`, when present, must be an integer from 1
  through 8; when absent it defaults to 4 (accessor `manifest_max_concurrency(mapping)`).
- **M5 — Created-at.** `created_at` must be a non-empty string.
- **M6 — Items.** `items` must be a list; each entry must satisfy the S1 item table, including
  `issue_num` uniqueness and the full `blast_radius` shape.
- **M7 — Prohibited keys.** No `depends_on` key may appear at any level and no
  `integration_branch` key at top level.

## Inputs / Outputs

- Inputs (CLI flags, files, env vars):
  - `validate_orchestration_artifacts.py parallel-orchestrator-state <path> [--require-complete]`
  - `validate_orchestration_artifacts.py parallel-planner-state <path> [--require-ready-for-execution]`
  - MCP tool `validate_orchestration_artifacts` with `artifact_type` in
    `{parallel-orchestrator-state, parallel-planner-state}`, forwarding the existing
    `requireComplete` / `requireReadyForExecution` flags (no new flag names are needed).
  - Manifest validation: library call `validate_parallel_manifest_text(text)`; no new CLI
    subcommand or MCP artifact type (decision 3.2-A).
- Outputs (artifacts, logs, telemetry):
  - Validators return `list[str]` of error strings; CLI prints errors to stderr and exits 1, or
    prints `"{artifact_type} validation passed: {path}"` and exits 0 (existing dispatcher
    behavior, unchanged).
- Config keys and defaults:
  - `config/orchestration-routing.json` `routes.parallel` (new entry; see Implementation
    Strategy). Manifest defaults: `mode: closed`, `max_concurrency: 4`.
- Versioning or backward-compatibility constraints:
  - Additive only. Existing artifact types, epic validators, and their tests are byte-unchanged.
  - Optional keys (receipt arrays, `merge_status`, `complexity_band`, `kickoff_prompt_path`
    outside the ready gate) contribute zero errors when absent.

## API / CLI Surface

New Python entry points (keyword-only opt-in flags, epic signature pattern):

- `validate_parallel_orchestrator_state_text(text: str, *, require_complete: bool = False) -> list[str]`
- `validate_parallel_planner_state_text(text: str, *, require_ready_for_execution: bool = False) -> list[str]`
- `validate_parallel_manifest_text(text: str) -> list[str]`
- `manifest_mode(mapping) -> str` (returns `"closed"` when absent)
- `manifest_max_concurrency(mapping) -> int` (returns `4` when absent)

New TypeScript entry points (byte-identical error strings to Python):

- `validateParallelOrchestratorStateText(text, options)` in
  `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
- `validateParallelPlannerStateText(text, options)` in
  `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`

Contracts and validation rules: sections "Schema Definitions" and "Validator Invariants" above.

Example invocation (expected output shape):

```
$ python scripts/dev_tools/validate_orchestration_artifacts.py parallel-orchestrator-state artifacts/orchestration/parallel-orchestrator-state.json
parallel-orchestrator-state validation passed: artifacts/orchestration/parallel-orchestrator-state.json
```

An unknown artifact type continues to fail with `"Unsupported artifact type: {type}"` on both the
Python and TypeScript surfaces.

## Data & State

- Data transformations and invariants: no data is transformed; the validators are pure functions
  from artifact text to error lists. Invariants are enumerated in "Validator Invariants".
- Caching or persistence details — **cache doctrine (§12, restated in the rule file):** the
  orchestrator checkpoint is a CACHE of durable state, not the source of truth. Every field is
  re-derivable from `git worktree list --porcelain`, `git branch`, and
  `gh pr view --json state,mergedAt,headRefOid`. No downstream feature may treat the checkpoint
  as authoritative.
- Migration or backfill requirements: none. The artifacts do not exist yet; there is no legacy
  shape to migrate.

## Constraints & Risks

- **No `depends_on` field.** Ordering is expressed as blast-radius overlap and derived by the
  scheduler (design sections 4 and 11). Dependency edges must not be added; presence is an
  explicit rejection (orchestrator invariant 10, planner P3, manifest M7).
- **`issue_num` is the primary key**, matching the epic manifest convention so the identifier does
  not drift when a feature moves from `active/` to `completed/`.
- **No integration branch.** Each parallel item PRs to `main` independently (design section 4).
  The schema carries no integration-branch or final-integration-PR fields; the S8 table records
  every omitted epic field, and `integration_branch` / `epic_merge_pr` presence is an explicit
  rejection (invariant 11).
- **No foreign JSON Schema.** Per `.claude/rules/orchestrator-state.md`, this repository enforces
  checkpoint invariants through Python validator logic and prose rules, not imported schema
  files. No JSON Schema file is authored or imported for either checkpoint.
- **Additive only.** The existing epic validators (`validate_epic_orchestrator_state.py`,
  `validate_epic_planner_state.py`), their helper modules, TS cores, and tests must not be
  modified or refactored.
- **The checkpoint is a cache**, not the source of truth (see Data & State).
- **Upstream coupling.** See "Upstream Assumptions (A1–A8)". The design sections are the contract
  until F1/F2 specs land; reconciliation happens at spec review.
- **File-size limit.** No production or test file may exceed 500 lines; the decomposition in
  Implementation Strategy enforces this (`_parallel_state_common.py`,
  `_parallel_state_structures.py`, three-way Python test split).
- **Coverage.** Line coverage >= 85% and branch coverage >= 75% for every new module.
- **Test placement.** Python tests under `tests/scripts/dev_tools/` mirroring production; the
  extension's Jest tests under `extensions/drm-copilot/test/` (the package's established mirror
  tree). Colocation is prohibited. No temporary files in tests.
- **R1 — F1/F2 shape drift.** Mitigated by the assumptions register (A1–A4).
- **R2 — TS parity cost.** ~1,160 TS production lines plus tests. Sequence Python first
  (authoritative), then port with byte-identical strings so the Python tests serve as the parity
  oracle.
- **R3 — `quality-tiers.yml` absence.** If `quality-tiers.yml` exists at execution time (F1 may
  create it in wave 0), classify the new modules there; otherwise record the observed state.
- **R4 — F7 seam.** The orchestrator validator must expose the delimited insertion point
  described under V-O.
- **R5 — Invariant 13 strictness.** Resolved: adopted as "exactly one" per the §8.1 pinning
  model (see Behavior).

## Implementation Strategy

- Implementation scope (what changes, not sequencing):

New Python production files (all under `scripts/dev_tools/`; estimates include mandatory
docstring/comment density; hard cap 500 lines each):

| File | Content | Est. lines |
| --- | --- | --- |
| `_parallel_state_common.py` | All S4 enums as module constants (`VALID_ITEM_STATES`, `VALID_MERGE_STATUS`, `VALID_SOURCES`, `VALID_KINDS`, `VALID_MODES`, `VALID_MUTATION_OPS`, `VALID_DISPOSITIONS`, `VALID_EDGE_REASONS`, `VALID_DRIFT_ACTIONS`); `blast_radius` block validator; item-shape validator (uniqueness, state/merge-status enums + consistency); prohibited-key scanner (`depends_on`, `integration_branch`, `epic_merge_pr`); shared string/int helpers | ~300 |
| `_parallel_state_structures.py` | `cohorts[]` (+ current-generation uniqueness/coverage), `conflict_edges[]`, `mutations[]`, `drift_events[]`, receipt-array validators | ~330 |
| `validate_parallel_orchestrator_state.py` | Entry point; required keys; route/mode/concurrency; helper orchestration; mode-dependent completion gate; delimited appendable block for F7's Layer-2 invariant | ~300 |
| `parallel_manifest_contract.py` | Frontmatter extraction (CR/LF/CRLF tolerant), `validate_parallel_manifest_text(text)`, default accessors; reuses `_parallel_state_common` item validators | ~260 |
| `validate_parallel_planner_state.py` | Entry point; P1–P4 structural checks; P6–P9 ready gate | ~300 |

New TypeScript production files (under `extensions/drm-copilot/src/lib/validate/`):

| File | Content | Est. lines |
| --- | --- | --- |
| `parallel-state-shared.ts` | Enum constants + shared item/blast-radius/prohibited-key validators; error strings byte-identical to `_parallel_state_common.py` | ~280 |
| `parallel-state-structures.ts` | Cohorts/conflict-edges/mutations/drift-events validators; parity with `_parallel_state_structures.py` | ~320 |
| `parallel-orchestrator-state-core.ts` | `validateParallelOrchestratorStateText(text, options)` | ~280 |
| `parallel-planner-state-core.ts` | `validateParallelPlannerStateText(text, options)` | ~280 |

New documentation: `.claude/rules/parallel-orchestration.md` carrying the V-O/V-P/V-M invariants
as numbered prose; the Foreign Schema Warning restated for the parallel artifacts; the
cache-not-source-of-truth doctrine; the S8 omitted-epic-fields table; the A7 concurrency bound;
the A8 drift recording rule; and the enum-ownership statement (F6/F7/F8 consume, never extend).
Markdown, exempt from the line cap.

Modified files (all seven edit points; every change additive; epic validators untouched):

| File | Change |
| --- | --- |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | Two new subparsers (`parallel-orchestrator-state` with `--require-complete`; `parallel-planner-state` with `--require-ready-for-execution`) + two dispatch branches + two imports (~+45 lines on 357 — within cap) |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | Two new `switch` cases + imports + option threading; existing `requireComplete` / `requireReadyForExecution` flags reused (~+45 lines on 257) |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | Add both values to `VALID_ARTIFACT_TYPES` (~line 427) |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | Add both values to the `artifact_type` enum (~line 403); update `require_complete` / `require_ready_for_execution` descriptions to name the parallel types |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | Identical enum + description edits (~line 342); alignment asserted by a new definitions test |
| `config/orchestration-routing.json` | Add the `parallel` route entry (below) |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | Byte-identical mirror of the same edit (enforced by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`) |

Files verified as requiring no change: `mcp-tools.ts`,
`mcp-handlers/template-validation-handlers.ts`, `lib/validate/validate-orchestration-service-call.ts`,
`repo-automation-tool-names.ts`, `mcp-server.ts`, all `validate_epic_*` / `_epic_*` Python
modules, all `epic-*` TS modules.

Proposed `parallel` route entry (adapted from `epic` with the structural deltas applied):

```json
"parallel": {
  "description": "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch.",
  "requires_pr_gate": false,
  "required_agents": ["orchestrator", "pr-author"],
  "required_skills": [
    "parallel-orchestrate",
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "evidence-and-timestamp-conventions",
    "pr-context-artifacts",
    "pr-base-branch-merge-base"
  ],
  "required_mcp_tools": ["collect_pr_context", "validate_orchestration_artifacts"]
}
```

Route-entry notes (verified in the research): `requires_pr_gate: false` because there is no
run-level PR to gate (§4) — each child's own `large`-route checkpoint enforces its per-item PR
gate. `validate_route_membership` checks key membership only; no test asserts a closed route-id
set, so the addition is additive-safe. `required_skills` names `parallel-orchestrate` before that
skill exists (F5); this is data, not a file reference — the list is PROVISIONAL and F5 must
confirm or amend it. `MANDATORY_ROUTE_PHASES` needs no `parallel` entry.

Test surface (Python, Pytest, `tests/scripts/dev_tools/`):

| Test file | Covers | Est. lines |
| --- | --- | --- |
| `test_validate_parallel_orchestrator_state.py` | Builder `build_valid_parallel_state()`; invariants 1–11, 14, 19; invalid-JSON / non-object root; absent-optional-receipts backward-compat case | ~450 |
| `test_validate_parallel_orchestrator_state_structures.py` | Invariants 12–13, 15–18 (cohorts, edges, mutations incl. disposition rule, drift events); shares the builder via sibling import | ~430 |
| `test_validate_parallel_orchestrator_state_completion.py` | Invariants 20–21 (closed/open completion, close-mutation requirement); withdrawn-item exemption | ~200 |
| `test_validate_parallel_planner_state.py` | P1–P4, P6–P9; ready-gate positive and per-field negative cases | ~400 |
| `test_parallel_manifest_contract.py` | M1–M7; CRLF/CR tolerance; `mode` / `max_concurrency` default accessors; `depends_on` rejection | ~350 |
| `test_validate_orchestration_artifacts_parallel_dispatch.py` | New CLI subparsers and dispatch via monkeypatched `_read_text` + `validator.main([...])` exit codes; a NEW file so the existing epic dispatch test is untouched | ~180 |

Test surface (TypeScript, Jest, `extensions/drm-copilot/test/`):

| Test file | Covers |
| --- | --- |
| `lib/validate/parallel-orchestrator-state-core.test.ts` | TS mirror of invariants 1–21; error strings asserted byte-identical to Python |
| `lib/validate/parallel-planner-state-core.test.ts` | TS mirror of P1–P9 |
| `mcp-tool-inputs-parallel-validation.test.ts` | `it.each` over both new artifact types; flag forwarding |
| `mcp-parallel-validation-definitions.test.ts` | Both definition surfaces carry both new enum values (`expect.arrayContaining`) |
| `mcp-server-parallel-validation.test.ts` | In-memory MCP round trip with mocked `RepoAutomationService` (`InMemoryTransport.createLinkedPair()`) |

Per-invariant coverage discipline: valid case, each malformed case, and — where a key is
optional — the absent-key case. Enum-membership tests use `pytest.mark.parametrize` (Python) and
`it.each` (TypeScript). No temp files; state built as dicts and serialized with `json.dumps`. If
the new modules are classified T1/T2 in `quality-tiers.yml` at execution time, add at least one
`hypothesis` property per pure helper (e.g., prohibited-key scanner over arbitrary nested dicts;
edge-normalization over arbitrary int pairs).

Epic-unchanged evidence: the acceptance criterion "existing epic validators are unmodified" is
evidenced by the feature-review diff (no hunks under `validate_epic_*`, `_epic_*`,
`epic-*-core.ts`, or their tests), recorded as a review checklist item, not a brittle checksum
test. One explicit unknown-artifact-type case is added in the new dispatch tests on both sides.

- New classes/functions/commands to add or update: listed above (Python and TypeScript entry
  points, CLI subparsers, MCP enum values, route entry).
- Dependency changes: none. PyYAML is already a declared dependency (`pyproject.toml`); no new
  Python or TypeScript runtime dependencies.
- Logging/telemetry additions: none. Validators are pure functions; the CLI dispatcher's existing
  stderr/exit-code behavior is reused unchanged.
- Rollout plan: additive-only change; no feature flag needed. Nothing consumes the new artifact
  types until F4/F5 land. Sequencing guidance for the atomic plan: Python validators and tests
  first (authoritative), then the TS port with byte-identical strings, then CLI/MCP wiring, then
  config and rule file.

## Acceptance Criteria

- [ ] `scripts/dev_tools/parallel_manifest_contract.py` exists, exposes `validate_parallel_manifest_text(text) -> list[str]` plus accessors `manifest_mode(...)` (returning `closed` when `mode` is absent) and `manifest_max_concurrency(...)` (returning `4` when `max_concurrency` is absent), and enforces invariants M1–M7 including LF/CRLF/CR frontmatter tolerance.
- [ ] `scripts/dev_tools/validate_parallel_orchestrator_state.py` exists, exposes `validate_parallel_orchestrator_state_text(text, *, require_complete=False) -> list[str]`, and enforces invariants 1–19 unconditionally and 20–21 only under `require_complete`.
- [ ] The orchestrator validator entry point contains a clearly delimited, appendable helper-invocation block documented as the F7 insertion seam for the Layer-2 cohort-ordering invariant.
- [ ] `scripts/dev_tools/validate_parallel_planner_state.py` exists, exposes `validate_parallel_planner_state_text(text, *, require_ready_for_execution=False) -> list[str]`, and enforces P1–P4 unconditionally and P6–P9 only under `require_ready_for_execution`, including the `PARALLEL_EXECUTION_READY` sentinel and the `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md` kickoff path.
- [ ] Shared helper modules `scripts/dev_tools/_parallel_state_common.py` and `scripts/dev_tools/_parallel_state_structures.py` exist, hold the S4 enum constants and shared validators, and every new production and test file is at or under 500 lines.
- [ ] All S4 enums are enforced with exactly the specified member sets: item `state` (8 values), `merge_status` (8 values), `mode` (2), `kind` (2), `blast_radius.source` (3), `conflict_edges[].reason` (4), `mutations[].op` (4), `mutations[].disposition` (`detach`/`abandon`/null), `drift_events[].action` (2).
- [ ] `mutations[]` entries are validated to the full S5 shape, including the op-specific null rules for `item_key` / `prior_state` / `new_state`, the in-flight-removal disposition rule (invariant 17), and `recolor_generation <=` the top-level value.
- [ ] `drift_events[]` entries are validated to the full S6 shape, including a resolving `item_key`, list-of-string `declared` / `observed`, a non-empty `escaped_paths` list, and the A8 action enum.
- [ ] `conflict_edges[]` entries are validated to the full S7 shape: distinct resolving endpoints, `a < b` normalization, no duplicate pairs, reason enum membership.
- [ ] Both validators reject a `depends_on` key at any level and reject `integration_branch` / `epic_merge_pr`; the manifest validator rejects `depends_on` at any level and `integration_branch` at top level; negative tests cover each rejection.
- [ ] `scripts/dev_tools/validate_orchestration_artifacts.py` registers subparsers `parallel-orchestrator-state` (with `--require-complete`) and `parallel-planner-state` (with `--require-ready-for-execution`), dispatches to the new validators, and unknown artifact types still fail with `Unsupported artifact type: {type}`.
- [ ] TypeScript cores `parallel-orchestrator-state-core.ts` and `parallel-planner-state-core.ts` (plus `parallel-state-shared.ts` and `parallel-state-structures.ts`) exist under `extensions/drm-copilot/src/lib/validate/` with error strings byte-identical to the Python source, and `orchestration-artifacts.ts` dispatches both new artifact types to them.
- [ ] `mcp-tool-inputs.ts` `VALID_ARTIFACT_TYPES` and both definition surfaces (`mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`) accept `parallel-orchestrator-state` and `parallel-planner-state`, with flag descriptions updated to name the parallel types; a definitions test asserts both surfaces stay aligned.
- [ ] `config/orchestration-routing.json` carries the `parallel` route entry with `requires_pr_gate: false`, and `extensions/drm-copilot/resources/config/orchestration-routing.json` is its byte-identical mirror (`test_orchestration_routing_config_parity.py` passes).
- [ ] `.claude/rules/parallel-orchestration.md` exists and records: the V-O/V-P/V-M invariants as numbered prose, the Foreign Schema Warning restated for the parallel artifacts, the cache-not-source-of-truth doctrine, the S8 omitted-epic-fields table, the A7 concurrency bound (1..8), the A8 drift recording rule, and the enum-ownership statement (F6/F7/F8 consume, never extend).
- [ ] Python tests exist at the six planned files under `tests/scripts/dev_tools/` and TypeScript tests at the five planned files under `extensions/drm-copilot/test/`, covering each invariant's valid case, each malformed case, and the absent-optional-key backward-compatible case.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new Python and TypeScript module.
- [ ] The feature-review diff contains no hunks under `scripts/dev_tools/validate_epic_*`, `scripts/dev_tools/_epic_*`, `extensions/drm-copilot/src/lib/validate/epic-*`, or their existing tests (epic validators unmodified).
- [ ] The full seven-stage toolchain loop passes in a single pass for both the Python and TypeScript surfaces.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage for each checkpoint invariant: valid case, each malformed case, and the absent-key backward-compatible case.
- [ ] Unit coverage for each manifest invariant, including the `mode` and `max_concurrency` defaults.
- [ ] Enum-membership coverage for item `state`, per-item `merge_status`, `blast_radius.source`, and `mutations[].op`.
- [ ] Negative coverage asserting that a `depends_on` field is rejected or absent from the schema surface.
- [ ] Coverage that `conflict_edges[]`, `mutations[]`, and `drift_events[]` validate their full field shapes.
- [ ] MCP dispatch coverage that `parallel-orchestrator-state` and `parallel-planner-state` route to the correct validators and that unknown `artifact_type` values still fail.
- [ ] A regression assertion that the existing epic validators and their tests are unchanged.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module.
