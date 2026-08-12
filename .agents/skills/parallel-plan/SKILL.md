---
name: parallel-plan
description: Prepare two or more independent issues for deterministic bounded parallel execution through the forced Codex parallel-planner. Use when a root session must complete promotion, research, feature documents, atomic planning, preflight, blast-radius conflict analysis, cohort and batch assignment, a standalone planner checkpoint, and a committed kickoff without starting implementation.
---

# Parallel Plan

Use this skill only from the root session.
Delegate only to the project custom agent `parallel-planner`.
The `parallel-planner` is the sole root delegate for this workflow.

The root session passes the requested parallel slug, issue numbers, and potential-entry paths to
that agent. It must not perform this procedure locally, route it through an ordinary or epic
orchestrator, or delegate to `parallel-orchestrator`.

Planning ends after all active items have complete preparation and deterministic scheduling
evidence. Atomic execution, implementation, pull-request work, feature review, CI monitoring, and
merge operations are prohibited. No child implementation process can launch from this skill.

## Required authority

Before any write-heavy preparation, read `AGENTS.md`, applicable policies under `.agents/skills/`,
`config/orchestration-routing.json`, and any existing
`artifacts/orchestration/parallel-planner-state.json`.

Resolve and persist the forced root receipts with these exact values:

- execution context `parallel_planning`;
- route `parallel` and topology `parallel_persona`;
- logical and deployment agent `parallel-planner`;
- orchestration complexity ceiling `C4`;
- model `gpt-5.6-sol` and reasoning effort `ultra`;
- permissions `parallel-planner-workspace`;
- root-session authority bound to this invocation.

Reject absent, mismatched, downgraded, cross-wired, or unavailable authority before preparation.
Model aliasing and silent fallback are prohibited.

## Inputs and normalization

Accept a safe slug plus at least two item inputs. Each item is either a positive GitHub issue
number or a repository potential-entry path.

1. Normalize the slug to lowercase hyphen form and reject an unsafe or empty result.
2. Resolve each issue to its repository identity. Assign temporary negative keys to potential
   entries only until their preparation child returns a verified promotion receipt.
3. Replace every temporary key with its positive issue number before conflict analysis.
4. Reject duplicate issue numbers, duplicate potential entries, unresolved identities, and an
   item set with fewer than two active items.
5. Sort the final normalized item records by ascending `issue_num`. This order is the only input
   order used by subsequent deterministic operations.
6. Resolve `mode` to `closed` unless explicitly set to `open`. Resolve `max_concurrency` to `4`
   unless supplied, and require an integer from `1` through `8`.

Do not accept dependency edges, requested cohort numbers, requested batch numbers, integration
branches, or fan-in fields. Parallel order comes only from shared conflict authority.

## Standalone artifact home

Create the planner-owned branch `parallel/<parallel-slug>-plan` from verified `origin/main`.
Store only run-level documents on it:

- `docs/features/parallel/<parallel-slug>/parallel.md`;
- `docs/features/parallel/<parallel-slug>/parallel-kickoff.md`.

Maintain the independent checkpoint only at
`artifacts/orchestration/parallel-planner-state.json`. Never read or write an epic planner or epic
orchestrator checkpoint for this surface. Each prepared item's feature folder and approved plan
remain on that item's own pushed branch based on `origin/main`; no item branch merges into the
planner branch.

## Preparation-only child boundary

Prepare every item through the repository's sealed external child launcher in execution context
`preparation`. A preparation launch may perform only promotion, research, feature-document
authoring, atomic planning, and atomic-executor preflight validation. Its prompt must state:

> `Preparation mode: true. route_id: preparation. parallel_slug: <parallel-slug>. Perform promotion, research, feature documents, atomic planning, and preflight clearance only. Atomic execution, implementation, PR authoring, feature review, CI monitoring, and merge operations are out of scope. After PREFLIGHT: ALL CLEAR, commit and push the prepared feature folder and plan, set next_step to S5_atomic_execution, and stop.`

The preparation prompt must not contain `Parallel mode: true` or `Epic mode: true`. Those markers
authorize execution scheduling and are invalid here. The launcher must bind each child to a
distinct worktree and branch, exact routed profile, delegation receipt, topology receipt, model
receipt, and preparation-only prompt hash.

A completed item requires all of the following:

- verified promotion receipt and positive `issue_num`;
- active feature folder with `issue.md`, research, `spec.md`, and `user-story.md`;
- an approved atomic plan whose preflight result is exactly `PREFLIGHT: ALL CLEAR`;
- `next_step: S5_atomic_execution` on the item checkpoint;
- committed and pushed preparation output on the recorded item branch;
- no production or test implementation diff from the preparation process;
- exact topology, model-routing, delegation, launch, and child-status receipts.

If any condition is absent, persist the item as not prepared and do not admit it to kickoff.

## Shared blast-radius authority

Do not implement blast-radius parsing, normalization, validation, or conflict detection in skill
prose. Use the published issue-462 portable authority:

```powershell
Import-Module ./.claude/lib/blast-radius/BlastRadius.psm1 -Force
```

Use `config/blast-radius.json` as its truth table. Call `Get-PlanPaths`, `Get-BlastRadius`,
`Test-BlastRadius`, and `Test-BlastRadiusConflict`. The shared Python modules under
`scripts/dev_tools/` remain the repository reference implementation; the portable PowerShell
module is the payload runtime. Do not copy or edit either implementation from this skill.

For each prepared item:

1. Read the committed plan and `spec.md` text from the item's pushed branch.
2. Derive a `source: declared` radius with the stable keys `paths`, `modules`, `shared_surfaces`,
   `contracts`, `source`, and `computed_at`.
3. Run V1 coverage, V2 shared-surface enumeration, and V3 over-breadth validation.
4. Treat a V1 or V2 Blocking finding as not ready and return the item to preparation-only plan
   revision. Record a V3 Advisory without changing readiness.
5. Evaluate every unordered pair in ascending `(lower_item_key, higher_item_key)` order through
   `Test-BlastRadiusConflict`.
6. Record one normalized undirected edge per conflicting pair with ordered endpoints and the
   shared authority's sorted stable reason codes. Fail closed on an unrecognized radius or reason.

Equivalent normalized item records and committed plan/spec inputs must therefore produce the same
declared radii and byte-equivalent semantic conflict edges regardless of invocation order.

## Deterministic cohorts and bounded batches

Use the portable cohort and batching entry points; do not reproduce their algorithms:

```bash
bash .claude/lib/bash/compute-cohorts.sh --keys "<ascending keys>" --edges "<a>:<b> ..."
bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<cohort keys>" --max-concurrency <n>
```

The shared Python authority is `scripts/dev_tools/parallel_cohort_computation.py`. The runtime
contract is deterministic:

1. Normalize vertices to the final unique positive item keys and edges to ordered unique pairs.
2. Visit vertices by the ascending composite key `(-degree, item_key)`.
3. Assign each vertex the smallest non-negative color not used by an adjacent vertex.
4. Emit cohorts in ascending color order and item keys ascending within each cohort.
5. For each cohort in order, sort its keys ascending and split consecutive groups no larger than
   `max_concurrency`. Preserve ascending batch index and ascending position within each batch.

Available Codex thread capacity is only a resource ceiling. It must not change conflict edges,
vertex order, colors, cohort order, batch membership, or item order.

After recording generation-zero cohorts and bounded batches, recompute both from the normalized
checkpoint inputs. Require exact semantic equality for conflict edges, cohort indexes and members,
batch indexes and members, and item order. A mismatch makes the checkpoint not ready; do not
rewrite the first result or emit a kickoff.

## Manifest

Write `docs/features/parallel/<parallel-slug>/parallel.md` with:

- `parallel`, `mode`, `max_concurrency`, and an ISO-8601 `created_at`;
- one ascending item record per positive unique `issue_num`;
- `feature_folder`, `kind`, preparation state, and declared blast radius for every item;
- generation-zero cohorts, normalized conflict edges, and ascending bounded batches.

Reject `depends_on`, `wave`, `integration_branch`, integration PR, or fan-in fields. Validate the
manifest through the shared portable entry point:

```bash
bash .claude/lib/bash/validate-parallel-manifest.sh docs/features/parallel/<parallel-slug>/parallel.md
```

Commit and push the fully resolved manifest on `parallel/<parallel-slug>-plan`; no negative or
placeholder item key may remain.

## Planner checkpoint

Write `artifacts/orchestration/parallel-planner-state.json` after each state transition. Persist:

- schema version, objective, `parallel_slug`, manifest path, mode, `max_concurrency`, and
  `plan_home_branch`;
- the forced root authority, topology, and model-routing receipts;
- normalized items and their preparation, Git, blast-radius, validation, and receipt state;
- normalized `conflict_edges`, generation-zero `cohorts`, deterministic bounded batches,
  `recolor_generation: 0`, and `current_cohort: 0`;
- completed steps, the exact durable `next_step`, kickoff path, and timestamp.

The checkpoint is a cache. On resume, reconcile it with repository identity, remote refs,
committed blobs, branches, worktrees, and child-status receipts. Durable repository state wins;
rewrite stale cached values before continuing.

Maintain a fail-closed ready/not-ready boundary:

- Not ready: persist the first incomplete or invalid step in `next_step`; do not use
  `PARALLEL_EXECUTION_READY`; validate without the readiness flag and retain all findings.
- Ready: every active item satisfies the complete preparation contract, all conflict/cohort/batch
  parity checks pass, no temporary key remains, and `next_step` is exactly
  `PARALLEL_EXECUTION_READY`.

Invoke `validate_orchestration_artifacts` for `parallel-planner-state` with
`require_ready_for_execution: true` and the explicit workspace root before producing a ready
result. Any finding leaves the checkpoint not ready.

## Committed kickoff

Only after the ready checkpoint gate succeeds, write and commit
`docs/features/parallel/<parallel-slug>/parallel-kickoff.md` on
`parallel/<parallel-slug>-plan`. The kickoff must include:

- heading `# Parallel Kickoff: <parallel-slug>`;
- the committed manifest path and planner checkpoint path;
- exact root invocation `parallel-run <parallel-slug>`;
- an item table with issue, feature folder, cohort, batch, complexity, branch, and plan path;
- a statement that each item resumes at atomic execution from its committed plan on its own
  branch and targets `main`;
- the generation-zero conflict/cohort/batch identity and planning commit provenance.

Validate the committed document as artifact type `parallel-kickoff`, verify it with `git show` at
the pushed plan-home ref, and bind its path, commit, and hash into the planner checkpoint. Re-run
the ready checkpoint validator after this binding. Do not emit or delegate an execution prompt
from an uncommitted or mismatched kickoff.

## Completion response

Return either `PARALLEL_EXECUTION_READY` or a precise not-ready result. For a ready result, report
the manifest and committed kickoff paths, plan-home ref, every item plan/branch/preflight result,
normalized conflict edges, generation-zero cohorts, ascending bounded batches, and successful
recomputation and validator results. State explicitly that implementation has not started and can
begin only through a later root invocation of `parallel-run`.
