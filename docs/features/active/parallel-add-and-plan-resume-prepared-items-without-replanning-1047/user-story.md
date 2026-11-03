# `parallel-add-and-plan-resume-prepared-items-without-replanning` — User Story

- Issue: #1047
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1047
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-03

## Story Statement

- As the repository owner running parallel orchestration, I want `/parallel-add` and `/parallel-plan` to admit an item at whatever stage its branch already reached, so that finished research, specs, plans, and preflights are not repeated at the cost of hours and quota.
- As the repository owner, I want to state that one item must run after another, so that a prerequisite is merged before the item that depends on it starts.
- As the repository owner, I want a closed run to refuse an add from code with a clear error, so that the refusal does not depend on an agent reading prose correctly.
- As the parallel orchestrator, I want conflict edges and plan hashes stored in a committed record, so that a re-seed from another checkout recovers them and an execution child does not start on a plan that changed after admission.
- As the repository owner, I want the parent orchestrator to treat "PR open, step 9 pending" as not done, so that no item needs a manual second turn to reach its CI green gate.

## Problem / Why

Every item admitted by `/parallel-add` or seeded by `/parallel-plan` goes through the full preparation-mode child, even when its branch already holds research, a spec, a plan, or a cleared preflight. A stale-plan reconcile alone measured about 50 minutes for one item (#1010), while items whose cited files were unchanged could skip it with a mechanical check. In addition, the scheduler cannot express "A after B" (a dry run colored a dependent item before its prerequisite), conflict edges live only in a gitignored checkpoint, the closed-run refusal is prose only, no plan hash is verified, and every item so far has needed a second orchestrator turn after its PR opened.

## Personas & Scenarios

- Persona: Repository owner (operator of parallel runs)
  - Runs `/parallel-plan` and `/parallel-add` to deliver several issues concurrently.
  - Cares about elapsed time, quota spend, and gate integrity.
  - Constraint: gate intent must not weaken (closed runs stay closed, preflight strictness and the at-most-one-return rule are unchanged).
  - Frustration: prepared work is redone, prerequisites are scheduled out of order, and items stall after the PR opens.
- Persona: Parallel orchestration agents (`parallel-planner`, `parallel-orchestrator`)
  - Run as forks in the session checkout and call repository helpers through granted `pwsh -File` routes.
  - Need mechanical, code-backed answers (stage, staleness, guard, precedence) rather than prose judgment.
- Scenario: Re-seed a run from prepared items
  - Trigger: an earlier run closed with several items prepared but not executed.
  - Steps: the owner runs `/parallel-plan <slug> <items> --after <later>:<earlier>`; the planner assesses each item, finds them `cleared` and `fresh`, computes edges and the precedence lift, writes the scheduling record, and seeds the run with no preparation children.
  - Decision point: one item's cited file changed on `main`; that item resumes at preflight while the others are admitted directly.
  - Outcome: the validators accept the seeded run and the cohort table places the later item after its prerequisite.
- Scenario: Add a half-prepared item to an open run
  - Trigger: an item has research and a spec on its branch but no plan.
  - Steps: the owner runs `/parallel-add <item>`; the guard passes; `assess` reports `spec`; the preparation child is delegated with a resume line naming the plan stage and the existing artifacts.
  - Outcome: the child writes the plan and preflight without redoing research or the spec, and the item is admitted.
- Scenario: Add to a closed run
  - Trigger: the owner runs `/parallel-add` against a run whose manifest mode is `closed`.
  - Outcome: the helper exits with `PARALLEL_ADMISSION_REJECTED: run_closed: <detail>` and nothing is admitted.

## Acceptance Criteria

- [ ] An item whose branch holds research, a spec, a plan, or a cleared preflight is admitted without repeating any completed stage, and the run checkpoint records its `preparation_status` (`none`, `research`, `spec`, `plan`, or `cleared`). Verified by Pester `assess` cases and the local "half-prepared item" integration scenario.
- [ ] When no file the plan cites or writes changed on `main` since the recorded base commit, a `cleared` item is admitted with no preparation child, no preflight, and no plan revision. Verified by Pester staleness cases and the local seed integration scenario.
- [x] When cited files changed, the item goes through the unchanged single-pass preflight contract, a stage is redone only when its premise is falsified, and superseded artifacts are kept as new timestamped files. Verified by Pester verdict-to-action cases.
- [x] The preparation child writes a receipt with the plan hash and base commit, and the execution child stops before any other step when the plan blob hash at its head differs from the admitted hash. Verified by Pester hash cases and the kickoff plan-hash fragment pin in `test_parallel_orchestrator_surface_contracts.py`.
- [ ] `/parallel-add` against a closed run fails with `PARALLEL_ADMISSION_REJECTED: run_closed` emitted by the admission helper. Verified by the Pester guard matrix and the local "add to a closed run" integration scenario.
- [ ] `/parallel-plan` seeds a new run from prepared items without preparation children, and the manifest, planner-state, and orchestrator-state validators accept the result. Verified by the local seed integration scenario with validator exit codes recorded.
- [x] The band comes from `--band`, then the planner checkpoint, then a fresh assessment with a written rationale. Verified by Pester band-source cases.
- [ ] An `--after` precedence input is honored by the cohort table, and a cohort table that violates it is rejected by the helper and by the cohort barrier hook. Verified by Pester precedence and hook suites.
- [ ] Conflict edges are stored in a committed `parallel-scheduling.json` that a re-seed from another checkout reads. Verified by Pester record cases and the local seed integration scenario.
- [x] The parent orchestrator keeps an item at `pr_open` while its CI green gate is pending and re-delegates the child to resume at that gate. Verified by the fragment pin in `test_parallel_orchestrator_surface_contracts.py`.
- [ ] The helper is PowerShell with no new or edited Python or TypeScript, mirrors and bundles are byte-equal, and the push-down, pack-manifest, dependency-closure, and parallel contract tests pass. Verified by the scope diff and contract test runs recorded under `evidence/`.

## Non-Goals

- Changing the bash entry points (`mutate-parallel-run.sh`, `compute-cohorts.sh`) or their Python authorities.
- Editing the Python validators or the TypeScript validator port, including teaching the Layer 2 validator about precedence (D2 known gap).
- Parsing Phase 0 prose for precedence (D5).
- A second preparation mechanism; incomplete items still use the existing preparation-mode child.
- Removing the rebase and re-run CI cost of a tolerated overlap.
- Relaxing any gate: closed runs, preflight strictness, and the at-most-one-return rule are unchanged.
- Splitting the work into child items or an epic (D7).
