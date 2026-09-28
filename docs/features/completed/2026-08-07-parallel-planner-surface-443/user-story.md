# parallel-planner-surface — User Story

- **Issue:** #443
- **Parent:** epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, feature F4, wave 2)
- **Owner:** drmoisan
- **Status:** Approved for planning
- **Last Updated:** 2026-08-07
- **Work Mode:** full-feature (acceptance criteria live in this file and in `spec.md`)

## Story Statements

- As a repository operator with a backlog of unrelated bugs and features, I want to invoke
  `/parallel-plan <slug>` with a mixed list of issue numbers and potential-entry paths, so that
  every item is prepared to preflight clearance concurrently without me authoring a dependency
  graph or answering an epic-worthiness question.
- As a repository operator, I want the planner to compute each item's blast radius from its
  approved atomic plan and derive the conflict-free cohorts itself, so that concurrency is
  decided by evidence (`declared` radii, V1-V3 validation) rather than by my guesses about which
  changes collide.
- As a repository operator, I want planning to end with a durable, replayable kickoff artifact
  and no execution started, so that I control exactly when `/parallel-run <slug>` begins merging
  items to `main`.
- As the future `parallel-orchestrator` (F5) consumer, I want every prepared plan reachable by
  ref (per-item pushed feature branches plus the `parallel/<slug>-plan` run branch) without any
  integration branch, so that items can PR to `main` independently and late arrivals cannot
  invalidate a fan-in point.

## Problem / Why

The `parallel-orchestration` epic delivers a surface that executes multiple thematically
unrelated bugs and features concurrently, scheduled by computed blast-radius contention
(`docs/research/2026-08-07-parallel-orchestration-design-research.md`, §1-§6). That surface
currently has no planning half: nothing prepares the item set, computes each item's
authoritative blast radius, seeds the initial cohort table, or emits the artifact that hands a
prepared run to the execution agent. The epic surface solves the equivalent problem with
`epic-planner` / `epic-plan`; the parallel surface needs its own planning agent and skill with
the deltas the design requires — no worthiness gate, no `depends_on`, no integration branch, and
a planner-computed radius validated against each item's approved atomic plan. The technical
contracts are specified in `spec.md`.

## Personas & Scenarios

### Persona: repository operator (Dan)

Sole maintainer running agentic development on this repository. Cares about throughput (several
unrelated items in flight at once) without relaxing merge safety. Constraints: works from the
main session; will not hand-author dependency edges between items that share no theme; expects
planning and execution to be separate, resumable commands, matching the existing
`/epic-plan` / `/epic-run` split.

### Scenario 1: planning a mixed batch

1. The operator runs `/parallel-plan bugfix-batch 412 415 docs/features/potential/fix-hook-timeout.md`
   from the main session. Two items are promoted issues; one is an unpromoted potential entry.
2. The planner records the intake (the potential entry gets a placeholder `issue_num` of -1) and
   launches three concurrent preparation-mode `Agent(orchestrator)` children, each in its own
   worktree branched from `origin/main`. The operator is not asked for `depends_on`, waves, or a
   worthiness verdict at any point.
3. Each child promotes (where needed), researches, writes `spec.md` and `user-story.md`, produces
   an approved atomic plan, reaches `PREFLIGHT: ALL CLEAR`, commits its feature folder and plan
   to its own branch, and pushes that branch.
4. The planner derives each item's blast radius from its approved plan and validates it. One
   item's plan names a path outside its derived radius; V1 fails Blocking, the item stays
   un-`prepared`, and the planner re-delegates it with the findings until validation passes. The
   operator sees this as recorded findings and a revised plan, not as a dropped item.
5. With all items `prepared`, the planner seeds the cohorts, writes the manifest and checkpoint,
   commits the manifest and durable kickoff to `parallel/bugfix-batch-plan`, and reports:
   per-item plan-path, branch, preflight status, radius-validation result (including any V3
   Advisory), the cohort table, and the kickoff paths. The report states that execution has not
   started.

### Scenario 2: starting execution later

1. Days later, possibly on a different machine, the operator runs `/parallel-run bugfix-batch`.
2. The kickoff and manifest are discovered by ref (`git fetch origin parallel/bugfix-batch-plan`
   plus `git show`), and each item resumes at atomic execution from its committed plan on its own
   pushed feature branch. No integration branch exists to reconcile; each item PRs to `main`
   independently. (Execution behavior itself is F5 scope; F4's obligation is that the prepared
   state makes this scenario possible.)

### Scenario 3: a blocked item does not stall the operator

1. During planning, one item repeatedly fails V2 because it touches
   `config/orchestration-routing.json` without enumerating it in `shared_surfaces`.
2. The planner keeps the item un-`prepared`, records the Blocking findings in the checkpoint,
   and continues iterating that item while the others complete. The operator can inspect the
   recorded `radius_validation` findings at any time, and may later remove the item via F6's
   `/parallel-remove` — removal is the operator's decision, never a planner default.

## Acceptance Criteria

Outcome and behavioral criteria from the operator's perspective. Technical and contract criteria
are in `spec.md`; together the two files are the authoritative acceptance-criteria source for
this `full-feature` work mode. Criteria over live upstream tooling hold to the extent F1/F2/F3
have landed; until then they are verified against the documented procedure in the delivered
skill text (the `[ASSUMPTION]` regime defined in `spec.md`).

- [x] An operator can invoke the delivered skill with a slug plus any mix of GitHub issue
      numbers and potential-entry paths in one command, and unpromoted items are promoted by
      their own preparation-mode child without a separate manual promotion step.
- [x] At no point does the documented planning procedure ask the operator for `depends_on`
      edges, wave assignments, or an epic-worthiness verdict; planning proceeds directly from
      intake to preparation.
- [x] Every item is prepared through the same preparation-mode child contract an epic child
      uses — promotion, research, `spec.md`, `user-story.md`, approved atomic plan,
      `PREFLIGHT: ALL CLEAR` — and the operator can locate each item's prepared feature folder
      and plan on that item's own pushed feature branch afterward.
- [x] An item whose plan fails V1 or V2 is visibly iterated (findings recorded, plan revised via
      a follow-up preparation delegation) rather than silently dropped or auto-withdrawn; an
      over-broad radius (V3) appears in the completion report as an Advisory finding on an item
      that still completes planning.
- [x] The planner's completion report gives the operator, per item: plan-path, branch name,
      preflight status, and radius-validation result; plus the generation-0 cohort table, the
      manifest path, and both kickoff artifact paths — and states that execution has NOT
      started.
- [x] After planning completes, the operator can start execution from a fresh session by
      discovering the kickoff via the `parallel/<slug>-plan` branch (fetch plus `git show`,
      without checking the branch out), replaying `/parallel-run <slug>` at a time of their
      choosing.
- [x] After a planning run, the repository contains only per-item feature branches and the
      single `parallel/<slug>-plan` run branch as new refs; no `parallel` integration branch
      exists and no prepared item folder has been pushed to `main` by the planner.
- [x] Existing epic workflows are unaffected: `/epic-plan` and `/epic-run` behave exactly as
      before F4, with no observable change from this feature's diff.

## Non-Goals

- Executing any item: atomic execution, PR authoring, CI monitoring, merge to `main`, and the
  `parallel-status.md` projection are F5 (`parallel-orchestrator` surface) scope.
- Mutating a live run: `/parallel-add`, `/parallel-remove`, `/parallel-close`, admission
  control, recoloring, and the mutation log are F6 scope; F4 seeds cohorts exactly once.
- Enforcement: the cohort-barrier hook, the worktree-removal gate, and the invocation-origin
  hook extension are F7 scope; F4 documents the extension point only.
- Drift detection (§7) is F8 scope.
- Implementing radius derivation, V1-V3 validation, `conflicts(a, b, config)`, Welsh-Powell coloring, or
  any schema/validator: F1, F2, and F3 own these; F4 calls and conforms.
- Key-level partitioning of shared surfaces and optimal graph coloring (epic non-goals).
- Modifying or refactoring any epic surface.
