# Phase 0 — Doc-Set Grep Sweep (Remediation Cycle 1)

Timestamp: 2026-07-19T07-52
Command: grep -n -E "Python source/data|Python package data" docs/engineering/legacy-discovery-and-parity/*.md
Command: grep -n -E "schemas/discovery|docs/discovery/templates" docs/engineering/legacy-discovery-and-parity/*.md
EXIT_CODE: 0

Output Summary:

## Sweep 1 — "Python source/data|Python package data"

Matches (2 total, both in `consumer-onboarding.md`):

- `consumer-onboarding.md:24` — `2. **Schemas and initialization templates — distributed as Python package data via the`
  — classification: (a) known passage, remediated in Phase 1 (P1-T1).
- `consumer-onboarding.md:29` — `   Python source/data through the `@danmoisan/drm-copilot-mcp` npm package (the same`
  — classification: (a) known passage, remediated in Phase 1 (P1-T1).

## Sweep 2 — "schemas/discovery|docs/discovery/templates"

Matches (13 total across three files):

- `consumer-onboarding.md:26` — schema path cited inside the item-2 passage — classification: (a) known
  passage, remediated in Phase 1 (P1-T1).
- `consumer-onboarding.md:27` — template path cited inside the item-2 passage — classification: (a) known
  passage, remediated in Phase 1 (P1-T1).
- `consumer-onboarding.md:33` — template path cited inside the item-2 passage — classification: (a) known
  passage, remediated in Phase 1 (P1-T1).
- `artifacts-and-schemas.md:14` — "Each discovery artifact kind has one versioned JSON Schema file under
  `schemas/discovery/v1/`:" — classification: (b) schema-name-table lead-in; states where schema files
  live in the `drm-copilot` repository itself, asserts no consumer delivery mechanism.
- `artifacts-and-schemas.md:18` — schema-name table row (Feature Contract) — classification: (b) schema
  path reference in a name table, no delivery-mechanism assertion.
- `artifacts-and-schemas.md:19` — schema-name table row (Coverage Ledger) — classification: (b) same as above.
- `artifacts-and-schemas.md:20` — schema-name table row (Runtime Characterization Scenario) —
  classification: (b) same as above.
- `artifacts-and-schemas.md:21` — schema-name table row (Parity Matrix) — classification: (b) same as above.
- `artifacts-and-schemas.md:22` — schema-name table row (Unspecified Behavior Record) — classification:
  (b) same as above.
- `artifacts-and-schemas.md:23` — schema-name table row (Product Decision Record) — classification: (b)
  same as above.
- `artifacts-and-schemas.md:24` — schema-name table row (Evidence Reference) — classification: (b) same
  as above.
- `artifacts-and-schemas.md:32` — "Schemas live under a version-numbered directory (`schemas/discovery/v1/`)"
  — classification: (b) schema-versioning-convention statement describing repository-internal layout, no
  delivery-mechanism assertion.
- `artifacts-and-schemas.md:59` — "The artifact templates under `docs/discovery/templates/artifacts/*.template.json`"
  — classification: (b) governed-glob validation-scan scoping sentence, no delivery-mechanism assertion.
- `domain-profile.md:13` — "`docs/discovery/templates/domain-profile/domain-profile.yaml`. A consumer
  repository copies and edits this template" — classification: (b) `dev.discovery.init`
  template-scaffolding sentence describing a repository-internal starting-point template used when
  `dev.discovery.init` runs inside the `drm-copilot` repository (or a repository into which the template
  itself has already been pushed down); it does not assert a consumer-facing package-based distribution
  mechanism for the template tree.

## Disposition

Every match falls into one of the two allowed classifications:
- (a) one of the two known `consumer-onboarding.md` passages being remediated in Phase 1 (5 matches:
  lines 24, 26, 27, 29, 33), or
- (b) a schema/template path reference elsewhere in the doc set that names a repository-internal file
  location without asserting or implying a current consumer-facing delivery mechanism (10 matches, all in
  `artifacts-and-schemas.md` and `domain-profile.md`).

Zero matches outside the two named `consumer-onboarding.md` passages assert or imply that any package or
tool currently delivers the schemas/templates to a consumer repository. No other page in the six-page doc
set (`README.md`, `workflow.md`, `running-the-workflow.md`) matched either sweep pattern at all.