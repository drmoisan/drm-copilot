# parallel-lane-scale-and-barrier-semantics (Issue #479)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-lane-scale-and-barrier-semantics/ (Issue #479)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #479
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/479
- Last Updated: 2026-08-17
- Work Mode: full-bug

## Summary

The `parallel` orchestration surface rejected a proposed work organization of 13 thematic lanes over 69 issues, executed as "lanes in parallel, items within a lane sequential". Four separate defects contribute: the documented cohort barrier is stricter than the barrier both enforcement layers actually implement, the `max_concurrency` ceiling of 8 cannot express 13 concurrent lanes, there is no way to assert an expected lane grouping against the derived conflict components, and there is no staged intake bounding preparation fan-out for a 69-item run.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `/parallel-plan` over a 13-lane, 69-item proposal
- Data source or fixture: `.claude/rules/parallel-orchestration.md`, `.claude/skills/parallel-*/SKILL.md`, `scripts/dev_tools/validate_parallel_*.py`

## Steps to Reproduce

1. Propose a parallel run of 13 thematic lanes covering 69 issues, where items within a lane mutually conflict and lanes are mutually disjoint.
2. Observe that the structure is the transpose of the existing cohort model: a cohort is an independent set in the conflict graph, so a lane whose items mutually conflict is naturally colored across cohorts `0..n-1`, and cohort `k` holds roughly the k-th item of each lane.
3. Attempt to set `max_concurrency` to 13 so that all lanes advance independently.
4. Attempt to confirm that the hand-authored lane grouping survived blast-radius derivation.
5. Attempt to prepare 69 items through `/parallel-plan`.

## Expected Behavior

The cohort model already expresses the intent, so the run should schedule: 13 lanes should advance concurrently, the operator's expected grouping should be confirmable against the derived conflict components, and preparation should be bounded rather than fanning out 69 concurrent child orchestrators.

## Actual Behavior

Four defects prevent it.

**Defect 1 — documented barrier is stricter than the enforced barrier.** `.claude/skills/parallel-orchestrate/SKILL.md:118-123` specifies a GLOBAL barrier: cohort `N+1` branches from `main` only after **every** cohort-`N` item is `merged` or `worktree_removed`. Neither enforcement layer implements it; both implement a strictly weaker PER-EDGE predicate. Layer 1 (`.claude/hooks/enforce-parallel-cohort-barrier.ps1:372-393`, `Test-ParallelCohortBarrierClear`) iterates only conflict-edge neighbors and `continue`s on any neighbor whose cohort index is `>=` the target's, so non-conflicting prior-cohort items are never consulted. Layer 2 (`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py:282-328`, `_violation_endpoints`) judges only `conflict_edges[]` pairs, so a non-conflicting pair that overlapped in time produces no violation. Under the documented global rule a single `blocked_ci_loop_limit` item halts every lane.

**Defect 2 — `max_concurrency` ceiling of 8 is too low.** The bound `1..8` is enforced by orchestrator invariant 4, planner invariant P2, and manifest invariant M4. Thirteen lanes need thirteen slots. `.claude/rules/parallel-orchestration.md` section "Concurrency Bound (A7)" records that 8 was adopted "for symmetry with the epic surface", not derived from a real constraint.

**Defect 3 — no way to assert an expected lane grouping.** The planner derives grouping from blast radii. There is no confirmation that a hand-authored grouping survived derivation and no diagnostic when it does not.

**Defect 4 — no staged intake for large runs.** `/parallel-plan` fans out one preparation-mode child orchestrator per item concurrently. Sixty-nine concurrent preparation delegations is not viable regardless of barrier semantics.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet: the exact rejection text is no longer available, which is why all four contributing defects are addressed rather than only the one that fired.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Blocker for lane-organized parallel runs: the surface cannot schedule a work organization it is structurally capable of expressing.

## Suspected Cause / Notes

- Defect 1 is a documentation defect, not a code defect. Both mechanical layers already implement the correct per-edge predicate; only the prose overstates it. The safety argument for the per-edge rule already exists in the skill: an item branching from a `main` that lacks non-conflicting merged work is the same situation the skill accepts as safe for two same-cohort items (`.claude/skills/parallel-orchestrate/SKILL.md:100-103`). `current_cohort` becomes a progress indicator rather than a scheduling gate; invariant 14 only bounds it and nothing gates on it.
- Defect 3 must add an ASSERTION seam, never a DECLARATION seam. The field must never override a derived edge, never feed `compute_cohorts`, and never influence scheduling, preserving the fail-closed derivation, the prohibition on narrowing a radius to suppress an edge (`.claude/skills/parallel-plan/SKILL.md:190-192`), and the `depends_on` prohibition (invariant 10, P3, M7).
- Defect 3 adds a manifest key, so `.claude/rules/parallel-orchestration.md` must be amended at spec review per its own "Enum Ownership" section.
- Files to inspect: `.claude/rules/parallel-orchestration.md`, the five `parallel-*` skills, `.claude/agents/parallel-orchestrator.md` and `parallel-planner.md`, `scripts/dev_tools/validate_parallel_orchestrator_state.py`, `validate_parallel_planner_state.py`, `parallel_manifest_contract.py`, the TypeScript parity ports under `extensions/drm-copilot/src/lib/validate/parallel-state-*.ts`, and the bash parity layer under `.claude/lib/bash/`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: the three `max_concurrency` bound checks and their TypeScript and bash parity ports; the new optional manifest field's key-gated validation; a backward-compatibility test proving every existing manifest and checkpoint validates byte-identically.
- [x] Integration scenario to retest: a 13-lane transpose fixture that colors into cohorts and schedules with all lanes advancing.
- [x] Manual verification notes: audit every restatement of the global barrier across skills, agents, and rules; confirm no code path implements the global rule before concluding the fix is prose-only.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
