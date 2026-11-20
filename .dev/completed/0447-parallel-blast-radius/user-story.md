# `2026-08-07-parallel-blast-radius` — User Story

- Issue: #447
- Owner: drmoisan
- Status: Ready
- Last Updated: 2026-08-07T12-00

## Story Statement

- As the `parallel-planner` (F4), I want to derive a blast radius from an approved atomic plan and validate it with V1–V3, so that only plans whose declared footprint provably covers their named paths and shared surfaces are admitted to a concurrent cohort.
- As the parallel-orchestration scheduler (F2/F5, via the F3 schema), I want a deterministic, fail-closed `conflicts(a, b)` relation over radii, so that two items execute concurrently only when no path, module, shared-surface, or contract overlap can be shown, and every conflict edge carries auditable reasons.
- As the drift-detection procedure (F8), I want to compute an `observed` radius from an actual diff using the same library that produced the `declared` radius, so that a diff escaping its declared radius is detected by comparing like with like.
- As the repository maintainer, I want the Python reference and the PowerShell mirror proven equivalent by a shared fixture corpus, so that the enforcement hooks (PowerShell) and the planner/validators (Python) cannot disagree about whether two items conflict.

## Problem / Why

The accepted parallel-orchestration design (`docs/research/2026-08-07-parallel-orchestration-design-research.md`, sections 5 and 5.4) schedules independent bugs and features concurrently based on computed blast-radius contention rather than a human-authored dependency graph. No blast-radius computation exists in the repository. Downstream features of the `parallel-orchestration` epic (F3 schema/validators, F4 `parallel-planner`, F8 drift detection) consume the radius shape and the `conflicts(a, b)` contention relation, so this library is the wave-0 foundation of the epic. Radius under-reporting is named in design section 13.1 as the dominant failure mode of the entire design, so the derivation and validation contract must be delivered as tested, cross-language-consistent reference implementations.

The epic's leading indicators depend directly on this library: "Blast-radius V1 coverage validation rejects an atomic plan whose task bodies name a path outside the declared radius" is an F1 behavior, and "a parallel run schedules two or more non-conflicting items into one cohort" is only trustworthy if `conflicts` fails closed. The epic NFR "identical inputs produce identical cohort assignments across Python and PowerShell implementations" requires parity at the radius layer, which this feature establishes with the shared fixture corpus.

## Personas & Scenarios

- Persona: `parallel-planner` agent (F4) — machine consumer, acting for the repository maintainer.
  - Cares about: admitting only plans whose declared radius covers everything the plan names; blocking under-reported radii before any concurrent execution starts.
  - Constraints: the atomic-plan contract is fixed; derivation must work from unmodified plan text.
  - Scenario (V1 rejection — epic leading indicator): The planner derives a radius from an approved plan, then a maintainer hand-narrows the `declared` radius in the manifest. On the next validation pass, `validate_blast_radius` re-extracts the plan's concrete paths, finds one not subsumed by `blast_radius.paths`, and returns a Blocking V1 finding naming that path. The planner refuses to seed the item into a cohort until the radius is corrected.
  - Scenario (V2 rejection): A plan task edits `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, a configured shared surface, but the radius's `shared_surfaces` list does not name it explicitly (only a broad glob in `paths` covers it). V2 returns a Blocking finding; the item cannot be scheduled beside another item until the surface is enumerated.
  - Scenario (V3 advisory): A radius covers more than the configured fraction (0.25) of tracked files. V3 emits one Advisory finding; the item is admitted but will serialize heavily, and the over-breadth is visible in the planner's report.
- Persona: parallel orchestrator / cohort scheduler (F2, F5 via F3) — machine consumer.
  - Cares about: a conflict verdict that never assumes safety it has not proven, with reasons it can serialize into `conflict_edges[].reason`.
  - Scenario (fail-closed conflict): Item A declares `scripts/dev_tools/validate_*.py`; item B declares `scripts/dev_tools/validate_orchestrator_state.py`. Glob-versus-concrete matching proves overlap; `conflicts` returns `conflict: true` with a `path_overlap` reason and the pair in `detail`. Two items whose glob pair cannot be proven disjoint likewise conflict. The two items are placed in different cohorts and serialize.
  - Scenario (safe concurrency): Item A's radius is confined to `docs/**`; item B's to `packages/mcp-server/**`; no shared surface or contract identifier intersects. `conflicts` returns `conflict: false` with no reasons, and both items run in one cohort — the epic's first leading indicator.
- Persona: drift detection (F8) — machine consumer.
  - Scenario: At an item's pre-review commit, F8 passes the `git diff --name-only` output to `radius_from_observed_paths`, obtaining an `observed` radius with modules and shared surfaces resolved by the same rules as the `declared` radius, then recomputes `conflicts` against every co-running item's declared radius. Because both radii come from one library, a genuine escape produces a real conflict edge rather than a false negative caused by divergent resolution rules.
- Persona: repository maintainer (human) — accountable for merge safety.
  - Cares about: the Python validators and the PowerShell enforcement hooks agreeing; deterministic, explainable verdicts; no new dependencies; no changes to the shared plan contract.
  - Scenario: The maintainer reviews a cohort decision by reading the recorded conflict reasons (kind plus detail) and can reproduce the verdict from the committed fixtures, because identical fixture inputs are asserted to produce identical outputs in both test suites.

## Acceptance Criteria

- [x] V1 rejects (Blocking) a radius when the plan's task bodies name a concrete repository path not subsumed by `blast_radius.paths`, naming the uncovered path — satisfying the epic leading indicator.
- [x] V2 rejects (Blocking) a radius that touches a configured shared surface without enumerating it explicitly by concrete path; glob coverage alone does not pass.
- [x] V3 reports (Advisory, never Blocking) a radius whose concrete coverage exceeds the configured fraction of tracked files; the item remains schedulable.
- [x] `conflicts(a, b)` fails closed: any shared-surface overlap conflicts by default, glob pairs that cannot be proven disjoint count as overlap, and the result carries every triggered reason kind for auditability; key-level partitioning of shared surfaces is not attempted (design §13.2).
- [x] A radius derived by the library from a plan always passes V1 against that same plan, so the Blocking gate targets hand-edited, stale, or drifted radii rather than the library's own output.
- [x] Identical inputs produce identical radii, validation findings, and conflict results in the Python reference and the PowerShell mirror, proven by both test suites asserting the shared fixture corpus at `tests/fixtures/blast_radius/` — satisfying the epic NFR at the radius layer.
- [x] The public API documented in `spec.md` (`## Public API Contract`) is sufficient for the downstream consumers as specified: F3 serializes the radius shape and the `ConflictReason.kind` strings, F4 calls derivation plus V1–V3 validation, and F8 computes `observed` radii and recomputes conflicts.
- [x] The feature is delivered without modifying the atomic-plan contract, without modifying existing epic implementations, and without adding dependencies; coverage meets the uniform gates (line >= 85%, branch >= 75%) for every new module.

## Non-Goals

- Key-level partitioning of shared surfaces (design §13.2; epic Non-Goals). A shared surface conflicts by default in v1; measurement precedes any refinement.
- Radius-drift detection and requeue logic (F8). This feature supplies `radius_from_observed_paths` and `conflicts`; the §7 six-step procedure is F8's scope.
- Cohort scheduling (F2) and manifest/checkpoint schemas (F3). This feature defines the radius and conflict contract those features consume.
- Creating `quality-tiers.yml` or its CI `tier-classification` stage. Module resolution uses the `modules` map in `config/blast-radius.json`; the deviation from design §5.1 is recorded in `spec.md`.
- Changing `.claude/skills/atomic-plan-contract/SKILL.md` (accepted decision, design §5.3).
- Adding `hypothesis` or any other dependency; property obligations are met with parametrized invariant tests.
- Cross-process Python↔PowerShell parity execution; parity is proven via the shared committed fixture corpus.
