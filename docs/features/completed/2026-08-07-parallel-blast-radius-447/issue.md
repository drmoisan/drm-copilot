# parallel-blast-radius (Issue #447)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-blast-radius/ (Issue #447)

- Issue: #447
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/447
- Last Updated: 2026-08-07
- Work Mode: full-feature

## Problem / Why

The accepted parallel-orchestration design (`docs/research/2026-08-07-parallel-orchestration-design-research.md`, sections 5 and 5.4) schedules independent bugs and features concurrently based on computed blast-radius contention rather than a human-authored dependency graph. No blast-radius computation exists in the repository. Downstream features of the `parallel-orchestration` epic (F3 schema/validators, F4 `parallel-planner`, F8 drift detection) consume the radius shape and the `conflicts(a, b)` contention relation, so this library is the wave-0 foundation of the epic. Radius under-reporting is named in design section 13.1 as the dominant failure mode of the entire design, so the derivation and validation contract must be delivered as tested, cross-language-consistent reference implementations.

## Proposed Behavior

Deliver the blast-radius library:

- `scripts/dev_tools/compute_blast_radius.py` — the canonical, tested Python reference implementation.
- `.claude/lib/blast-radius/BlastRadius.psm1` — the PowerShell parity implementation (required because the Layer 1 enforcement hooks are PowerShell).
- A configuration truth table enumerating the high-contention shared surfaces of design section 5.1 item 3 (`config/orchestration-routing.json`, `.claude/settings.json`, lockfiles, `quality-tiers.yml`, shared validators).
- A cross-language parity test proving the Python and PowerShell implementations agree, in the manner of the existing `epic_wave_computation.py` and model-routing parity tests.
- The `conflicts(a, b)` contention relation of design section 5.4.

Implements the four-level radius model (section 5.1: `paths`, `modules`, `shared_surfaces`, `contracts`), the three confidence sources (section 5.2: `derived`, `declared`, `observed`), and the derivation plus validation contract of section 5.3, including validation rules V1 (coverage, Blocking), V2 (shared-surface enumeration, Blocking), and V3 (over-breadth, Advisory).

## Acceptance Criteria (early draft)

- [ ] `scripts/dev_tools/compute_blast_radius.py` implements the four-level radius model, the three confidence sources, radius derivation, V1–V3 validation, and `conflicts(a, b)`.
- [ ] `.claude/lib/blast-radius/BlastRadius.psm1` implements the same behavior with cross-language parity.
- [ ] A configuration truth table enumerates the shared surfaces of design section 5.1 item 3.
- [ ] A cross-language parity test proves the Python and PowerShell implementations agree on identical inputs.
- [ ] The contention relation fails closed: any shared-surface overlap creates a conflict; key-level partitioning is out of scope (section 13.2).
- [ ] V1 rejects a plan whose task bodies name a concrete repository path outside the declared radius (Blocking); V2 requires explicit shared-surface enumeration (Blocking); V3 reports over-breadth (Advisory).
- [ ] The module-resolution source for the `modules` level is resolved explicitly: either a new `quality-tiers.yml` is created or an alternative source is defined, with the deviation from section 5.1 recorded in `spec.md` (no `quality-tiers.yml` currently exists at the repository root).
- [ ] The public API of both implementations is defined explicitly in `spec.md` as a cross-module contract for F3, F4, and F8.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module.

## Constraints & Risks

- The atomic-plan contract (`.claude/skills/atomic-plan-contract/SKILL.md`) must NOT be changed; the radius is derived heuristically from approved plan task bodies and `spec.md` (accepted decision, section 5.3).
- The surface is named `parallel` throughout.
- Additive only: no modification or refactoring of the existing epic implementations.
- Heuristic derivation can under-report; V1 bounds this at plan time (section 13.1). Drift detection (F8) bounds it at execution time and is out of scope here.
- Design section 5.1 references `quality-tiers.yml`, which does not exist at the repository root; research must resolve this gap explicitly.

## Test Conditions to Consider

- [ ] Unit coverage: derivation from plan/spec text, path-to-module mapping, shared-surface intersection, contract extraction, each of V1/V2/V3, each of the four `conflicts` disjuncts, fail-closed behavior.
- [ ] Property/edge cases: empty radius, glob subsumption, whitespace and CRLF handling in plan parsing, over-breadth threshold boundary.
- [ ] Cross-language parity: identical fixture inputs produce identical radii, validation verdicts, and conflict edges in Python and PowerShell.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-blast-radius/` folder from the template
