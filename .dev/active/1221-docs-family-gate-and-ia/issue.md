# docs-family-gate-and-ia (Issue #1221)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1221-docs-family-gate-and-ia/ (Issue #1221)
- Epic: #1217 (documentation-estate-families), wave 1, complexity C3

- Issue: #1221
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1221
- Last Updated: 2026-11-23
- Work Mode: full-feature

## Problem / Why

The docs profile gains a `required_families[]` record and a `legacy_exclusions[]` list (owned by the sibling child docs-family-profile-model). Nothing in the documentation workflow consumes them yet: the docs-complete gate still proves only surface-driven reference coverage, so a consumer repository can pass docs-complete while a required documentation family (onboarding, administration, security, operations, service management, architecture, ADRs) has no page at all, and legacy pages excluded from the estate are never reported.

## Proposed Behavior

- The docs-complete gate (`.claude/lib/docs/DocsCompleteGate.psm1`, its receipt modules, and `DocsValidateCommands.psm1`) fails when a required family has no page in its `directory` and no recorded `exclusion`; fails when the `security` family is required and the repository-root `SECURITY.md` or `CODEOWNERS` is missing; reports each excluded (not applicable) family; and reports every `legacy_exclusions[]` entry on every run. Family pages may carry empty `surface_refs`.
- The docs coverage report (`DocsCoverageReport.psm1`) carries a family section, implemented in its own function so that the placeholder-count section added by docs-prose-markdown-lint does not conflict.
- The `docs-plan-ia` skill gains a family-planning step alongside element-driven planning.
- The docs MCP TypeScript tools (`run_docs_coverage`, `validate_docs_artifacts`, `run_docs_check` as needed) surface the new findings and fields.
- Codex (`.agents`), Copilot, and bundle copies under `extensions/drm-copilot/resources/` stay in parity per `config/harness-parity-matrix.json`, using the harness generator for generated files.

## Acceptance Criteria (early draft)

- [ ] A fixture profile with a required family that has no page and no exclusion fails docs-complete with a finding naming the family id.
- [ ] The same fixture passes the family check after a page is added to the family directory, or after an exclusion is recorded; an excluded family is reported as not applicable.
- [ ] With the security family required, a missing repository-root `SECURITY.md` or `CODEOWNERS` fails docs-complete with a finding naming the file.
- [ ] Every `legacy_exclusions[]` entry is reported on every docs-complete run.
- [ ] A family page with empty `surface_refs` is accepted.
- [ ] Docs coverage output contains a family section produced by its own function.
- [ ] `docs-plan-ia` describes a family-planning step alongside element-driven planning, in every surface copy.
- [ ] The docs MCP tools surface the family findings and fields.
- [ ] Parity checks and the harness generator `-Check` pass.

## Constraints & Risks

- Consumes the family record and legacy list defined by docs-family-profile-model; does not re-implement the schema or loader.
- No new Python. PowerShell 7.4 for the docs library; TypeScript only for MCP surfaces.
- docs-review-cadence edits `DocsCompleteGate.psm1` after this item; the review_due / overdue option is out of scope here.
- Templates and epic-scale routing guidance are out of scope.
- File-size limit 800 lines hard; tests use no temporary files.

## Test Conditions to Consider

- [ ] Pester unit coverage for the family check, the security root-file check, exclusion reporting, and legacy reporting.
- [ ] Jest coverage for the MCP tool output shape.
- [ ] Contract and parity tests for mirrored skill text.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-family-gate-and-ia/` folder from the template
