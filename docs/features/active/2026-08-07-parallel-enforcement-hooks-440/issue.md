# parallel-enforcement-hooks (Issue #440)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-enforcement-hooks/ (Issue #440)
- Epic: `parallel-orchestration` (child F7)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` section 9

- Issue: #440
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/440
- Last Updated: 2026-08-07
- Work Mode: full-feature

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

## Proposed Behavior

Deliver the two-layer cohort barrier plus two lifecycle gates.

- **Layer 1 — per-call deterrent.** A new `PreToolUse` hook
  `.claude/hooks/enforce-parallel-cohort-barrier.ps1` on the `Agent` matcher. It activates when
  the delegation target `subagent_type` is `orchestrator` and the serialized prompt carries the
  marker `Parallel mode: true`. It resolves the target item, reads the parallel checkpoint, and
  denies with reason `PARALLEL_COHORT_BARRIER_BLOCKED` unless every conflicting item in a prior
  cohort is `merged` or `worktree_removed`.
- **Layer 2 — retrospective backstop.** A cohort-ordering invariant inside
  `validate_parallel_orchestrator_state_text`, enforced at `parallel-orchestrator`
  `SubagentStop` time, appending
  `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`.
- **Worktree removal gate.** `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, adapted
  near-verbatim from the epic equivalent.
- **Invocation origin.** Extend the existing
  `.claude/hooks/enforce-epic-invocation-origin.ps1` additively to also deny
  `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` calls originating from
  `orchestrator`, preserving the existing epic behavior byte-compatibly.

Both barrier layers are required. Neither alone closes the gap: a `PreToolUse` hook fires per
call with no cross-call or conversation-state visibility, so it cannot validate a batch of
concurrent `Agent` calls; the retrospective validator sees the batch but only after the fact.

## Acceptance Criteria (early draft)

- [ ] Layer 1 hook denies a conflicting prior-cohort item with `PARALLEL_COHORT_BARRIER_BLOCKED`.
- [ ] Layer 1 hook allows a non-conflicting item and any call lacking the `Parallel mode: true` marker.
- [ ] Layer 2 invariant appends `PARALLEL_COHORT_BARRIER_VIOLATION` for a concurrency violation.
- [ ] Worktree removal gate blocks removal for a non-terminal item state.
- [ ] Invocation-origin hook denies both parallel personas from `orchestrator` while preserving epic behavior.

## Constraints & Risks

- **Wave-4 contention.** F6 and F8 execute concurrently and touch the same
  `.claude/skills/parallel-orchestrate/SKILL.md` and `validate_parallel_orchestrator_state.py`
  files. Edits must be confined to a distinct, explicitly named new section and must not reflow
  or reorder existing sections.
- **Upstream ownership.** F3 owns the complete checkpoint schema; Layer 2 adds validation logic
  over existing fields rather than adding schema fields. F5 owns the `Parallel mode: true`
  kickoff marker Layer 1 matches on.
- **Additive only.** The epic barrier and removal-gate hooks must not be modified or refactored.
- **Out of scope.** The drift gate belongs to F8; the abandon gate belongs to F6.

## Test Conditions to Consider

- [ ] Unit coverage for allow/deny decision paths in each hook (Pester)
- [ ] Unit coverage for the Layer 2 cohort-ordering invariant (Pytest)
- [ ] Malformed and absent payload handling for each hook
- [ ] Backward compatibility of the extended invocation-origin hook for epic targets

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-enforcement-hooks/` folder from the template
