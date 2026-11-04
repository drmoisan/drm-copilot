---
name: parallel-add
description: Admit one new item into a running parallel run — preparation via a preparation-mode child orchestrator run, conflict-edge computation against all items including in-flight ones, and the admission decision that either places the item in the current cohort or defers it and recolors the unstarted subgraph. Appends exactly one mutations[] entry. In-flight items are never moved.
argument-hint: "[issue|potential-entry] [--after <earlier>] [--band <Cn>]"
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

- Reject a pending or not-started run with guidance to consolidate the initial set through `/parallel-plan`. Admit exactly one item only after execution has started in an open run; closed runs are not eligible.

- A parallel run is in progress and `artifacts/orchestration/parallel-orchestrator-state.json`
  tracks its `parallel_slug`. This skill does not start a run; use `/parallel-plan` and
  `/parallel-run` for that.
- `$ARGUMENTS` names exactly one item: a GitHub issue number or reference, or a path to an entry
  under `docs/features/potential/`. An argument naming more than one item is rejected; admit one
  item per invocation so each admission decision and its mutation entry stay attributable. The
  `--after <earlier>` and `--band <Cn>` flags are not items, so the multi-item rejection applies to
  positional items only.
- The run-existence check is evaluated first, before any argument-shape check: a pending or
  not-started run, and a run whose `parallel_slug` no checkpoint tracks, are rejected before the
  argument is examined.
- On either run-existence rejection, change no state and emit the rejection signal defined in
  `## Mutation Rejection Signal (issue #1012)` of `.claude/rules/parallel-orchestration.md`: when
  the run's slug is known, put the line `parallel_slug: <slug>` before the signal, and end the
  final output with the literal line `PARALLEL_MUTATION_REJECTED: run_not_started` as its last
  line, with no formatting and no trailing text.
- After the run-existence check passes, apply the closed-run guard in code. Read the manifest mode
  with `bash .claude/lib/bash/validate-parallel-manifest.sh --print-mode <manifest-path>`, then run
  `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 guard-run -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ManifestMode <mode>`.
  The guard rejects when either mode is `closed`, when a `mutations[]` entry has `op` `close`, or
  when the two modes disagree. On exit 1, stop with the helper's stderr line
  (`PARALLEL_ADMISSION_REJECTED: run_closed: <detail>`) as the reported reason, change no state,
  and emit no mutation rejection signal: `run_closed` is an admission rejection code defined in
  `## Prepared-Item Admission (issue #1047)` of `.claude/rules/parallel-orchestration.md`, not a
  mutation rejection code.
- A closed run and an argument naming more than one item are rejected only after the run-existence
  check, while the run's checkpoint exists; each of these rejections emits no rejection signal, and
  the stop validates against that checkpoint.

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

2. **Prepare the item.** First assess how far the item's pushed branch is already prepared:
   `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 assess -Branch origin/<item branch> -FeatureFolder <feature folder> -PlannerCheckpointPath artifacts/orchestration/parallel-planner-state.json`,
   adding `-Band <Cn>` when the operator passed `--band`. The helper reads the branch by ref, selects
   the newest preparation receipt or infers the stage from the branch files, compares the files the
   plan cites against `origin/main` since the base commit, and prints `next_action`.
   - When `next_action` is `admit_prepared` (stage `cleared`, verdict `fresh`), run no preparation
     child, no preflight, and no plan revision. Record the output's `preparation_status`,
     `plan_hash`, `base_commit`, `complexity_band` (the `band.value`), and `band_source` (the
     `band.source`) on the item, and continue with step 3.
   - Otherwise delegate the preparation child described below on the item's pushed branch, not on
     a new branch, and append after the unchanged kickoff line the resume line
     `Preparation resume: stage <stage>. Existing artifacts: <paths>. Do not repeat a completed stage; supersede with new timestamped files.`
     with `<stage>` set to the output's `resume_stage` and `<paths>` listing the existing
     `research_path`, `spec_path`, and `plan_path` relative to the feature folder. A stale item
     (verdict `stale`) resumes at preflight with the output's `changed_cited_paths` as the findings,
     under the single-pass rule of `.claude/skills/orchestrate/SKILL.md` `## Delegation Model`
     (trivial defects fixed in place, one planner revision for substantive defects, and a halt with
     the defect list when a second round still fails). A plan that never cleared preflight always
     runs preflight. A contract change found by that preflight, or a `premise_falsified` verdict
     (a cited path removed on `main`), resumes at `plan`: the new plan is a new timestamped file,
     and no superseded artifact is deleted.
   - The band source order is `--band` (`band_source: caller`), then the planner checkpoint item's
     `complexity_band` (`planner_checkpoint`), then the `## Complexity Assessment` procedure below
     (`assessment`).

   Otherwise run preparation through a preparation-mode child `Agent(orchestrator)`
   run, reusing the existing `route_id: preparation` contract UNCHANGED: promotion, research,
   `spec.md`, `user-story.md`, the atomic plan, and preflight clearance. Do not fork a variant
   contract for parallel admission. Preparation yields the item's DECLARED blast radius, and only
   the planner-computed declared radius is authoritative for scheduling. The item's lifecycle
   advances `proposed` -> `admitted` -> `prepared` during this step, recorded as item-state updates in
   `items[]` with the checkpoint's lifecycle timestamps. When the band source is `assessment`, after
   the admitted item's preflight
   clearance, perform the `parallel-plan` skill's `## Complexity Assessment` procedure for it, and
   record the resulting `complexity_band` on the admitted orchestrator-checkpoint item so step 3's
   edge derivation and the parent's model routing read the same band.
   The admitted item records `complexity_band` and no `model_routing_receipt`; the parent resolves
   the item's model from that band at spawn time per `parallel-orchestrate` `## Model Selection`.
   For an issue-number item, the preparation delegation prompt carries the issue-adoption line used
   by `/parallel-plan` `## Preparation Fan-Out`, quoted verbatim: `Issue adoption: this item's GitHub
   issue already exists. Verify it read-only (gh issue view), do not call potential_to_issue or the
   promotion-entry tool, and record a top-level issue_adoption object in the checkpoint per
   .claude/rules/orchestrator-state.md with origin filed_before_orchestration (or transferred when
   the issue was transferred), waiving potential_to_issue and the promotion-entry tool for the
   checkpoint's promotion-type. When a lifecycle record for the item exists under
   docs/features/potential/promoted/, cite it as potential_record.` The line is omitted for a
   potential-entry item, whose child promotes it. The preparation child creates and commits the
   item's feature folder, so the item's later execution child records `feature_folder_record` for
   that committed folder instead of calling `new_active_feature_folder` again, per
   `/parallel-orchestrate` kickoff element 4.

3. **Compute conflict edges over ALL items, including in-flight ones.** Invoke the scheduling
   entry point Get-BlastRadiusConflictEdge from the destination-runtime PowerShell port
   `.claude/lib/blast-radius/BlastRadius.psm1`, which is published by push-down and needs no Python
   interpreter (the default PowerShell 5.1 execution policy blocks `Import-Module` of a `.psm1`
   file, so `pwsh` is mandatory: run as `$repoRoot = git rev-parse --show-toplevel; Import-Module
   (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop`).
   Call it once, as `Get-BlastRadiusConflictEdge -Item <items> -Config <config> -Relation ${function:Test-BlastRadiusConflict}`, where each item
   record carries `key` (the `items[].issue_num` value), `radius` (the item's radius hashtable, not
   a string), and the optional complexity `band`, and `-Config` is the required parsed
   `config/blast-radius.json` mapping, which push-down publishes into the destination workspace.
   The -Relation argument is required and carries the facade's detection relation; an omitted
   relation fails fast. The entry point applies the contention relation `Test-BlastRadiusConflict` to every unordered
   pair and then the integration-cost edge rule of `.claude/rules/parallel-orchestration.md`
   (hard classes, integer cost, pairwise benefit, and the configured `conflict_tolerance`); the
   relation still reads the mapping's optional `mergeable_paths` list and contributes no
   `path_overlap` edge for a path matching it while the path stays in the declared radius.
   `schedule_conflict_edges(items, config)` and `conflicts(a, b, config)` in
   `scripts/dev_tools/compute_blast_radius.py` (defined in
   `scripts/dev_tools/_blast_radius_scheduling.py` and `scripts/dev_tools/_blast_radius_conflicts.py`)
   remain the repository authority and the parity reference. The call returns a hashtable with
   `edges` (records `a`, `b`, `reason`, `hard`, `cost`, `benefit`, already normalized so `a < b`)
   and `tolerated_overlaps` (records `a`, `b`, `reasons`, `cost`, `benefit`). Take each returned
   edge as an `(int, int)` conflict edge of `items[].issue_num` values, and record the returned
   tolerated overlaps in the checkpoint's tolerated_overlaps list. When `Test-BlastRadiusConflict`
   is called directly for a single pair, read the verdict from `$result['conflict']`; do not test
   the returned hashtable itself, since it is always truthy under PowerShell boolean coercion, so a
   bare `if ($result)` check treats every pair as conflicting. Do not reimplement the relation or
   the edge rule, do not apply the relation to each pair by hand, and do not compute edges over the
   unstarted subset only: an in-flight conflict is precisely what the admission decision turns on.
   A tolerated overlap is not an edge: the two items run in the same or adjacent cohorts without a
   barrier, and the later-merging item merges `origin/main` under the existing per-item
   merge-conflict handling and re-passes CI before it merges. The entry point applies the aggregate
   cost cap (issue #1013) inside the same call, so the edges this step records are capped edges.
   After the edges are computed, call Get-BlastRadiusCombination from the same facade over the
   candidate plus the unstarted items, with the same `-Config` and `-Relation`, and report each
   qualifying pair that involves the candidate with the text
   `qualifies for combination; not combined (combination applies at planning time only)`. This
   step never combines items: it adds no checkpoint field and makes no `mutations[]` change for a
   qualifying pair.
   Record each `--after <earlier>` flag as one top-level `precedence[]` entry
   `{before, after, source, recorded_at}` with `before` the earlier item, `after` the candidate,
   `source` `operator`, and `recorded_at` the current UTC minute. Each precedence pair is a
   separating input, never a dependency key: add it to the edges passed to steps 4 and 5 as one
   more `<a>:<b>` edge with `a < b`, so the coloring always separates the pair.

4. **Decide admission.** Call the bundled entry point, which needs no Python interpreter:

   ```bash
   bash .claude/lib/bash/mutate-parallel-run.sh admit --candidate <key> --edges "<a>:<b> ..." --in-flight "<k> ..." --current-cohort-members "<k> ..."
   ```

   `--edges` carries the step-3 conflict edges over ALL items, `--in-flight` the in-flight (pinned)
   keys, and `--current-cohort-members` the full current-cohort membership. The command prints one
   JSON object whose `outcome` field is one of:
   - `admit_current_cohort` — the candidate shares no edge with any member of the current cohort,
     pinned or unstarted. Admit it into the current cohort. NO recompute occurs and
     `recolor_generation` is unchanged — precisely because the candidate conflicts with no
     current-cohort member, so no cohort assignment needs to change.
   - `defer_and_recolor` — the candidate shares an edge with at least one member of the current
     cohort, pinned or not-yet-launched. Defer it to a future cohort and recolor through the
     bundled entry point:

     ```bash
     bash .claude/lib/bash/mutate-parallel-run.sh recolor --unstarted "<k> ..." --edges "<a>:<b> ..." --pinned "<k> ..." --generation <g> --current-cohort <c> --highest-pinned-cohort <h>
     ```

     `--highest-pinned-cohort` is derived from re-verified durable state: the highest
     current-generation cohort index occupied by any in-flight item.
     The recolor is a recompute: `recolor_generation` increments by exactly one, and it places every
     unstarted item at an index at or above `current_cohort`, strictly above
     `highest_pinned_cohort` when a pinned conflict exists.

   Derive `current_cohort_members` from the re-verified durable state, not from the cached
   checkpoint: it is the full membership of the current-generation cohort at `current_cohort`,
   INCLUDING its not-yet-launched `scheduled` members. Derive `current_cohort` from that same
   re-verified state; it is F3's top-level `current_cohort` field, the lowest current-generation
   cohort index still holding a non-terminal item. Under the per-edge barrier an in-flight item is
   not confined to that index, so derive `highest_pinned_cohort` from the same re-verified state as
   well: the highest current-generation cohort index occupied by any in-flight item. Both matter
   because `max_concurrency` caps simultaneously in-flight items independently
   of cohort size and refills each freed slot from the same current cohort — see
   `## Cohort Barrier and Max-Concurrency Slot Filling` in
   `.claude/skills/parallel-orchestrate/SKILL.md` — so the current cohort durably holds `scheduled`
   members that a candidate can contend with.

   A candidate with an active unmerged predecessor (a `precedence[]` entry whose `before` item has a
   `merge_status` other than `merged` or `worktree_removed` and a `state` other than `withdrawn`) is
   forced to `defer_and_recolor` even when `admit` prints `admit_current_cohort`.

   A conflict with an unstarted member of the CURRENT cohort defers the candidate and recolors,
   because the next `max_concurrency` batch would otherwise launch the two concurrently. A conflict
   with an unstarted item OUTSIDE the current cohort does not defer: the cohort barrier keeps the
   two from running concurrently, so the coloring's existing separation already resolves it.

5. **Apply the recolor result.** Before writing, pass the recolor result through the precedence
   lift: `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 order-cohorts -Cohorts <table-json> -Edges "<a>:<b> ..." -Precedence "<before>:<after> ..." -Pinned "<k> ..." -Floor <current_cohort>`,
   which moves an unstarted `after` item above its `before` items and never moves a pinned item.
   After writing, and before step 6 appends the mutation entry, run
   `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 test-cohorts -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json`;
   on exit 1 (`precedence_violated`, `precedence_cycle`, or `precedence_unknown_item`), restore the
   prior `cohorts[]` and `recolor_generation` and stop with the helper's stderr line.
   Write the recolor output field `cohort_assignments` (as lifted) into
   `cohorts[]` and set the top-level `recolor_generation` to the output field `generation`. The
   result's key set equals the
   unstarted set exactly and contains no pinned key: no in-flight item changes cohort or state as a
   result of this admission. Verify that before writing, and stop rather than write a result that
   names a pinned key. The admit branch performs no recolor at all, precisely because the candidate
   conflicts with no current-cohort member.

   The returned `cohort_assignments` values are **ABSOLUTE cohort indices**. Write them VERBATIM
   into `cohorts[].index`; never re-base them to zero. When the lowest returned index equals
   `current_cohort` — the no-pinned-conflict case, where the offset is not applied — the returned
   keys at that index are **MERGED into the single existing current-generation cohort entry at
   `current_cohort`** alongside its pinned members, and are never written as a second cohort entry
   carrying the same `index`, because F3 invariant 13 requires current-generation `cohorts[].index`
   values to be unique (`scripts/dev_tools/_parallel_state_structures.py:282-305` — duplicate-index
   detection at 282-293, error emission at 301-305).

6. **Append exactly one `mutations[]` entry**, at admission-decision time, built by the bundled
   entry point. Run the first line on the admit branch (`--deferred false`) and the second on the
   defer branch (`--deferred true`):

   ```bash
   bash .claude/lib/bash/mutate-parallel-run.sh add-entry --item <key> --deferred false --generation <g> --at <timestamp>
   bash .claude/lib/bash/mutate-parallel-run.sh add-entry --item <key> --deferred true --generation <g> --at <timestamp>
   ```

   `--generation` is the run's generation before this admission, read before any step-5 recolor;
   the printed entry stamps it unchanged or plus one per the table below:

   | Case | `op` | `item_key` | `prior_state` | `new_state` | `disposition` | `recolor_generation` |
   | --- | --- | --- | --- | --- | --- | --- |
   | No-conflict admit | `add` | item key | null | `scheduled` | null | `g` (unchanged) |
   | Deferred admit | `add` | item key | null | `scheduled` | null | `g` + 1 |

   `prior_state` is null on BOTH add rows. The accompanying `prepared` -> `scheduled` transition is
   not lost and is not recorded in the mutation entry: it is recorded as an item-state update in
   `items[]`, the same mechanism that records `proposed` -> `admitted` -> `prepared` in step 2. The
   `at` timestamp is supplied through `--at`; when `--at` is omitted the entry point stamps the
   current UTC minute.

7. **Validate the checkpoint** before treating the admission as applied. Run the
   `validate_orchestration_artifacts` MCP tool with `artifact_type:
   "parallel-orchestrator-state"`. A non-empty error list means the admission was applied
   incorrectly; correct the checkpoint rather than proceeding.

8. **Rewrite the durable scheduling record.** Build the record content with
   `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 record -RunFolder docs/features/parallel/<slug> -Entry <entry-json>`,
   where the entry carries the checkpoint's `conflict_edges`, `tolerated_overlaps`, `precedence`,
   and `items`. The helper prints the content and makes no git write. Write it to
   `docs/features/parallel/<slug>/parallel-scheduling.json` on `parallel/<slug>-plan` and commit it
   with a pathspec under `docs/features/parallel/`, so a re-seed from another checkout reads the
   recorded edges and plan hashes by ref.

## Constraints

- One admission per invocation, one `mutations[]` entry per successful admission. A failed
  preparation appends no entry and leaves `items[]` without the candidate.
- No field and no enum member is added to `mutations[]` or any state or merge-status enum. The only
  fields added to `items[]` are the four tolerated fields `preparation_status`, `plan_hash`,
  `base_commit`, and `band_source` declared in `## Prepared-Item Admission (issue #1047)` of
  `.claude/rules/parallel-orchestration.md`, which also declares the top-level `precedence[]` list
  this skill records. A `conflict_edges[]` entry may carry only the three tolerated extra fields `hard`, `cost`,
  and `benefit` (tolerated-not-validated, returned by the scheduling entry point), and no reason
  member is added: the four `conflict_edges[].reason` members are unchanged. The nine parallel
  enums are owned by `.claude/rules/parallel-orchestration.md` and are consumed, never extended.
  The `complexity_band` recorded in step 2 is not a new field: it is an existing scheduling field
  read by drift re-scheduling.
- This operation never moves, restates, or re-derives an in-flight item's cohort or state.
- This operation performs no destructive side effect: it closes no pull request and removes no
  worktree. Those belong to `/parallel-remove` with `--disposition abandon`.
- The step 5 stop and a failed preparation each emits no rejection signal: the run's checkpoint
  already exists and state is already written, so the stop validates against that checkpoint.

## Completion Requirements

- Report the admitted item key, the admission outcome, the resulting `recolor_generation`, and the
  single appended `mutations[]` entry.
- Report the cohort index the item landed in, and confirm explicitly that no in-flight item's
  cohort or state changed.
- Report the checkpoint validation result.
