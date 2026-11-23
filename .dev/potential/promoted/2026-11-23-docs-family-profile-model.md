# docs-family-profile-model (Issue #1218)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1218-docs-family-profile-model/ (Issue #1218)
- Epic: #1217 (documentation-estate-families), wave 0, complexity C3

- Issue: #1218
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1218
- Last Updated: 2026-11-23
## Problem / Why

The docs profile (`docs-profile.json`) describes a documentation estate only through surface-driven reference pages. It has no way to declare the documentation families a production estate needs (product overview, onboarding, user guides, administration, security, operations, service management, architecture, ADRs, reference), no way to record that a family is not applicable, no per-family review interval, and no list of legacy pages that are tolerated while they are migrated. Downstream epic children (the docs-complete family check, page templates, and review cadence) consume a family record whose contract is fixed in the epic Shared Design, so the profile model must exist first.

## Proposed Behavior

- The docs profile schema (`.claude/lib/docs/schemas/v1/docs-profile.schema.json`, `schemas/docs/v1/docs-profile.schema.json`, and the bundle copy under `extensions/drm-copilot/resources/claude-customizations/`) gains an optional `required_families[]` array. Each entry carries `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required` (boolean), and an optional `exclusion` object (`reason`, `recorded_at`). A family with `required: true` and an `exclusion` is not applicable and is reported, not failed.
- The schema gains an optional `legacy_exclusions[]` array of repository-relative page paths, each with a `reason`.
- Profile loading and validation in `.claude/lib/docs/DocsProfile.psm1` and the related DocsProfile*/DocsSchema* modules accept and validate the new keys; a profile without them stays valid.
- `docs-init` (skill `.claude/skills/docs-init` and `DocsProfileCommands.psm1`) seeds the default family set: `product-overview`, `getting-started`, `user-guides`, `administration`, `security`, `operations`, `service-management`, `architecture`, `adr`, `reference`, with the template ids fixed in the epic Shared Design.
- The Codex `.agents` and Copilot surfaces and bundle copies stay in parity per `config/harness-parity-matrix.json`, using the harness generator for generated files.

## Acceptance Criteria (early draft)

- [ ] The three schema copies accept `required_families[]` and `legacy_exclusions[]` with the fields above and remain byte-identical where parity requires it.
- [ ] Profile validation rejects malformed family entries and legacy exclusions with specific errors, and existing profiles without the keys stay valid.
- [ ] `docs-init` writes the ten default families with their template ids.
- [ ] Surface and bundle parity checks pass.

## Constraints & Risks

- No new Python; implementation is PowerShell 7.4 (docs lib) or bash; TypeScript only for MCP/extension command surfaces, and only if the profile change requires it.
- Out of scope: the docs-complete family check and legacy reporting (docs-family-gate-and-ia), page templates (docs-family-page-templates), and `review_due` validation (docs-review-cadence).
- File-size limit 800 lines hard; no temporary files in tests; coverage thresholds per repository rules.

## Test Conditions to Consider

- [ ] Unit coverage of family and legacy-exclusion validation (valid, missing field, wrong type, duplicate id, exclusion shape)
- [ ] docs-init seeding output
- [ ] Schema parity across copies

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-family-profile-model/` folder from the template
