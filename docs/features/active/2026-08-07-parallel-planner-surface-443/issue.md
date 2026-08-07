# parallel-planner-surface (Issue #443)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-planner-surface/ (Issue #443)

- Issue: #443
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/443
- Last Updated: 2026-08-07
- Work Mode: full-feature

## Problem / Why

The `parallel-orchestration` epic delivers a `parallel` orchestration surface that executes
multiple thematically unrelated bugs and features concurrently, scheduled by computed
blast-radius contention rather than a human-authored dependency graph. That surface has no
planning half: nothing prepares the item set, computes each item's authoritative blast radius,
seeds the initial cohort table, or emits the artifact that hands a prepared run to the
execution agent.

The epic surface solves the equivalent problem with `epic-planner` / `epic-plan`. The
`parallel` surface needs its own planning agent and skill, structurally parallel but with the
deltas the design requires: no epic-worthiness gate, no human-authored `depends_on`, no
integration branch, and a planner-computed radius validated against each item's approved
atomic plan.

Authoritative design input:
`docs/research/2026-08-07-parallel-orchestration-design-research.md` (sections 3, 5, 6, 8.3,
11, 12). Epic narrative and shared constraints:
`docs/features/epics/parallel-orchestration/epic.md` (feature F4, wave 2).

## Proposed Behavior

Deliver the planning half of the `parallel` surface:

1. `.claude/agents/parallel-planner.md` — the agent persona, including its tool allowlist,
   model, preloaded skills, and invocation-origin constraints.
2. `.claude/skills/parallel-plan/SKILL.md` — the planning procedure: item intake, preparation
   fan-out, radius computation and validation, cohort seeding, manifest and checkpoint
   authoring, and kickoff emission.
3. Preparation fan-out that reuses the existing `route_id: preparation` child contract
   unchanged (design section 8.3 item 2): one preparation-mode `Agent(orchestrator)` run per
   item covering promotion, research, `spec.md`, `user-story.md`, atomic plan, and preflight
   clearance.
4. Blast-radius computation and V1-V3 validation (design section 5.3) invoked against each
   item's approved atomic plan, producing the `declared` radius that is authoritative for
   scheduling.
5. Cohort seeding (design section 6) via the upstream Welsh-Powell reference implementation.
6. A kickoff prompt artifact mirroring the epic kickoff contract.
7. Writing `artifacts/orchestration/parallel-planner-state.json` and the
   `docs/features/parallel/<slug>/parallel.md` manifest.

## Acceptance Criteria (early draft)

- [ ] `.claude/agents/parallel-planner.md` exists and declares the `parallel-planner` persona.
- [ ] `.claude/skills/parallel-plan/SKILL.md` exists and documents the planning procedure.
- [ ] Preparation fan-out reuses `route_id: preparation` unchanged; no change to the
      preparation route contract or to `.claude/skills/orchestrate/SKILL.md` preparation-mode
      section.
- [ ] The planner computes the `declared` blast radius by calling the upstream derivation and
      V1-V3 validation; it does not reimplement them.
- [ ] V1 (coverage) and V2 (shared-surface enumeration) are Blocking; V3 (over-breadth) is
      Advisory.
- [ ] Cohort seeding calls the upstream Welsh-Powell coloring reference; coloring is not
      reimplemented.
- [ ] The planner emits a kickoff prompt artifact mirroring the epic kickoff contract.
- [ ] The planner writes `artifacts/orchestration/parallel-planner-state.json` conforming to
      the upstream checkpoint schema.
- [ ] The planner writes `docs/features/parallel/<slug>/parallel.md` conforming to the
      upstream manifest schema, carrying no `depends_on` field.
- [ ] No epic-worthiness gate analogue and no human-authored dependency graph exist anywhere
      in the delivered surface.
- [ ] The planner creates no integration branch.
- [ ] `.claude/skills/atomic-plan-contract/SKILL.md` is unmodified.
- [ ] `.claude/agents/epic-planner.md` and `.claude/skills/epic-plan/SKILL.md` are unmodified.

## Constraints & Risks

Constraints (non-negotiable, from the epic's Shared Design section):

- The surface is named `parallel` throughout: skill `parallel-plan`, agent `parallel-planner`,
  home `docs/features/parallel/<slug>/`, manifest `parallel.md`, checkpoint
  `artifacts/orchestration/parallel-planner-state.json`.
- No epic-worthiness gate analogue; no dependency graph to author. The planner computes blast
  radii and derives conflicts; it never asks a human for `depends_on`.
- Blast radius is planner-computed and validated against the approved atomic plan.
- No integration branch. Items PR to `main` independently.
- The atomic-plan contract must not change.
- Additive only: `epic-planner` and `epic-plan` are not modified or refactored.

Risks:

- **Upstream availability.** This feature depends on F1 (blast-radius library), F2 (cohort
  scheduler), and F3 (schema and validators). If those specs have not landed on the
  integration branch at planning time, the design sections serve as the contract and the
  assumption must be recorded.
- **Artifact home for prepared items.** With no shared fan-in branch, where prepared items'
  planning artifacts live is a real design question the design document does not fully answer.
  It must be resolved explicitly in research and stated in `spec.md`.
- **Heuristic radius derivation under-reports** (design section 13.1). Bounded by V1 at plan
  time and by drift detection at execution time, not eliminated.

## Test Conditions to Consider

- [ ] Structural validation of the agent and skill Markdown against repository conventions.
- [ ] Manifest output validates against the upstream manifest schema.
- [ ] Checkpoint output validates against the upstream planner-state validator.
- [ ] Kickoff artifact conforms to the kickoff contract.
- [ ] Radius derivation and V1-V3 validation are invoked, not reimplemented.
- [ ] Cohort seeding calls the upstream coloring reference, not a local reimplementation.
- [ ] Negative case: an item whose plan names a path outside the declared radius fails V1.
- [ ] Negative case: an item touching a shared surface not enumerated in `shared_surfaces`
      fails V2.
- [ ] Advisory case: an over-broad radius is reported without rejection (V3).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-planner-surface/` folder from the template
