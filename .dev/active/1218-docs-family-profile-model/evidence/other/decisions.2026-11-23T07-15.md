# Execution Decisions (Issue #1218)

Timestamp: 2026-11-23T07-15
Plan: .dev/active/1218-docs-family-profile-model/plan.2026-11-23T00-38.md
Mode: autonomous (recommended option taken, recorded, execution continues)

## D-EX1. Mixed-mode family directories

- Source: the `Mixed-mode family directories` item of `## Shared Design` in `.dev/epics/documentation-estate-families/epic.md`, and the coordinator relay for this run.
- Decision: a family's `diataxis_mode` is the family default, not a constraint on the pages inside the family directory. Rule F4 checks only that the mode is listed in `diataxis_policy.modes`. No page-mode constraint and no `directory_modes` entry is derived from a family record in this feature.
- Rationale: the recommended option of the relay; it keeps F4 as the spec states it and leaves page-mode checking to docs-family-gate-and-ia, so an `alerts-catalog` reference page inside the `operations` how-to family is not reported as a mismatch.
- Effect: `Test-DocsProfileFamilySemantic` help text and the docs-init `## Documentation Families` section state that the mode is a default for the family's pages.

## D-EX2. Open item AC19 verification

- Decision: P4-T4 records a self-review row that verifies `.agents/skills/docs-init/references/standard.md` and its bundle copy contain `**OB-5** Documentation Families`, `**AC-5** (OB-5)`, and `**AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5)` and are byte-identical, because no test fails when that item is absent.
