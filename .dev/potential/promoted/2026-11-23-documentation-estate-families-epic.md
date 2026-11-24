# documentation-estate-families-epic (Issue #1217)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1217-documentation-estate-families-epic/ (Issue #1217)

- Issue: #1217
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1217
- Last Updated: 2026-11-23
## Problem / Why

The drm-copilot documentation workflow (`.claude/skills/documentation-workflow`, the `docs-*` skills, `.claude/lib/docs/`, `docs-profile.schema.json`, and the docs MCP tools) is surface-driven. Its element kinds are `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`, and `architecture-component`, and the docs-complete gate checks only element dispositions. A full production documentation estate also needs page families that no surface element produces (product overview, onboarding, administration, security, operations, service management, architecture, ADRs), a review cadence, prose and Markdown lint in CI, and a route for an estate too large for one pull request. The reference estate in the `rgf-forecast` repository shows these areas.

## Proposed Behavior

Epic with six child features:

1. Documentation family model in the docs profile schema, seeded by `docs-init`, with not-applicable exclusions, per-family review intervals, and a legacy-page exclusion list.
2. Page templates for the new families, and data-flow and trust-boundary sections in the architecture overview template.
3. Markdown lint and pinned, hash-verified Vale steps in the `_docs-quality.yml` template, tonality Vale rules, and an `SME input required` placeholder token counted in coverage output.
4. A family check in the docs-complete gate (including `SECURITY.md` and `CODEOWNERS` when the security family is required), legacy exclusion reporting, and a family-planning step in `docs-plan-ia`.
5. Review cadence: a `review_due` front-matter field, ordering validation, a calendar overdue finding through an injected clock, and a docs-complete option for blocking on overdue pages.
6. Epic-scale routing guidance in `documentation-workflow` with a default family-wave decomposition.

## Acceptance Criteria (early draft)

- [ ] Every child feature merges into `epic/documentation-estate-families-integration` with a green CI run.
- [ ] A fixture repository with a required family that has no page and no exclusion fails docs-complete, and passes after a page or an exclusion is recorded.
- [ ] The Codex, Claude, and Copilot surfaces and the bundle copies under `extensions/drm-copilot/resources/` stay in parity per `config/harness-parity-matrix.json`.

## Constraints & Risks

- No new Python; PowerShell 7.4 or bash, and TypeScript only for MCP and extension command surfaces.
- Non-goals: an external documentation portal; event or AsyncAPI reference pages.

## Next Step

- [ ] Promote to GitHub issue (epic)
