# `2026-08-07-parallel-enforcement-hooks` — User Story

- Issue: #440
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-07

## Story Statement

- As the repository owner operating a parallel run, I want the cohort ordering rule enforced
  mechanically by hooks and a retrospective validator, so that a `parallel-orchestrator` cannot
  fan out a conflicting item before its prior-cohort conflicts have merged and silently
  invalidate the concurrency guarantee.
- As the repository owner, I want `git worktree remove` gated on a terminal `merge_status`
  (`merged` or `worktree_removed`), so that in-flight work in a parallel child worktree cannot
  be destroyed by a premature removal.
- As the repository owner, I want `Agent(parallel-orchestrator)` and `Agent(parallel-planner)`
  invocations denied when they originate from `orchestrator`, so that the delegation chain
  cannot nest `orchestrator` inside its own delegation, while the existing epic
  invocation-origin behavior remains unchanged.

## Problem / Why

The `parallel` orchestration surface schedules unrelated items into cohorts derived from a
computed blast-radius conflict relation. Cohort `N+1` may branch from `main` only after every
conflicting cohort-`N` item has merged. Without mechanical enforcement, that ordering rule is
advisory only: a `parallel-orchestrator` could fan out a conflicting item early and silently
invalidate the concurrency guarantee the whole design rests on.

The same gap exists for two lifecycle transitions. A worktree removed before its item reached a
terminal merge state destroys in-flight work. An `Agent(parallel-orchestrator)` or
`Agent(parallel-planner)` call originating from `orchestrator` would nest `orchestrator` inside
its own delegation chain, because both parallel agents delegate to `Agent(orchestrator)`.

The epic surface already solved the structurally identical problems with proven hooks
(`enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
`enforce-epic-invocation-origin.ps1`). This feature adapts that precedent to the `parallel`
surface.

Both barrier layers are required. A `PreToolUse` hook fires once per tool call with no
cross-call or conversation-state visibility, so it cannot validate a batch of concurrent
`Agent` calls; the retrospective validator sees the whole recorded batch in the checkpoint but
only after execution. Layer 1 deters per call; Layer 2 proves the batch and blocks completion.
Neither alone closes the gap.

## Personas & Scenarios

- Persona: Repository owner (Dan) running an autonomous parallel orchestration.
  - Who: sole maintainer; delegates implementation to agent orchestrations and relies on
    mechanical gates rather than manual review of every delegation.
  - Cares about: merge safety on `main`, deterministic enforcement, and auditability of why a
    delegation was blocked.
  - Constraints: waves 0–3 of the epic land before this feature executes; enforcement must not
    interfere with non-parallel session traffic.
  - Goals: the ordering rule from the design is enforced, not advisory; blocked calls carry a
    literal, greppable reason string.

- Scenario: Blocked early fan-out.
  - The `parallel-orchestrator` fans out cohort items via `Agent(orchestrator)` delegations
    whose prompts carry `Parallel mode: true` and the target item's
    `docs/features/active/<folder>` path.
  - One target item conflicts (per `conflict_edges[]`) with a cohort-0 item whose
    `merge_status` is `ci_green` — not yet `merged`.
  - The `PreToolUse` hook `enforce-parallel-cohort-barrier.ps1` reads the parallel checkpoint,
    finds the unmerged prior-cohort conflict, and denies the call with
    `PARALLEL_COHORT_BARRIER_BLOCKED`. The orchestrator defers the item until the conflict
    reaches `merged` or `worktree_removed`, then the same delegation is allowed.

- Scenario: Retrospective batch detection.
  - A batch of concurrent delegations slips past per-call checks (each call was individually
    consistent with the checkpoint at read time), and two conflicting items ran concurrently.
  - At `parallel-orchestrator` `SubagentStop`, `validate_parallel_orchestrator_state_text`
    evaluates the cohort-ordering invariant over `cohorts[]`, `conflict_edges[]`, and item
    statuses/timestamps, and appends
    `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` for each
    violated edge. The stop hook surfaces the errors and blocks completion.

- Scenario: Guarded worktree removal.
  - An agent issues `git worktree remove` for a parallel child whose item is still `pr_open`.
  - `enforce-parallel-worktree-removal-gate.ps1` matches the command, resolves the item by
    `worktree_path`, finds a non-terminal `merge_status`, and denies with
    `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. After the item reaches `merged`, the same command is
    allowed.

- Scenario: Invocation-origin protection.
  - An `orchestrator`-context agent attempts `Agent(parallel-orchestrator)`. The extended
    `enforce-epic-invocation-origin.ps1` denies the call. The same invocation from the main
    session is allowed. Epic targets continue to be denied with the unchanged
    `EPIC_INVOCATION_ORIGIN_BLOCKED` reason string.

## Acceptance Criteria

- [ ] Layer 1 hook `.claude/hooks/enforce-parallel-cohort-barrier.ps1` denies an in-scope `Agent(orchestrator)` delegation whose target item has a conflicting item in a strictly prior current-generation cohort with a non-terminal `merge_status`, with a deny reason carrying the exact literal `PARALLEL_COHORT_BARRIER_BLOCKED` (Pester evidence).
- [ ] Layer 1 hook allows an in-scope delegation whose every conflicting prior-cohort item has `merge_status` `merged` or `worktree_removed`, and allows an item with no conflicting prior-cohort neighbors (Pester evidence).
- [ ] Layer 1 hook allows a delegation whose serialized prompt lacks the literal marker `Parallel mode: true` (Pester evidence).
- [ ] Layer 1 hook allows a delegation whose `subagent_type` is not `orchestrator` (Pester evidence).
- [ ] Layer 1 hook fails closed — denies with `PARALLEL_COHORT_BARRIER_BLOCKED` — when the parallel checkpoint file is missing or its JSON is malformed (Pester evidence).
- [ ] Layer 1 hook fails closed — denies — when the target item is unresolvable: no feature-folder path token in the prompt, no matching `items[]` record, or no current-generation cohort assignment (Pester evidence).
- [ ] A conflicting prior-cohort item in `ci_green` does not satisfy the barrier: Layer 1 denies; only `merged` and `worktree_removed` satisfy it (Pester evidence).
- [ ] Layer 2 invariant, exercised through `validate_parallel_orchestrator_state_text`, appends exactly one message per violated conflict edge in the exact form `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`, covering both the structural (same-cohort) and temporal (started-before-merged) violation readings (pytest evidence).
- [ ] Layer 2 invariant is key-gated: a checkpoint lacking the `conflict_edges` / `cohorts` keys validates exactly as before with zero new errors, and a clean multi-cohort checkpoint produces zero barrier errors (pytest evidence).
- [ ] Worktree removal gate `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denies a `git worktree remove` command for an item whose `merge_status` is non-terminal, and fails closed for an unreadable checkpoint or an unmatched worktree path, with the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason prefix (Pester evidence).
- [ ] Worktree removal gate allows `git worktree remove` for an item whose `merge_status` is `merged` or `worktree_removed`, and allows commands that are not `git worktree remove` unconditionally (Pester evidence).
- [ ] Extended `.claude/hooks/enforce-epic-invocation-origin.ps1` denies both `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` calls originating from caller `agent_type` `orchestrator`, and allows the same targets from the main thread and from non-orchestrator agents (Pester evidence).
- [ ] Epic invocation-origin behavior is preserved unchanged: the existing `EPIC_INVOCATION_ORIGIN_BLOCKED` deny reason string is byte-identical for epic targets (exact-string assertion) and all pre-existing tests in `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` pass unmodified (Pester evidence).
- [ ] `.claude/settings.json` registers `enforce-parallel-cohort-barrier.ps1` under `PreToolUse` matcher `Agent`, `enforce-parallel-worktree-removal-gate.ps1` under `PreToolUse` matcher `Bash`, and — unless the Phase 0 check finds F5 already registered it — a `SubagentStop` matcher `parallel-orchestrator` invoking `validate-orchestrator-output.ps1` with the parallel checkpoint path and artifact type.
- [ ] Line coverage >= 85% and branch coverage >= 75% for all new and changed code, with no coverage regression on changed lines.
- [ ] All test files are mirrored under `tests/` per `.claude/rules/general-unit-test.md` (`tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/dev_tools/test_*.py`), use mocked read seams instead of temp files, and are deterministic.

## Non-Goals

- The **drift gate** — blocking a child's transition to review while an unresolved
  `drift_events[]` entry exists — belongs to F8 `parallel-drift-detection`.
- The **abandon gate** — denying `--disposition abandon` without an explicit confirmation
  marker — belongs to F6 `parallel-mutation-protocol`.
- No modification or refactoring of `.claude/hooks/enforce-epic-wave-barrier.ps1` or
  `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; reuse is by near-verbatim adaptation
  into new `parallel`-named files.
- No parallel counterpart to `enforce-epic-merge-gate.ps1`; parallel items PR to `main`
  independently.
- No schema fields added to the F3-owned checkpoint; Layer 2 validates existing fields only.
