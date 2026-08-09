---
name: parallel-add
description: Admit one new item into a running parallel run — preparation via a preparation-mode child orchestrator run, conflict-edge computation against all items including in-flight ones, and the admission decision that either places the item in the current cohort or defers it and recolors the unstarted subgraph. Appends exactly one mutations[] entry. In-flight items are never moved.
argument-hint: "[issue|potential-entry]"
context: fork
agent: parallel-orchestrator
---

# Parallel Add Skill

A user invocation (`/parallel-add <issue|potential-entry>`) forks the `parallel-orchestrator`
agent with this procedure in context. The issue reference or potential-entry path to admit is:

$ARGUMENTS

This skill implements the mutation-protocol add operation (spec FR1). It mutates a parallel run
that is already executing: the run's cohorts, its `recolor_generation`, and its `mutations[]`
audit log all belong to the parallel-orchestrator checkpoint, and the pinning invariant of the
`## Mutation Protocol (F6)` section of `.claude/skills/parallel-orchestrate/SKILL.md` governs what
this operation may and may not disturb. Read that section before applying anything here.

## Prerequisites

- A parallel run is in progress and `artifacts/orchestration/parallel-orchestrator-state.json`
  tracks its `parallel_slug`. This skill does not start a run; use `/parallel-plan` and
  `/parallel-run` for that.
- `$ARGUMENTS` names exactly one item: a GitHub issue number or reference, or a path to an entry
  under `docs/features/potential/`. An argument naming more than one item is rejected; admit one
  item per invocation so each admission decision and its mutation entry stay attributable.

## Re-Derive Durable State Before Applying Anything

The checkpoint is a CACHE of durable state, not the source of truth
(`.claude/rules/parallel-orchestration.md`, Cache Doctrine). Before computing any admission
decision, re-derive the run's true state and rewrite the checkpoint from it when they disagree:

- `git worktree list --porcelain` — worktree existence and path per item.
- `git branch` — branch existence and name per item.
- `gh pr view <pr> --json state,mergedAt,headRefOid` — pull-request state and merge outcome per
  item.

The in-flight set this operation reads is derived from that re-verified state. Admitting against a
stale in-flight set is the one way this operation can violate the pinning invariant, so the
re-derivation is mandatory and is not an optimization to skip when the checkpoint "looks current".

## Procedure

1. **Enter `proposed`.** Add the item to `items[]` in state `proposed` with its `issue_num` as the
   primary key. Item keys are integers throughout this surface; there is no string key.

2. **Prepare the item.** Run preparation through a preparation-mode child `Agent(orchestrator)`
   run, reusing the existing `route_id: preparation` contract UNCHANGED: promotion, research,
   `spec.md`, `user-story.md`, the atomic plan, and preflight clearance. Do not fork a variant
   contract for parallel admission. Preparation yields the item's DECLARED blast radius, and only
   the planner-computed declared radius is authoritative for scheduling. The item's lifecycle
   advances `proposed` -> `admitted` -> `prepared` during this step, recorded as item-state updates in
   `items[]` with the checkpoint's lifecycle timestamps.

3. **Compute conflict edges over ALL items, including in-flight ones.** Invoke the landed
   contention relation `conflicts(a, b, config)` from `scripts/dev_tools/compute_blast_radius.py`
   (defined in `scripts/dev_tools/_blast_radius_conflicts.py`). `a` and `b` are the two items'
   `BlastRadius` value objects, not strings, and `config` is the required parsed
   `config/blast-radius.json` mapping. Map each conflicting pair onto an `(int, int)` conflict edge
   of `items[].issue_num` values, normalized so `a < b`. Do not reimplement the relation and do not
   compute edges over the unstarted subset only: an in-flight conflict is precisely what the
   admission decision turns on.

4. **Decide admission.** Call `decide_admission(candidate, conflict_edges, in_flight)` from
   `scripts/dev_tools/parallel_mutation_protocol.py`.
   - `ADMIT_CURRENT_COHORT` — the candidate shares no edge with any in-flight item. Admit it into
     the current cohort. NO recompute occurs and `recolor_generation` is unchanged.
   - `DEFER_AND_RECOLOR` — the candidate shares an edge with at least one in-flight item. Defer it
     to a future cohort and recolor by calling `recolor_unstarted(unstarted_items,
     conflict_edges, pinned, current_generation)`. The recolor is a recompute:
     `recolor_generation` increments by exactly one.

   A conflict with an UNSTARTED item is not a deferral. The coloring places contending unstarted
   items in different cohorts, so such a conflict is resolved by the recolor, never by rejecting
   the candidate.

5. **Apply the recolor result, if any.** Write `RecolorResult.cohort_assignments` into `cohorts[]`
   and set the top-level `recolor_generation` to `RecolorResult.generation`. The result's key set
   equals the unstarted set exactly and contains no pinned key: no in-flight item changes cohort or
   state as a result of this admission. Verify that before writing, and stop rather than write a
   result that names a pinned key.

6. **Append exactly one `mutations[]` entry**, at admission-decision time, built by
   `build_add_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`:

   | Case | `op` | `item_key` | `prior_state` | `new_state` | `disposition` | `recolor_generation` |
   | --- | --- | --- | --- | --- | --- | --- |
   | No-conflict admit | `add` | item key | null | `scheduled` | null | `g` (unchanged) |
   | Deferred admit | `add` | item key | null | `scheduled` | null | `g` + 1 |

   `prior_state` is null on BOTH add rows. The accompanying `prepared` -> `scheduled` transition is
   not lost and is not recorded in the mutation entry: it is recorded as an item-state update in
   `items[]`, the same mechanism that records `proposed` -> `admitted` -> `prepared` in step 2. The
   `at` timestamp comes from the engine's injected clock seam.

7. **Validate the checkpoint** before treating the admission as applied. Run the
   `validate_orchestration_artifacts` MCP tool with `artifact_type:
   "parallel-orchestrator-state"`. A non-empty error list means the admission was applied
   incorrectly; correct the checkpoint rather than proceeding.

## Constraints

- One admission per invocation, one `mutations[]` entry per successful admission. A failed
  preparation appends no entry and leaves `items[]` without the candidate.
- No field and no enum member is added to `mutations[]`, `conflict_edges[]`, `items[]`, or any
  state or merge-status enum. The nine parallel enums are owned by
  `.claude/rules/parallel-orchestration.md` and are consumed, never extended.
- This operation never moves, restates, or re-derives an in-flight item's cohort or state.
- This operation performs no destructive side effect: it closes no pull request and removes no
  worktree. Those belong to `/parallel-remove` with `--disposition abandon`.

## Completion Requirements

- Report the admitted item key, the admission outcome, the resulting `recolor_generation`, and the
  single appended `mutations[]` entry.
- Report the cohort index the item landed in, and confirm explicitly that no in-flight item's
  cohort or state changed.
- Report the checkpoint validation result.
