# Evidence Filename Normalization (N2) and Deliberate Non-Edit Record (N3)

Timestamp: 2026-08-08T15-25

Task: [P6-T3]

## Rename Performed

| Field | Value |
|---|---|
| Old path | `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/phase0-instructions-read.md` |
| New path | `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/phase0-instructions-read.2026-08-08T13-49.md` |
| Timestamp component source | The `Timestamp: 2026-08-08T13-49` line already recorded inside the file body |
| Command | `git mv docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/phase0-instructions-read.md docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/phase0-instructions-read.2026-08-08T13-49.md` |
| EXIT_CODE | 0 |
| Verification | `git status --short` reports the change as `R` (a pure rename), confirming byte-identical content; the old path no longer exists and the new filename carries a `yyyy-MM-ddTHH-mm` component |

## Reason

`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` requires every audit, remediation, and evidence artifact filename to carry a `yyyy-MM-ddTHH-mm` timestamp component. The Phase 0 policy-read artifact from the base plan cycle was written without one. Feature review raised this as Non-blocking finding N2. The timestamp used is not newly invented: it is the value the file itself already recorded, so the rename does not misstate when the evidence was produced.

Every sibling artifact in `evidence/baseline/` already carried a timestamp component (`black-baseline.2026-08-08T13-51.md`, `ruff-baseline.2026-08-08T13-52.md`, `pyright-baseline.2026-08-08T13-53.md`, `pytest-coverage-baseline.2026-08-08T13-56.md`), so this rename brings the one outlier into line rather than establishing a new convention.

## Citations of the Old Path Deliberately Not Edited

The old path is cited in four documents that were deliberately NOT edited:

1. `docs/features/active/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md` — the base plan. It is fully executed and is the historical record for the prior cycle; the remediation plan's Non-Negotiable Constraints forbid modifying it.
2. `docs/features/active/2026-08-07-parallel-planner-surface-443/code-review.2026-08-08T14-59.md`
3. `docs/features/active/2026-08-07-parallel-planner-surface-443/feature-audit.2026-08-08T14-59.md`
4. `docs/features/active/2026-08-07-parallel-planner-surface-443/policy-audit.2026-08-08T14-59.md`

The three audit artifacts are point-in-time records of what was observed at 2026-08-08T14-59, when the file still carried the old name. Rewriting them would falsify the audit record. This artifact exists so those citations remain traceable: a reader following any of the four citations to the old path should resolve it to the new path recorded above.

## Deliberate Non-Edit of the Second `conflicts(a, b)` Occurrence (N3 scope boundary)

Non-blocking finding N3 concerns the stale two-argument reference `conflicts(a, b)` where the landed form is the three-argument `conflicts(a, b, config)`. There are two occurrences in this feature folder, and only one is corrected:

| Occurrence | Location | Disposition | Reason |
|---|---|---|---|
| 1 | `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md:135` | CORRECTED by [P6-T4] | The line is Non-Goals prose, not an acceptance criterion, so the preserve-text rule is not engaged. |
| 2 | `docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md:645` | DELIBERATELY NOT EDITED | The occurrence sits inside an acceptance criterion (the criterion beginning "The skill documents invoking F1's radius derivation and V1-V3 validation..." at `spec.md:642-645`). `.claude/skills/acceptance-criteria-tracking/SKILL.md` permits only `- [ ]` <-> `- [x]` state changes on criterion text. Editing the token would be a criterion-text modification and is therefore prohibited. |

The remaining occurrence is recorded here so it is traceable as a deliberate, rule-driven non-edit rather than an oversight. If the criterion text is ever to be corrected, that must be done by the owning planning or scoping agent as a scope change, not by an executor during remediation.
