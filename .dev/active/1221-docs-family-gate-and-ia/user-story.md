# docs-family-gate-and-ia — User Story

- Issue: #1221
- Parent: epic #1217 (documentation-estate-families)
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-23
- Spec: `.dev/active/1221-docs-family-gate-and-ia/spec.md`

## Story Statement

- As a maintainer of a consumer repository, I want docs-complete to fail when a required documentation family has no page, so that the estate cannot pass while onboarding, operations, security, or architecture documentation is absent.
- As a security reviewer, I want docs-complete to fail when the security family is required and the repository-root `SECURITY.md` or `CODEOWNERS` is missing, so that vulnerability reporting and ownership are always declared.
- As a maintainer, I want families that do not apply to be reported as not applicable with their recorded reason, so that an exclusion is visible rather than silent.
- As a documentation lead, I want every legacy-excluded page reported on every docs-complete run, so that the legacy list is visible and can be driven to empty.
- As a documentation author, I want the coverage report to show the status of each family, so that I can see which families need pages.
- As an IA-planning agent, I want the `docs-plan-ia` skill to include a family-planning step, so that planned pages cover required families as well as code elements.
- As an MCP client user, I want the docs MCP tools to return the family findings and the coverage family section, so that I can act on them without running the CLI.

## Problem / Why

The docs profile gains a `required_families[]` record and a `legacy_exclusions[]` list (owned by the sibling child docs-family-profile-model, #1218). Nothing in the documentation workflow consumes them yet: the docs-complete gate still proves only surface-driven reference coverage, so a consumer repository can pass docs-complete while a required documentation family (onboarding, administration, security, operations, service management, architecture, ADRs) has no page at all, and legacy pages excluded from the estate are never reported.

## Personas & Scenarios

- Persona: Repository maintainer
  - Owns a consumer repository that uses the drm-copilot documentation workflow and the opt-in docs-complete merge gate.
  - Cares that the merge gate reflects the documentation the organization requires, not only reference coverage.
  - Constraint: cannot write every family page at once; needs a recorded, visible way to mark a family as not applicable.
  - Goal: a failing gate that names exactly what is missing and how to fix it.
- Persona: Documentation lead
  - Migrates legacy pages into the family structure.
  - Cares that excluded legacy pages are tracked until the list is empty.
  - Goal: one report that shows family status and remaining legacy entries.
- Persona: IA-planning agent (`docs-plan-ia`)
  - Plans the information architecture before authoring.
  - Goal: a step that turns missing families into planned pages with the family template, Diataxis mode, and audience.

- Scenario: Missing operations family
  1. The maintainer runs `validate -Mode docs-complete` on a repository whose profile requires the `operations` family; `docs/operations/` has no `.md` page.
  2. The result is `fail` with `DOCS_FAMILY_PAGE_MISSING` naming `operations` and its directory; the merge hook denies the integration merge as `RECEIPT_FAILING`.
  3. The maintainer adds `docs/operations/runbook.md` (with `surface_refs: []`) and re-runs; the family check passes.
- Scenario: Family not applicable
  1. The repository provides no hosted service, so `service-management` does not apply.
  2. The maintainer records an `exclusion` with a reason and `recorded_at` on that family in the profile.
  3. docs-complete passes and reports `DOCS_FAMILY_NOT_APPLICABLE` (info) for `service-management`.
- Scenario: Security root files
  1. The security family is required; `SECURITY.md` exists at the repository root, but `CODEOWNERS` exists only under `.github/`.
  2. docs-complete fails with `DOCS_FAMILY_ROOT_FILE_MISSING` naming `CODEOWNERS`.
  3. The maintainer adds a root `CODEOWNERS`; the check passes.
- Scenario: Legacy pages
  1. The profile lists two legacy pages under `legacy_exclusions`.
  2. Every docs-complete run reports one `DOCS_LEGACY_EXCLUSIONS_REPORTED` (info) finding naming both paths with their reasons; the coverage report lists both as `legacy-exclusion` lines.
  3. After migration, the lead removes the entries; the finding no longer appears.
- Scenario: IA planning
  1. The `docs-plan-ia` agent reads `required_families` and the coverage `families` section.
  2. For each `missing` family it plans a page in the family directory with the family template, Diataxis mode, and audience; for the security family it plans `SECURITY.md` and `CODEOWNERS`; for a family that does not apply it proposes an `exclusion` with a reason; it plans migration of each legacy entry.
  3. Its result lists the family lines.

## Acceptance Criteria

- [x] A docs-complete run over a profile with a `required: true` family that has no `.md` page in its directory and no `exclusion` fails with an `error` finding `DOCS_FAMILY_PAGE_MISSING` whose `related_ids` contains the family id.
- [x] Adding a `.md` page under that family directory removes the finding; recording an `exclusion` instead removes the error and produces an `info` finding `DOCS_FAMILY_NOT_APPLICABLE` naming the family id.
- [x] With the security family required and not excluded, a missing repository-root `SECURITY.md` or `CODEOWNERS` fails docs-complete with one `error` finding `DOCS_FAMILY_ROOT_FILE_MISSING` per missing file naming that file; `.github/CODEOWNERS` does not satisfy the check.
- [x] Every docs-complete run over a profile with legacy entries reports one `info` finding `DOCS_LEGACY_EXCLUSIONS_REPORTED` whose `related_paths` lists every legacy path and whose message gives each reason; an empty list produces no such finding.
- [x] A family page with `surface_refs: []` is accepted and counted as a family page.
- [x] A profile without families or legacy entries behaves exactly as before the change.
- [x] A failing family check reaches the merge hook as a failing receipt; `DocsCompleteGate.psm1` is unchanged.
- [x] The docs coverage result carries a `families` section produced by `Get-DocsCoverageFamilySection`, and the coverage lines include the `families:` summary line, one `family` line per entry, and one `legacy-exclusion` line per legacy entry.
- [x] Existing docs-complete pass fixtures, including the end-to-end fixtures, keep passing after the starter profile seeds required families, through the opt-in test-helper parameters or through family pages, root files, or exclusions in each fixture.
- [x] All 4 docs-plan-ia skill copies (the `.agents` source, the generated `.claude` copy, and the two bundle copies) describe the family-planning step after the element-assignment steps and list family lines in `## Result`.
- [x] The `validate_docs_artifacts` and `run_docs_coverage` MCP tools return the family findings and the `families` section unchanged, and their descriptions name them.
- [x] The harness generator `-Check`, the parity and push-down contract suites, and the docs manifest test pass.
- [x] `DocsFamilyCheck.psm1` has at least 85% line coverage, changed lines in edited modules do not regress, and Jest per-file thresholds stay at 85% line and 75% branch.

## Non-Goals

- `review_due`, the overdue finding, and the docs-complete review option (docs-review-cadence).
- Page templates and the `docs-author-page` skill (docs-family-page-templates).
- Epic-scale routing guidance (docs-epic-scale-routing).
- The placeholder-count section and prose or markdown lint (docs-prose-markdown-lint).
- The profile schema, loader validation, and `docs-init` seeding (#1218).
- Changes to `DocsCompleteGate.psm1` or the merge hook.
- The pre-existing `FINDINGS_LIMIT` envelope exit-code defect (separate issue).
- Any change to the rgf-forecast reference repository.
