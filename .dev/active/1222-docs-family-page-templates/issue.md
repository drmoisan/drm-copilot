# docs-family-page-templates (Issue #1222)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1222-docs-family-page-templates/ (Issue #1222)
- Epic: #1217 (documentation-estate-families), wave 0, complexity C2, no dependencies

- Issue: #1222
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1222
- Last Updated: 2026-11-23
- Work Mode: full-feature

## Problem / Why

The `docs-author-page` skill ships page templates only for surface-driven reference pages and the four Diataxis narrative modes (`api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial`). A production documentation estate also needs pages for documentation families such as product overview, onboarding, operations (runbooks, playbooks, alerts catalog), service management, security, and architecture decision records. Without templates for those families, every consumer repository authors the shape by hand, and the docs page checker has no tested guarantee that such pages are accepted.

## Proposed Behavior

- Add page templates under `.claude/skills/docs-author-page/templates/`: `product-overview.md`, `onboarding.md`, `runbook.md`, `playbook.md`, `adr.md`, `security.md`, `service-management.md` (SLI/SLO/SLA, change and release, incident management), and `alerts-catalog.md`.
- Extend `architecture-overview.md` with data-flow and trust-boundary/failure-domain sections.
- Use the production-documentation templates of a reference estate as the starting shape, made domain-neutral, and follow the front-matter fields and Diataxis conventions that the existing templates use.
- Update `.claude/skills/docs-author-page/SKILL.md` to list the new templates and when each applies.
- Keep the Codex `.agents`, the Copilot surface, and the bundle copies under `extensions/drm-copilot/resources/` in parity per `config/harness-parity-matrix.json`, using `scripts/harness-generation/Invoke-HarnessGeneration.ps1` for generated files.

## Acceptance Criteria (early draft)

- [ ] The eight new template files exist under `.claude/skills/docs-author-page/templates/` with the template ids fixed by the epic shared design.
- [ ] `architecture-overview.md` carries data-flow and trust-boundary/failure-domain sections.
- [ ] Each new and extended template is accepted by the docs page checker modules (`DocsPageFrontMatter`, `DocsPageDiataxis`, `DocsPageCheck`), proven by Pester tests.
- [ ] `docs-author-page` SKILL.md lists every template and when it applies.
- [ ] All mirrored and bundled copies are in parity and the harness generator `-Check` reports no drift.

## Constraints & Risks

- No new Python; any test or tooling is PowerShell 7.4 (Pester) or bash.
- Templates are domain-neutral; repository specificity belongs in the docs profile.
- Out of scope: the `review_due` front-matter field (docs-review-cadence), the family schema (docs-family-profile-model), and the docs-complete family check (docs-family-gate-and-ia).
- Files stay within the 800-line hard limit; tests create no temporary files.

## Test Conditions to Consider

- [ ] Pester tests that run the page checker over each template rendered as a page
- [ ] Parity and bundle contract tests for the mirrored template files
- [ ] Harness generator check for generated skill copies

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-family-page-templates/` folder from the template
