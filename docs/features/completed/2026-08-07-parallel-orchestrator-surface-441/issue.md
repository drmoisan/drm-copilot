# parallel-orchestrator-surface (Issue #441)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-orchestrator-surface/ (Issue #441)

- Issue: #441
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/441
- Last Updated: 2026-08-07
- Work Mode: full-feature

## Problem / Why

The `parallel-orchestration` epic (`docs/features/epics/parallel-orchestration/epic.md`) delivers a
`parallel` orchestration surface that runs thematically unrelated bugs and features concurrently,
scheduled by computed blast-radius contention. The planning half of that surface (`parallel-planner`
/ `parallel-plan`, feature F4) produces a manifest, prepared child plans, and seeded cohorts, but
nothing consumes them. Without an execution half there is no agent that reads the manifest,
schedules cohorts, fans out child orchestrations onto isolated worktrees, or drives each item to
`main`.

The existing `epic-orchestrator` cannot serve this role. It fans results into a shared integration
branch and drives a single integration-to-`main` PR; the parallel design (§4 of
`docs/research/2026-08-07-parallel-orchestration-design-research.md`) removes the integration branch
entirely and requires each item to open and merge its own PR against `main` independently. The epic
surface is also explicitly out of scope for modification: reuse is by near-verbatim adaptation into
new `parallel`-named files, not by refactoring the epic implementations into a shared abstraction.

## Proposed Behavior

Deliver the execution half of the parallel surface as feature F5 of the epic:

- A `parallel-orchestrator` agent persona at `.claude/agents/parallel-orchestrator.md`.
- A `parallel-orchestrate` procedure skill at `.claude/skills/parallel-orchestrate/SKILL.md`, the
  structural analogue of `epic-orchestrate`.
- A `parallel-run` user-invocable entry point at `.claude/skills/parallel-run/SKILL.md`, the
  structural analogue of `epic-run`.
- Cohort scheduling and child fan-out: cohort `N+1` branches from `main` only after every cohort-`N`
  item has merged (§6), with `max_concurrency` capping fan-out independently of cohort size and
  slots filled in ascending item-key order.
- Per-item merge to `main`: each item opens and merges its own PR against `main` independently (§4).
  This is the central structural delta from the epic surface.
- A generated `docs/features/parallel/<slug>/parallel-status.md` projection, regenerated from the
  checkpoint at defined boundaries and never hand-authored.
- Maintenance of the `artifacts/orchestration/parallel-orchestrator-state.json` checkpoint against
  the schema that feature F3 owns.

## Acceptance Criteria (early draft)

- [ ] `.claude/agents/parallel-orchestrator.md` exists and declares a tools allowlist, model, and
      preloaded skills consistent with the `epic-orchestrator` precedent, minus every
      integration-branch capability.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` defines the cohort barrier, the child kickoff
      contract carrying the literal `Parallel mode: true` marker, per-item merge to `main`, and the
      `parallel-status.md` projection rules.
- [ ] `.claude/skills/parallel-run/SKILL.md` defines the user-invocable entry point and routes to
      `Agent(parallel-orchestrator)`.
- [ ] The skill file is structured with clearly delimited, separately named top-level sections,
      including reserved placeholder sections for mutation protocol (F6), enforcement (F7), and
      drift detection (F8), so those wave-4 features can each append without reflowing content.
- [ ] No integration branch, no final integration PR, and no fan-in merge-conflict path appear
      anywhere in the delivered surface.
- [ ] `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` are
      unmodified by this feature.

## Constraints & Risks

- **Additive only.** The epic surface must not be modified or refactored. Reuse is by near-verbatim
  adaptation into new files.
- **Upstream schema ownership.** F3 owns the manifest schema (§11), the checkpoint schema (§12)
  including `cohorts[]`, `items[]`, `conflict_edges[]`, `mutations[]`, `drift_events[]`, and the
  `merge_status` enum, plus `route_id: parallel`. This feature reads and writes artifacts conforming
  to those schemas and does not define or alter them.
- **Upstream planner ownership.** F4 owns radius computation, V1-V3 validation, cohort seeding, and
  the kickoff artifact. This feature consumes the prepared plan and seeded cohorts; items resume at
  atomic execution from their committed plan-path rather than re-planning.
- **Wave-4 contention.** F6, F7, and F8 all execute after this feature and all three extend
  `.claude/skills/parallel-orchestrate/SKILL.md`. The file must be sectioned so each can append to a
  distinct named section.
- **File size limit.** No production or script file may exceed 500 lines; Markdown documentation is
  exempt, but the skill file should still stay navigable.
- **Risk: per-item merge races.** Items in a cohort branch from the same `main` tip and merge in any
  order. Correctness depends on the non-conflicting-by-construction guarantee that F1/F2 provide; a
  radius under-report surfaces here as a merge conflict.

## Test Conditions to Consider

- [ ] Structural validation that the three delivered files exist and carry the required frontmatter
      fields.
- [ ] Assertion that no delivered file references an integration branch, `epic-merge-gate`, or a
      fan-in merge path.
- [ ] Assertion that the child kickoff contract carries the literal `Parallel mode: true` marker
      that the F7 Layer 1 barrier hook matches on.
- [ ] Assertion that the reserved wave-4 placeholder sections are present and uniquely named.
- [ ] Assertion that `.claude/agents/epic-orchestrator.md` and
      `.claude/skills/epic-orchestrate/SKILL.md` are byte-identical to their pre-change state.
- [ ] Cohort-barrier behavior: cohort `N+1` is not started while any cohort-`N` item is unmerged.
- [ ] `max_concurrency` slot-filling order is ascending item key.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/parallel-orchestrator-surface/` folder from the template
