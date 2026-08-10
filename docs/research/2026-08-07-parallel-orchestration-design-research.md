# Parallel Orchestration Design (`parallel-plan` / `parallel-run`)

Date: 2026-08-07
Status: Design accepted; build not started.
Origin: `/orchestrate` invocation, scale-assessed as epic-scale and routed to `/epic-plan`.

## 1. Objective

Provide a mechanism, parallel in shape to `epic-plan` / `epic-run`, that executes multiple
**independent** bugs and features concurrently under one central orchestration with child
orchestrations on isolated worktrees. Unlike an epic, the items share no theme and no common
deliverable. Concurrency is decided by **computed blast-radius contention**, not by a
human-authored dependency graph, and the item set is **mutable mid-execution**.

## 2. Scale Verdict

Epic-scale. The decomposition yields at least seven independently mergeable features (§10) and
the combined scope exceeds a single large-path change budget. The build is handed to
`/epic-plan`; this document is its input.

## 3. Accepted Decisions

| Decision | Value |
| --- | --- |
| Name | `parallel` |
| Lifetime | Support both `closed` and `open`; default `closed` |
| Blast-radius source | Planner-computed, validated against the approved atomic plan |
| In-flight removal | Reject without an explicit disposition; caller must name `detach` or `abandon` |

Resulting surface names: skills `parallel-plan`, `parallel-run`, `parallel-orchestrate`; agents
`parallel-planner`, `parallel-orchestrator`; home `docs/features/parallel/<slug>/`; manifest
`parallel.md`; generated projection `parallel-status.md`; route `route_id: parallel`; checkpoints
`artifacts/orchestration/parallel-planner-state.json` and
`artifacts/orchestration/parallel-orchestrator-state.json`.

## 4. Structural Deltas from Epic

| Dimension | Epic | Parallel |
| --- | --- | --- |
| Ordering source | Human-authored `depends_on` DAG | Computed conflict relation over blast radii |
| Scheduling algorithm | Longest-path layering (directed) | Graph coloring (undirected) |
| Scheduling unit | Wave | Cohort |
| Merge target | Shared `epic/<slug>-integration`, then one integration-to-`main` PR | Each item PRs to `main` independently |
| Membership | Frozen at manifest-authoring time | Mutable mid-execution |
| Completion | All features merged plus integration PR merged | Mode-dependent (§8) |

Dropping the integration branch removes `enforce-epic-merge-gate.ps1`, the final integration PR,
and the fan-in merge-conflict path. It is also what makes open-ended membership coherent: there is
no fan-in point that a late arrival could invalidate.

The manifest carries **no `depends_on` field**. Ordering that a human would express as a
dependency is expressed instead as blast-radius overlap, which the scheduler derives.

## 5. Blast Radius

### 5.1 Definition

The blast radius of an item is the set of repository resources the item is predicted to modify,
recorded at four levels:

1. `paths` — file and glob set. Primary signal.
2. `modules` — projects the paths map to, via `quality-tiers.yml`.
3. `shared_surfaces` — high-contention artifacts many items touch: `config/orchestration-routing.json`,
   `.claude/settings.json`, lockfiles, `quality-tiers.yml`, shared validators.
4. `contracts` — exported symbols, schemas, and CLI surfaces changed. Catches items that break each
   other without file overlap.

### 5.2 Confidence sources

| Source | When | Use |
| --- | --- | --- |
| `derived` | From issue plus research, before planning | Provisional cohort seeding only |
| `declared` | Planner-computed from the approved atomic plan | Authoritative for scheduling |
| `observed` | From the actual diff, during execution | Drift correction (§7) |

### 5.3 Computation and validation contract

Atomic plans currently carry **no machine-parseable per-task file list**
(verified against `.claude/skills/atomic-plan-contract/SKILL.md`). Per the accepted decision, the
atomic-plan contract is left unchanged and `parallel-planner` derives the radius, then validates it:

- **Derivation.** Parse concrete repository paths from the approved plan's task bodies and the
  feature `spec.md`; add the feature folder itself; map paths to modules via `quality-tiers.yml`;
  intersect against the configured shared-surface list; extract contract identifiers from the spec's
  interface sections.
- **V1 — Coverage (Blocking).** Every concrete repository path mentioned in the plan must be
  subsumed by `blast_radius.paths`. An uncovered path fails validation. This is the primary safety
  rule: under-reporting the radius is what breaks the concurrency guarantee.
- **V2 — Shared-surface enumeration (Blocking).** A shared surface touched by the item must appear
  explicitly in `shared_surfaces`; glob coverage alone is insufficient.
- **V3 — Over-breadth warning (Advisory).** A radius covering more than a configured fraction of
  tracked files is reported, not rejected. An over-broad radius is safe but serializes the batch.

Derivation is heuristic and can under-report. V1 bounds that risk at plan time; §7 bounds it at
execution time. The pair is what makes the accepted decision viable without changing the shared
plan contract.

### 5.4 Contention relation

```
conflicts(a, b) = path_overlap(a, b)
               OR module_overlap(a, b)
               OR shared_surface_overlap(a, b)
               OR contract_dependency(a, b)
```

Fails closed. A shared surface creates a conflict by default; v1 does not assume that two items
editing disjoint keys of the same JSON map are safe. Key-level partitioning of shared surfaces is a
deliberate future refinement, not part of the initial build.

## 6. Cohort Scheduling

Build an undirected conflict graph `G`: vertices are items, edges are `conflicts`. A set of items
may execute concurrently if and only if it is an **independent set** in `G`. Scheduling is therefore
partitioning the vertices into a sequence of independent sets, which is graph coloring. Each color
class is a **cohort**.

Use **deterministic greedy coloring in Welsh-Powell order**: vertices sorted by descending degree,
ties broken by ascending item key. Optimality is not the objective; determinism and explainability
are, so that the scheduler can carry a tested reference implementation with cross-language parity in
the same manner as `epic_wave_computation.py` and the model-routing formulas.

Because items within a cohort are non-conflicting by construction, they may branch from the same
`main` tip and merge in any order. Cohort `N+1` branches from `main` only after every cohort-`N`
item has merged. This is a direct adaptation of the two-layer epic wave barrier (§9).

`max_concurrency` caps fan-out independently of cohort size: a cohort of twelve executes at
`max_concurrency` at a time, slots filled in ascending item-key order.

## 7. Radius Drift

An in-flight item whose actual diff escapes its declared radius invalidates the concurrency
guarantee for every item running beside it. This is the dominant failure mode of the whole design
and the compensating control for heuristic derivation (§5.3).

Procedure, evaluated at each child's pre-review commit:

1. Compare `git diff --name-only` against the declared `blast_radius.paths`.
2. On escape, record a `drift_events[]` entry and raise a synthetic Blocking finding in the child's
   own `remediation-inputs.<timestamp>.md`.
3. Quiesce: suspend admission of new items into the current cohort.
4. Recompute conflicts using the observed radius.
5. If the escape newly conflicts with a concurrently in-flight item, halt the **later-started** item
   of the pair, set its state to `blocked_drift`, and requeue it into a future cohort.
6. The child's existing R1-R5 remediation loop processes the finding unmodified.

Halting the later-started item, rather than the drifting item, is deliberate: the drifting item's
work is already broader than planned and is more expensive to unwind.

## 8. Dynamic Membership

### 8.1 Pinning invariant

**In-flight items are pinned; scheduling is recomputed only over the not-yet-started subgraph.**
Recoloring stays a pure function of `(remaining subgraph, pinned set)`, which preserves determinism
under mutation and prevents a running item from being rescheduled underneath itself.

### 8.2 Item lifecycle

```
proposed -> admitted -> prepared -> scheduled -> in_flight -> merged
                                                     |
                                          withdrawn / blocked
```

### 8.3 Add (`/parallel-add <issue|potential-entry>`)

1. Item enters `proposed`.
2. Prepare it via a preparation-mode child `Agent(orchestrator)` run — promotion, research,
   `spec.md`, `user-story.md`, atomic plan, preflight clearance — reusing the existing
   `route_id: preparation` contract unchanged. This yields the declared radius.
3. Compute conflict edges against all items, including in-flight ones.
4. **Admission decision.** No conflict with any in-flight item, admit into the current cohort.
   Otherwise defer to a future cohort and recolor the unstarted subgraph.

### 8.4 Remove (`/parallel-remove <item> [--disposition detach|abandon]`)

| Item state | Behavior |
| --- | --- |
| `proposed`, `admitted`, `prepared`, `scheduled` | Mark `withdrawn`, drop the vertex, recolor the unstarted subgraph |
| `in_flight` | **Reject** unless `--disposition` is supplied (accepted decision) |
| `in_flight` with `--disposition detach` | Let the item finish and merge on its own; stop tracking it in the parallel run |
| `in_flight` with `--disposition abandon` | Close the PR, remove the worktree, mark `withdrawn`. Destructive; hook-gated |
| `merged` | Reject; the change is already in `main` |

### 8.5 Close (`/parallel-close <slug>`)

Terminates an `open`-mode run. Rejected while any item is `in_flight`.

### 8.6 Mutation log

Every add, remove, close, and drift-induced requeue appends to `mutations[]` with
`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`.
`recolor_generation` increments on each recompute so that a cohort table which changes is traceable
rather than silently rewritten. This is the auditability requirement that mutable membership
introduces and that epics do not have.

### 8.7 Completion semantics by mode

- `closed` (default) — item set fixed at plan time; mid-execution mutation still permitted; the
  completion gate fires when every non-withdrawn item is `merged` or `worktree_removed`.
- `open` — standing queue; no automatic completion; terminates only via `/parallel-close`.

Defaulting to `closed` keeps a completion gate that can actually fire, consistent with the
repository's `require_complete` validator pattern.

## 9. Enforcement

Mirrors the proven two-layer epic design; no single `PreToolUse` hook can validate a batch of
concurrent `Agent` calls, because hooks fire per call with no cross-call state visibility.

- **Layer 1, per-call deterrent.** `.claude/hooks/enforce-parallel-cohort-barrier.ps1` on the `Agent`
  matcher. Fires when `subagent_type == "orchestrator"` and the prompt carries the marker
  `Parallel mode: true`; resolves the target item, reads the parallel checkpoint, and denies with
  `PARALLEL_COHORT_BARRIER_BLOCKED` unless every conflicting item in a prior cohort is `merged` or
  `worktree_removed`.
- **Layer 2, retrospective backstop.** A cohort-ordering invariant inside
  `validate_parallel_orchestrator_state_text`, enforced at `parallel-orchestrator` `SubagentStop`
  time, appending `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`.
- **Drift gate.** Blocks a child's transition to review while an unresolved `drift_events[]` entry
  exists for that item.
- **Worktree removal gate.** `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, adapted
  near-verbatim from `enforce-epic-worktree-removal-gate.ps1`.
- **Invocation origin.** Extend `.claude/hooks/enforce-epic-invocation-origin.ps1` to deny
  `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` calls originating from `orchestrator`.
- **Abandon gate.** Denies `--disposition abandon` without an explicit confirmation marker.

## 10. Suggested Build Decomposition

`/epic-plan` performs the authoritative decomposition. This is the starting proposal.

| ID | Feature | Depends on |
| --- | --- | --- |
| F1 | Blast-radius library: `scripts/dev_tools/compute_blast_radius.py`, `.claude/lib/blast-radius/BlastRadius.psm1`, config truth table, cross-language parity test, contention relation | — |
| F2 | Cohort scheduler: `scripts/dev_tools/parallel_cohort_computation.py` (Welsh-Powell), parity test | — |
| F3 | Manifest and checkpoint schema, `validate_parallel_orchestrator_state.py`, `validate_parallel_planner_state.py`, MCP `artifact_type` wiring, `.claude/rules/parallel-orchestration.md`, `route_id: parallel` | F1, F2 |
| F4 | `parallel-planner` agent and `parallel-plan` skill: preparation fan-out, radius computation and V1-V3 validation, cohort seeding, kickoff artifact | F1, F2, F3 |
| F5 | `parallel-orchestrator` agent, `parallel-orchestrate` and `parallel-run` skills: cohort scheduling, fan-out, per-item merge to `main`, `parallel-status.md` projection | F3, F4 |
| F6 | Mutation protocol: `/parallel-add`, `/parallel-remove`, `/parallel-close`, admission control, pinning invariant, mutation log | F5 |
| F7 | Enforcement hooks (§9) and drift detection (§7) | F3, F5 |

Reusable near-verbatim from the epic surfaces: the preparation-mode child contract, the
merge-on-green S9 extension, the worktree-removal gate, the invocation-origin gate, and the R1-R5
remediation loop.

## 11. Manifest Schema

`docs/features/parallel/<slug>/parallel.md` frontmatter:

```yaml
---
parallel: <slug>
mode: closed | open          # default closed
max_concurrency: <int>       # default 4
created_at: <iso8601>
items:
  - issue_num: <int>
    feature_folder: <resolvable-hint-basename>
    kind: feature | bug
    state: proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked
    blast_radius:
      paths: [<glob>, ...]
      modules: [<project>, ...]
      shared_surfaces: [<path>, ...]
      contracts: [<identifier>, ...]
      source: derived | declared | observed
      computed_at: <iso8601>
---
```

`issue_num` is the primary key, matching the epic manifest convention so the identifier does not
drift when a feature moves from `active/` to `completed/`. There is no `depends_on` field.

## 12. Checkpoint Schema

`artifacts/orchestration/parallel-orchestrator-state.json`:

- `objective`, `route_id: "parallel"`, `parallel_slug`, `parallel_manifest_path`,
  `parallel_status_doc_path`, `mode`, `max_concurrency`
- `completed_steps`, `next_step`, `last_updated`
- `current_cohort`, `recolor_generation`
- `cohorts[]` — `{ index, generation, item_keys[] }`
- `items[]` — `{ issue_num, feature_folder, state, blast_radius, worktree_path, branch_name,
  pr_number, pr_url, merge_status, merge_commit_sha, lifecycle timestamps }`
- `conflict_edges[]` — `{ a, b, reason }`, the computed graph recorded for auditability
- `mutations[]` — §8.6
- `drift_events[]` — `{ item_key, declared, observed, escaped_paths[], at, action }`
- `delegation_receipts[]`, `skill_receipts[]`, `mcp_call_receipts[]`

Per-item `merge_status` enum: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`,
`worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit`.

As with the epic checkpoint, every field needed to re-derive state on resume is re-derivable from
`git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`;
the checkpoint is a cache of durable state, not the source of truth.

## 13. Open Risks

1. **Heuristic derivation under-reports.** Bounded by V1 at plan time and drift detection at
   execution time, not eliminated. If drift events prove frequent in practice, revisit the decision
   to leave the atomic-plan contract unchanged.
2. **Shared-surface serialization.** Failing closed on shared surfaces may collapse most cohorts to
   size one in a repository where many items touch `config/orchestration-routing.json`. Key-level
   partitioning is the planned mitigation; measure before building it.
3. **Greedy coloring is not optimal.** Accepted in exchange for determinism. Cohort counts will be
   at or above the chromatic number.
4. **Concurrency cost.** Each in-flight item is a full child orchestration with its own delegation
   chain. `max_concurrency` is the only control; the default of 4 is a starting value, not a
   measured one.
