# `2026-11-23-docs-family-page-templates` — User Story

- Issue: #1222
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T00-39

## Story Statement

- As a documentation author in a consumer repository, I want ready-made `docs-author-page` templates for product overview, onboarding, runbook, playbook, architecture decision record, security, service management, and alerts catalog pages, so that I start from a shape that already passes the docs page checker instead of hand-authoring it.
- As a documentation reviewer, I want every template to be proven acceptable to the page checker and to be identical in every mirrored copy, so that I can review pages against a known-good shape and trust that the skill and its pushed-down copies agree.

## Problem / Why

The `docs-author-page` skill ships page templates only for surface-driven reference pages and the four Diataxis narrative modes (`api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial`). A production documentation estate also needs pages for documentation families such as product overview, onboarding, operations (runbooks, playbooks, alerts catalog), service management, security, and architecture decision records. Without templates for those families, every consumer repository authors the shape by hand, and the docs page checker has no tested guarantee that such pages are accepted.

## Personas & Scenarios

- Persona: documentation author in a consumer repository
  - Writes and maintains documentation pages, often through the `docs-author` agent and the `docs-author-page` skill.
  - Cares about pages that pass the docs checker on the first run and that follow the Diataxis mode of the page.
  - Constrained by a docs profile that declares audiences and directory modes, and by templates that must not carry another organization's specifics.
  - Frustrated by hand-copying a section outline and by placeholders that fail the checker.
- Scenario: author creates a runbook page
  - The author is asked to document an operational procedure for an operations audience.
  - The author opens the `docs-author-page` SKILL.md template table, selects `runbook.md` (mode `how-to`, use when the page lists diagnostic and remediation steps for a named trigger), and copies it.
  - The author replaces `<owner-id>`, `<yyyy-mm-dd>`, and `<audience-id>`, keeps `surface_refs: []`, and fills the ordered Diagnostics and Remediation lists.
  - The page checker accepts the page. If the author places an `alerts-catalog` page under a directory whose profile mode is how-to, the checker reports a directory-mode mismatch, and the SKILL.md note explains that a more specific `directory_modes` entry is needed.
- Persona: documentation reviewer
  - Reviews documentation changes and template changes for the repository.
  - Cares about consistency between the skill source, the generated copies, and the bundle copies.
  - Constrained by the generator drift check and the push-down contract tests.
- Scenario: reviewer verifies the template change
  - The reviewer runs the acceptance and family template Pester files and the harness generator `-Check`.
  - The reviewer confirms that each template passes the full page checker in memory, that each is byte-identical at four roots, and that each is listed once in three manifests.
  - The reviewer confirms that no docs lib production module changed.

## Acceptance Criteria

- [ ] An author can find the new family templates (`product-overview`, `onboarding`, `runbook`, `playbook`, `adr`, `security`, `service-management`, `alerts-catalog`) under `.claude/skills/docs-author-page/templates/`, each with the Diataxis mode and H2 sections defined in the spec. Traces to the spec criteria on new files and on modes and sections; proved by `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [ ] An author who fills a new template's placeholders gets a page that the full page checker (`Get-DocsPageCheckFinding`) accepts with zero error findings, and the how-to templates carry a literal ordered list that satisfies the steps rule. Traces to the spec criteria on checker acceptance, front matter (`surface_refs: []`, five JSON-valued fields), and ordered lists; proved by `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1`.
- [ ] An author who needs an architecture page finds `## Data Flow`, `## Trust Boundaries`, and `## Failure Domains` in `architecture-overview.md`, with the mode still `explanation`. Traces to the spec criterion on the extended template; proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [ ] An author reading the `docs-author-page` SKILL.md sees every template with its mode and when it applies, the `surface_refs: []` guidance for family pages, and the `alerts-catalog` directory-mode note. Traces to the spec criterion on SKILL.md content; proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [ ] A reviewer sees templates that are domain-neutral: no `review_due` key, no `SME input required` token, no `diataxis:` key, no generated block in `alerts-catalog`, and no reference-estate names, identifiers, or paths. Traces to the spec criteria on non-portable content and generated blocks; proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [ ] A reviewer can confirm parity: each template is byte-identical at the four skill roots, listed once in each pack manifest, SKILL.md is regenerated from the `.agents` source, and the harness generator `-Check` reports no drift. Traces to the spec criteria on generation, byte identity, and manifests; proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1`, `HarnessGeneration.RepoGate.Tests.ps1`, and the generator `-Check` run.
- [ ] A reviewer can confirm no regression: the existing `docs-authoring-roles` Templates, Mirrors, and WorkflowText tests pass unchanged, the push-down contract tests pass, and no docs lib production module changed. Traces to the spec regression and contract criteria; proved by the launcher `pester` suite, the `test_push_down_*` tests, and the branch diff.

## Non-Goals

- The `review_due` front-matter field and review-cadence checks (docs-review-cadence).
- The documentation family schema and `directory_modes` seeding (docs-family-profile-model).
- The docs-complete family check and `docs-plan-ia` edits (docs-family-gate-and-ia).
- The `SME input required` token (docs-prose-markdown-lint).
- Any change to a docs lib production module, the page-metadata schema, or the docs profile example.
