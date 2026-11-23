# docs-family-profile-model (Issue #1218) — User Story

- Issue: #1218
- Epic: #1217 (documentation-estate-families), wave 0
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-11-23
- Spec: `.dev/active/1218-docs-family-profile-model/spec.md`

## Story Statement

- As a repository maintainer running `docs-init`, I want the generated docs profile to declare the standard documentation families with their directory, Diataxis mode, template, audience, and review interval, so that my documentation estate is planned against a complete production family set from the first run.
- As a documentation owner, I want to mark a family as not applicable with a recorded reason and time, so that the estate stays complete without inventing pages that do not apply to my product.
- As a documentation owner migrating an existing estate, I want to list legacy pages with a reason, so that they are tolerated and visible while they are migrated.
- As the implementer of the downstream epic children (docs-complete family check, page templates, review cadence), I want a validated family record with a fixed contract, so that I can consume it without re-validating its shape.

## Problem / Why

The docs profile (`docs-profile.json`) describes a documentation estate only through surface-driven reference pages. It has no way to declare the documentation families a production estate needs (product overview, onboarding, user guides, administration, security, operations, service management, architecture, ADRs, reference), no way to record that a family is not applicable, no per-family review interval, and no list of legacy pages that are tolerated while they are migrated. Downstream epic children consume a family record whose contract is fixed in the epic Shared Design, so the profile model must exist first.

## Personas & Scenarios

- Persona: Repository maintainer adopting the docs workflow.
  - Owns a repository that needs production documentation beyond reference pages.
  - Cares about a correct starting configuration and clear validation errors.
  - Constrained to the profile and skills that `docs-init` writes; does not hand-author schemas.
  - Goal: a profile that validates on first run and names every family the estate needs.
- Persona: Documentation owner of an existing estate.
  - Has legacy pages outside the new family layout and some families that do not apply.
  - Cares that exceptions are recorded with reasons rather than silently ignored.
- Persona: Downstream epic implementer.
  - Builds the docs-complete family check, page templates, and review cadence.
  - Needs the family record fields, default ids, and template ids to be stable and validated.

- Scenario: First-time initialization.
  1. The maintainer runs `docs-init` in a repository with no docs profile.
  2. `docs-init` writes `docs/documentation-estate/docs-profile.json` with the default families under `docs/guide/<family-id>`, the starter audiences, and an empty `legacy_exclusions` list.
  3. The maintainer runs `validate-profile`; it reports zero findings.
- Scenario: Marking a family not applicable.
  1. The owner's product has no service-management process.
  2. The owner adds `"exclusion": {"reason": "No managed service is offered.", "recorded_at": "2026-11-23T00:00:00Z"}` to the `service-management` family and keeps `required: true`.
  3. `validate-profile` accepts the profile. Reporting the family as not applicable is done later by the docs-complete gate (docs-family-gate-and-ia).
- Scenario: Correcting a malformed entry.
  1. The owner sets `review_interval_days` to `0` and moves the `security` directory to `docs/security`, outside the documentation root `docs/guide`.
  2. `validate-profile` reports `DOCS_SCHEMA_INVALID` for the interval. After the interval is fixed, it reports `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT` at `/required_families/4/directory` with a next action.
  3. The owner corrects both and the profile validates.
- Scenario: Tolerating legacy pages.
  1. The owner lists `docs/debugging.md` in `legacy_exclusions` with a reason.
  2. Listing the same path twice yields `DOCS_PROFILE_LEGACY_DUPLICATE`; a single entry validates.

## Acceptance Criteria

- [ ] US1. Running `docs-init` writes a profile that holds exactly the default families `product-overview`, `getting-started`, `user-guides`, `administration`, `security`, `operations`, `service-management`, `architecture`, `adr`, `reference`, in that order, each with the directory, Diataxis mode, template id, audience, review interval, and `required` value stated in the spec `## Data & State` table, and that profile validates with zero findings.
- [ ] US2. A maintainer who passes a different documentation root to the starter receives family directories beneath that root, and the profile still validates with zero findings.
- [ ] US3. A documentation owner can record a family as not applicable by adding an `exclusion` with a non-empty `reason` and a UTC `recorded_at`, and the profile validates; an `exclusion` missing either field is rejected with a specific schema finding.
- [ ] US4. A documentation owner can list legacy pages in `legacy_exclusions` with a `path` and `reason`; a repeated path is rejected with `DOCS_PROFILE_LEGACY_DUPLICATE`, and a path with a `..` segment is rejected by the schema.
- [ ] US5. A malformed family entry (missing field, unknown key, wrong type, non-positive interval, duplicate id or directory, undeclared audience, mode outside policy, or directory outside every documentation root) is rejected with the specific code and pointer stated in the spec, and each semantic finding carries a next action.
- [ ] US6. An existing profile without `required_families` or `legacy_exclusions`, including the committed example profile, validates exactly as before.
- [ ] US7. The docs-init skill text on the Codex `.agents` source, the generated Claude copy, and every bundle copy describes the families, the `exclusion` object, and `legacy_exclusions`, and the generator check and bundle parity checks pass.
- [ ] US8. The docs profile schema copies `schemas/docs/v1/docs-profile.schema.json`, `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json` stay byte-identical, and the surface and bundle parity checks pass.

## Non-Goals

- The docs-complete family check, not-applicable reporting, and legacy exclusion reporting (docs-family-gate-and-ia).
- The page template files the `template` ids name (docs-family-page-templates).
- `review_due` front matter, overdue findings, and any cadence use of `review_interval_days` (docs-review-cadence).
- Template-file existence checks, TypeScript or MCP parameter changes, hook changes, and edits to `common.schema.json` or the committed example profile.
