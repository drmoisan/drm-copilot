---
name: parallel-run
description: Execute a prepared Codex parallel run from its committed parallel kickoff through the forced parallel-orchestrator. Use when parallel-plan has completed every item through preflight and the root session must verify repository-backed readiness before deterministic execution.
---

# Parallel Run

Use this skill only from the root session.
Delegate only to the project custom agent `parallel-orchestrator`.

Resolve the supplied slug or path to `docs/features/parallel/<parallel-slug>/`. This skill is the
prepared-run entry point; it does not plan, repair, synthesize, or partially execute a run.

## Forced root authority

Before delegation, require root-session authorization plus exact receipts for execution context
`parallel_execution`, route `parallel`, topology `parallel_persona`, logical and deployment agent
`parallel-orchestrator`, orchestration ceiling `C4`, model `gpt-5.6-sol`, reasoning effort `ultra`,
and permissions `parallel-orchestrator-workspace`. Reject missing, mismatched, downgraded, cross-wired, or
unavailable authority. Silent model fallback is prohibited.

## Committed kickoff gate

Require `docs/features/parallel/<parallel-slug>/parallel-kickoff.md` on the recorded plan-home ref
`parallel/<parallel-slug>-plan`.

1. Reject a missing workspace file or missing Git blob. Verify the remote ref, exact path, commit,
   and blob with `git cat-file -e` and `git show`; an untracked or uncommitted workspace copy is not
   a kickoff.
2. Reject byte drift between the committed blob and the selected kickoff.
3. Validate the document as artifact type `parallel-kickoff` with the explicit workspace root.
4. Require its slug, manifest path, plan-home ref, item identities, item branches, committed plan
   paths, conflict/cohort/batch identity, and invocation prompt to agree with the planner state and
   Git.
5. Validate `artifacts/orchestration/parallel-planner-state.json` as artifact type
   `parallel-planner-state` with `require_ready_for_execution: true`.
6. Require every active item to be promoted, prepared, committed, pushed, and exactly
   `PREFLIGHT: ALL CLEAR`, with a declared V1/V2-clear blast radius and complete topology, model,
   delegation, launch, and child-status receipts.
7. Recompute normalized conflict edges, generation-zero cohorts, and ascending bounded batches
   through the shared authorities. Require equality with the committed kickoff and planner state.

If any check fails, stop before delegation and report the exact not-ready finding. Do not use the
ignored working copy under `artifacts/orchestration/`, infer a kickoff from the manifest, downgrade
the readiness call, or launch a subset. Direct the caller to `parallel-plan` for preparation or to
`parallel-orchestrate` for a manually authored manifest.

## Execution handoff

Pass the validated kickoff invocation and repository-backed readiness receipt only to
`parallel-orchestrator`, applying `parallel-orchestrate` as the execution procedure.

- Use `artifacts/orchestration/parallel-orchestrator-state.json`; never reuse an epic checkpoint.
- Resume a matching checkpoint from its durable next step after live Git, GitHub, worktree,
  launch-status, mutation, and drift reconciliation.
- Copy the validated normalized cohort and bounded-batch order into the orchestrator checkpoint
  before the first launch.
- Fix every item branch base to verified `origin/main` and every pull-request target to `main`.
- Reject every integration-branch, integration-PR, final fan-in, dependency-wave, or epic field.
- Resume each item at atomic execution from its committed plan. Do not repeat promotion, research,
  feature documents, planning, or preflight.
- Launch worktree children only through the sealed external parallel launcher named by
  `parallel-orchestrate`; do not substitute an in-session agent launch.

Scheduling, per-item delivery, durable resume, worktree cleanup, and completion remain governed by
`parallel-orchestrate` after this gate succeeds.
