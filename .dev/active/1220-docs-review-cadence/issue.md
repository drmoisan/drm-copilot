# docs-review-cadence (Issue #1220)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1220-docs-review-cadence/ (Issue #1220)
- Epic: #1217 (documentation-estate-families), wave 2

- Issue: #1220
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1220
- Last Updated: 2026-11-23
- Work Mode: full-feature

## Problem / Why

The docs library detects staleness only through evidence pins (`DOCS_STALE_PAGE` in `DocsStaleness.psm1`): a page is stale when the source it pins has changed. A production documentation estate also needs calendar review cadence: runbooks, security pages, and service-management pages must be re-reviewed on a schedule whether or not their pinned source changed. Pages carry `last_reviewed` but no review due date, and nothing reports a page whose review is overdue.

## Proposed Behavior

- Add `review_due` to the page front-matter field enum (`DocsPageFrontMatter.psm1`, `DocsPageMetadata.psm1`, and the schema the page checker uses) and to every page template under `.claude/skills/docs-author-page/templates/`, including the family templates added by docs-family-page-templates.
- Validate that `review_due` is later than `last_reviewed`. When `review_due` is absent, the effective due date is `last_reviewed` plus the family `review_interval_days` (from the family record owned by docs-family-profile-model).
- Report a calendar overdue finding when the effective due date precedes the current instant. The instant comes from an injected clock: the command entry supplies it, and tested code reads no wall clock.
- Add a docs profile setting that decides whether an overdue page blocks docs-complete or only warns. The option is evaluated in `DocsCompleteGate.psm1` after the family check added by docs-family-gate-and-ia.
- Keep the pin-based `DOCS_STALE_PAGE` finding unchanged.

## Acceptance Criteria (early draft)

- [ ] `review_due` is an accepted front-matter field and appears in every page template.
- [ ] A page whose `review_due` is not later than `last_reviewed` produces a validation finding.
- [ ] A page without `review_due` uses `last_reviewed` plus the family `review_interval_days` as its due date.
- [ ] A page whose due date precedes the injected clock instant produces an overdue finding; tests pass fixed instants.
- [ ] The profile option makes an overdue finding block docs-complete, and its default only warns.
- [ ] `DOCS_STALE_PAGE` behavior is unchanged.
- [ ] Claude, Codex, Copilot, and bundle copies stay in parity per `config/harness-parity-matrix.json`.

## Constraints & Risks

- No new Python; PowerShell 7.4 in the docs lib, TypeScript only where an MCP parameter is required.
- Depends on docs-family-profile-model, docs-family-gate-and-ia, and docs-family-page-templates, which are prepared in parallel and not merged.
- File-size tiers (500/700/800) and line coverage >= 85% on new PowerShell.

## Test Conditions to Consider

- [ ] Unit coverage of due-date derivation, ordering validation, overdue detection at boundary instants.
- [ ] docs-complete gate behavior under both option values.
- [ ] Template front-matter contract tests.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-review-cadence/` folder from the template
