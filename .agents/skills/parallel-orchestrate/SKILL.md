---
name: parallel-orchestrate
description: Execute a validated prepared or manually authored Codex parallel run through the forced parallel-orchestrator. Use when a root session must persist deterministic cohort and bounded-batch order, launch isolated item worktrees, and deliver one main-targeted pull request per item without integration fan-in.
---

# Parallel Orchestrate

Use this skill only from the root session.
Delegate only to the project custom agent `parallel-orchestrator`.

This is the execution procedure for both a committed `parallel-run` kickoff and an explicitly
manual parallel manifest. Manual authorship changes only how the input is obtained; it does not
waive preparation, readiness, routing, repository, scheduling, launch, or completion validation.

## Forced root authority

Read `AGENTS.md`, applicable policies under `.agents/skills/`,
`config/orchestration-routing.json`, and any existing
`artifacts/orchestration/parallel-orchestrator-state.json` before acting.

Require root-session authorization and exact receipts for execution context `parallel_execution`,
route `parallel`, topology `parallel_persona`, logical and deployment agent
`parallel-orchestrator`, orchestration ceiling `C4`, model `gpt-5.6-sol`, reasoning effort `ultra`,
and permissions `parallel-orchestrator-workspace`. Reject absent, mismatched, downgraded, cross-wired, or
unavailable authority before any child launch. Silent model fallback is prohibited.

## Entry paths and common readiness gate

### Prepared kickoff

For `parallel-run`, require the already validated committed kickoff at
`docs/features/parallel/<parallel-slug>/parallel-kickoff.md`, its plan-home Git identity, and a
planner checkpoint accepted with `require_ready_for_execution: true`. Re-run the kickoff,
repository, and planner-state checks before copying schedule state. Reject drift; do not downgrade
the validation or fall back to an ignored working copy.

### Manual manifest

For a direct manual invocation, resolve `docs/features/parallel/<parallel-slug>/parallel.md`. A
planner-authored kickoff may be absent, but readiness may not be absent. Before launch, build and
persist a manual readiness receipt over the same evidence required of a prepared kickoff:

- at least two positive unique issue keys and fully resolved active feature folders;
- committed and pushed per-item branches based on verified `origin/main`;
- research, `spec.md`, `user-story.md`, approved atomic plan, and exact
  `PREFLIGHT: ALL CLEAR` for every active item;
- declared V1/V2-clear blast radii and complete authority, topology, model, delegation, launch,
  and child-status receipts;
- repository-backed plan paths and hashes;
- normalized conflict edges, deterministic cohorts, and bounded batches.

Validate the equivalent planner-state candidate with the same
`parallel-planner-state` readiness gate before creating execution state. If the manual input lacks
any required evidence, return not ready and launch nothing. Do not run preparation or
implementation to fill a manual-manifest gap.

## Manifest contract

Treat the selected `docs/features/parallel/<parallel-slug>/parallel.md` as read-only. Validate it
through the shared portable entry point:

```bash
bash .claude/lib/bash/validate-parallel-manifest.sh docs/features/parallel/<parallel-slug>/parallel.md
```

Resolve `mode` and `max_concurrency` through that entry point. Require mode `closed` or `open` and
an integer concurrency limit from `1` through `8`. Reject malformed or duplicate item identity,
partial cohorts, and every `depends_on`, `wave`, `integration_branch`, integration-PR, final-PR,
or fan-in field. Do not infer or tolerate an epic shape.

Set these values unconditionally for every item:

- repository base: verified `origin/main`;
- branch base: the recorded `origin/main` commit for its cohort;
- pull-request target: `main`.

No integration branch is created, fetched, pushed, merged, or used as a PR base. There is no
run-level fan-in or final integration pull request.

## Persist schedule before launch

Do not implement conflict, coloring, or batching algorithms in this skill. Use
`config/blast-radius.json`, `./.claude/lib/blast-radius/BlastRadius.psm1`, and the portable entry
points:

```bash
bash .claude/lib/bash/compute-cohorts.sh --keys "<ascending keys>" --edges "<a>:<b> ..."
bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<cohort keys>" --max-concurrency <n>
```

Before the first launch:

1. Normalize items by ascending issue key and conflicts as ordered unique undirected pairs.
2. Recompute declared-radius conflict edges through the shared blast-radius authority.
3. Recompute cohorts using Welsh-Powell order `(-degree, item_key)` and the smallest available
   color, then order cohorts by ascending color and keys ascending within each cohort.
4. Recompute each cohort's batches from ascending item keys with no batch larger than
   `max_concurrency`.
5. For a prepared kickoff, require exact equality with its persisted conflict, cohort, and batch
   identity. For a manual manifest, persist the computed identity in the readiness receipt.
6. Copy the accepted conflict graph, cohort generation, cohort order, batch order, and per-item
   positions into `artifacts/orchestration/parallel-orchestrator-state.json`.
7. Validate that checkpoint before launch. Any mismatch, missing item, duplicate position, or
   reordered batch blocks admission.

Available Codex thread capacity may lower simultaneous resource use but must never change persisted
cohort membership, batch membership, or ascending item order.

## Cohort and batch admission

- Start cohorts in ascending index for the current `recolor_generation` only.
- Do not admit a later cohort until every required predecessor item is durably merged and its
  matching worktree is removed.
- Admit only the first incomplete persisted batch of the current cohort.
- Within a batch, launch in ascending item-key order. Do not fill a slot from a later batch.
- Reconcile live Git, GitHub, worktree, launch-status, mutation, drift, and child-status state
  before every admission decision; cached notifications are not authority.
- Unresolved mutation or semantic drift quiesces new admission and is resolved only through the
  shared validators and mutation skills.

## Item launch boundary

Launch write-heavy item workers only through
`.codex/scripts/launch-parallel-child-batch.ps1` and its sealed launch specification. Do not use
native in-session subagent spawning as worktree authority.

Each launch must bind the exact repository, `origin/main` base commit, unique branch and worktree,
positive issue key, cohort/batch/position, item plan, generated child deployment profile, model,
reasoning effort, permissions, authority, topology, model-routing, delegation, prompt hash,
isolated `CODEX_HOME`, launch receipt, and child-status path. Reject reuse or mismatch.

The child prompt must state `Parallel mode: true`, the slug, checkpoint path, issue key,
cohort/batch identity, active feature folder, committed plan path, and `PR base branch MUST be
main; pass --base main to gh pr create.` The item resumes at atomic execution. It must not repeat
promotion, research, feature documents, planning, or preflight. Each item's ordinary orchestrator
owns implementation, tests, review, PR authoring, and CI; the parallel root does not perform that
work locally and neither parallel root persona may run as a child.

## Checkpoint and resume

Persist `artifacts/orchestration/parallel-orchestrator-state.json` after every transition with:

- schema version, objective, route, slug, manifest/status paths, mode, `max_concurrency`, current
  cohort, generation, durable next step, and timestamp;
- normalized items, conflicts, cohorts, bounded batches, and per-item positions;
- root and per-item authority, topology, model, delegation, launch, Git/worktree, PR/check,
  mutation, drift, removal, and completion receipts.

Never use an epic checkpoint. On resume, reconcile every cached field against the repository,
remote refs, worktree list, GitHub PR head/state/checks, and immutable status records. Continue the
first incomplete item in persisted cohort/batch/item order without duplicating any durable object.

## Per-item delivery and completion

Each item owns exactly one pull request targeting `main`. Confirm its current head SHA and required
green checks before merge. Merge that item to `main`, record its merge SHA, and remove only its
matching worktree after the removal gate accepts it. A conflict or failed check returns control to
the item's bounded remediation path; the parallel root must not implement the repair locally.

Regenerate `docs/features/parallel/<parallel-slug>/parallel-status.md` from the checkpoint at
kickoff, each item/cohort/batch transition, each mutation or drift transition, and completion.

For closed mode, require every active item merged, every worktree safely removed, every acceptance
criterion current, no unresolved mutation or drift, and successful
`parallel-orchestrator-state` validation with completion, topology, and model-routing requirements.
Open mode cannot complete until an accepted `parallel-close` mutation changes it to closed. No
completion path creates an integration or fan-in pull request.
